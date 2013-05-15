//
//  SLElement.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLElement.h"
#import "SLElement+Subclassing.h"
#import "SLAccessibility.h"

#import <objc/runtime.h>


#pragma mark SLElement

// all exceptions thrown by SLElement must have names beginning with this prefix
// so that they may be identified as "expected" throughout the testing framework
NSString *const SLElementExceptionNamePrefix    = @"SLElement";

NSString *const SLElementInvalidException       = @"SLElementInvalidException";
NSString *const SLElementNotTappableException   = @"SLElementNotTappableException";
NSString *const SLElementNotVisibleException    = @"SLElementNotVisibleException";
NSString *const SLElementVisibleException       = @"SLElementVisibleException";

const NSTimeInterval SLElementWaitRetryDelay = 0.25;

const CGPoint SLCGPointNull = (CGPoint){ INFINITY, INFINITY };

BOOL SLCGPointIsNull(CGPoint point) {
    return CGPointEqualToPoint(point, SLCGPointNull);
}

static NSString *const SLElementIsTappableFunctionName = @"SLElementIsTappable";


@interface SLElement ()

- (id)initWithPredicate:(BOOL (^)(NSObject *obj))predicate description:(NSString *)description;

@end


@implementation SLElement {
    BOOL (^_matchesObject)(NSObject*);
@protected
    NSString *_description;
}

static const void *const kDefaultTimeoutKey = &kDefaultTimeoutKey;
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
    if (defaultTimeout != [self defaultTimeout]) {
        // note that we explicitly associate with SLElement
        // so that subclasses can reference the timeout too
        objc_setAssociatedObject([SLElement class], kDefaultTimeoutKey, @(defaultTimeout), OBJC_ASSOCIATION_RETAIN);
    }
}

+ (NSTimeInterval)defaultTimeout {
    return (NSTimeInterval)[objc_getAssociatedObject([SLElement class], kDefaultTimeoutKey) doubleValue];
}

+ (void)loadSLElementIsTappableFunction {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SLTerminal sharedTerminal] loadFunctionWithName:SLElementIsTappableFunctionName
                                                   params:@[ @"element" ]
                                                     body:@"return (element.hitpoint() != null);"];
    });
}

+ (id)elementMatching:(BOOL (^)(NSObject *obj))predicate withDescription:(NSString *)description
{
    return [[self alloc] initWithPredicate:predicate description:description];
}

+ (instancetype)anyElement {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return YES;
    } description:@"any element"];
}

+ (id)elementWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return [obj.slAccessibilityName isEqualToString:label] || ([obj.accessibilityLabel length] > 0 && [obj.accessibilityLabel isEqualToString:label]);
    } description:label];
}

+ (id)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        BOOL matchesLabel = (label == nil || [obj.slAccessibilityName isEqualToString:label] || ([obj.accessibilityLabel length] > 0 && [obj.accessibilityLabel isEqualToString:label]));
        BOOL matchesValue = (value == nil || [obj.accessibilityValue isEqualToString:value]);
        BOOL matchesTraits = (obj.accessibilityTraits & traits) == traits;
        return (matchesLabel && matchesValue && matchesTraits);
    } description:[NSString stringWithFormat:@"label: %@; value: %@; traits: %llu", label, value, traits]];
}

- (id)initWithPredicate:(BOOL (^)(NSObject *))predicate description:(NSString *)description {
    self = [super init];
    if (self) {
        _matchesObject = predicate;
        _description = description;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ description:\"%@\">", NSStringFromClass([self class]), _description];
}

- (NSString *)staticUIARepresentation {
    return nil;
}

#pragma mark Sending Actions

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void(^)(NSString *uiaRepresentation))block {
    [self waitUntilTappable:waitUntilTappable
          thenPerformActionWithUIARepresentation:block
                                         timeout:[[self class] defaultTimeout]];
}

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void(^)(NSString *uiaRepresentation))block
                                       timeout:(NSTimeInterval)timeout {

    // A uiaRepresentation is created, unless a staticUIARepresentation is provided, and is passed to the action block.
    
    NSString *staticUIARepresentation = [self staticUIARepresentation];
    if (staticUIARepresentation) {
        block(staticUIARepresentation);
        return;
    }

    NSTimeInterval resolutionStart = [NSDate timeIntervalSinceReferenceDate];
    
    SLAccessibilityPath *accessibilityPath = [self accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        [NSException raise:SLElementInvalidException format:@"Element '%@' does not exist.", self];
    }
    
    NSTimeInterval resolutionEnd = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval resolutionDuration = resolutionEnd - resolutionStart;
    NSTimeInterval remainingTimeout = timeout - resolutionDuration;

    // It's possible, if unlikely, that one or more path components could have dropped
    // out of scope between the path's construction and its binding/serialization
    // here. If the representation is invalid, UIAutomation will throw an exception,
    // and it will be caught by Subliminal.
    NSException *__block actionException = nil;
    [accessibilityPath bindPath:^(SLAccessibilityPath *boundPath) {
        // catch and rethrow exceptions so that we can unbind the path
        @try {
            NSString *UIARepresentation = [boundPath UIARepresentation];
            if (waitUntilTappable) {
                [[self class] loadSLElementIsTappableFunction];
                BOOL didBecomeTappable = [[SLTerminal sharedTerminal] waitUntilFunctionWithNameIsTrue:SLElementIsTappableFunctionName
                                                                                whenEvaluatedWithArgs:@[ UIARepresentation ]
                                                                                           retryDelay:SLElementWaitRetryDelay
                                                                                              timeout:remainingTimeout ];
                if (!didBecomeTappable) {
                    [NSException raise:SLElementNotTappableException format:@"Element '%@' is not tappable.", self];
                }
            }

            block(UIARepresentation);
        }
        @catch (NSException *exception) {
            actionException = exception;
        }
    }];
    if (actionException) @throw actionException;
}

- (SLAccessibilityPath *)accessibilityPathWithTimeout:(NSTimeInterval)timeout {
    __block SLAccessibilityPath *accessibilityPath = nil;
    NSDate *startDate = [NSDate date];
    // a timeout of 0 means check once--but then return immediately, no waiting
    do {
        dispatch_sync(dispatch_get_main_queue(), ^{
            accessibilityPath = [[[UIApplication sharedApplication] keyWindow] slAccessibilityPathToElement:self];
        });
        if (accessibilityPath || !timeout) break;
        
        [NSThread sleepForTimeInterval:SLElementWaitRetryDelay];
    } while ([[NSDate date] timeIntervalSinceDate:startDate] < timeout);
    return accessibilityPath;
}

- (void)examineMatchingObject:(void (^)(NSObject *object))block {
    [self examineMatchingObject:block timeout:[[self class] defaultTimeout]];
}

- (void)examineMatchingObject:(void (^)(NSObject *))block timeout:(NSTimeInterval)timeout {
    NSParameterAssert(block);
    
    SLAccessibilityPath *accessibilityPath = [self accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        [NSException raise:SLElementInvalidException
                    format:@"Element '%@' does not exist.", [_description slStringByEscapingForJavaScriptLiteral]];
    }

    // It's possible, if unlikely, that the matching object could have dropped
    // out of scope between the path's construction and its examination here
    __block BOOL matchingObjectWasOutOfScope = NO;
    [accessibilityPath examineLastPathComponent:^(NSObject *lastPathComponent) {
        if (!lastPathComponent) {
            matchingObjectWasOutOfScope = YES;
            return;
        }
        block(lastPathComponent);
    }];

    if (matchingObjectWasOutOfScope) {
        [NSException raise:SLElementInvalidException
                    format:@"Element '%@' does not exist.", [_description slStringByEscapingForJavaScriptLiteral]];
    }
}

- (id)waitUntilTappable:(BOOL)waitUntilTappable
        thenSendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    id __block returnValue = nil;
    [self waitUntilTappable:waitUntilTappable
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        returnValue = [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@", uiaRepresentation, formattedAction];
    }];
    
    return returnValue;
}

- (BOOL)isValid {
    // isValid evaluates the current state, no waiting to resolve the element
    return ([self accessibilityPathWithTimeout:0.0] != nil);
}

/*
 Subliminal's implementation of -isVisible does not rely upon UIAutomation to check
 visibility of UIViews or UIAccessibilityElements, because UIAElement.isVisible()
 has a number of bugs. See SLElementVisibilityTest for more information. For some classes,
 for example those vended by UIWebBrowserView, we cannot fully determine whether or not
 they will be visible, and must depend on UIAutomation to confirm visibility.
 
 */
- (BOOL)isVisible {
    __block BOOL isVisible = NO;
    __block BOOL matchedObjectOfUnknownClass = NO;
    // isVisible evaluates the current state, no waiting to resolve the element
    [self examineMatchingObject:^(NSObject *object) {
        isVisible = [object slAccessibilityIsVisible];
        matchedObjectOfUnknownClass = ![object isKindOfClass:[UIView class]] && ![object isKindOfClass:[UIAccessibilityElement class]];
    } timeout:0.0];

    if (isVisible && matchedObjectOfUnknownClass) {
        isVisible = [[self waitUntilTappable:NO thenSendMessage:@"isVisible()"] boolValue];
    }

    return isVisible;
}

- (BOOL)isTappable {
    __block BOOL isTappable;
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        [[self class] loadSLElementIsTappableFunction];
        isTappable = [[[SLTerminal sharedTerminal] evalFunctionWithName:SLElementIsTappableFunctionName
                                                               withArgs:@[ uiaRepresentation ]] boolValue];
    }];
    return isTappable;
}

- (void)tap {
    [self waitUntilTappable:YES thenSendMessage:@"tap()"];
}

- (void)dragWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [self waitUntilTappable:YES
           thenSendMessage:@"dragInsideWithOptions({startOffset:{x:%f, y:%f}, endOffset:{x:%f, y:%f}, duration:1.0})",
                             startPoint.x, startPoint.y, endPoint.x, endPoint.y];
}

- (NSString *)label {
    return [self waitUntilTappable:NO thenSendMessage:@"label()"];
}

- (NSString *)value {
    return [self waitUntilTappable:NO thenSendMessage:@"value()"];
}

- (CGPoint)hitpoint {
    NSString *__block CGHitpointString = nil;
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *hitpointString = [NSString stringWithFormat:@"%@.hitpoint()", uiaRepresentation];
        CGHitpointString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLCGPointStringFromJSPoint"
                                                                      params:@[ @"point" ]
                                                                        body:@"if (!point) return '';\
                                                                               else return '{' + point.x + ',' + point.y + '}';"
                                                                    withArgs:@[ hitpointString ]];
    }];
    return ([CGHitpointString length] ? CGPointFromString(CGHitpointString) : SLCGPointNull);
}

- (CGRect)rect {
    NSString *__block CGRectString = nil;
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *rectString = [NSString stringWithFormat:@"%@.rect()", uiaRepresentation];
        CGRectString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLCGRectStringFromJSRect"
                                                                  params:@[ @"rect" ]
                                                                    body:@"if (!rect) return '';\
                                                                           else return '{{' + rect.origin.x + ',' + rect.origin.y + '},\
                                                                                         {' + rect.size.width + ',' + rect.size.height + '}}';"
                                                                withArgs:@[ rectString ]];
    }];
    return ([CGRectString length] ? CGRectFromString(CGRectString) : CGRectNull);
}

- (void)logElement {
    [self waitUntilTappable:NO thenSendMessage:@"logElement()"];
}

- (void)logElementTree {
    [self waitUntilTappable:NO thenSendMessage:@"logElementTree()"];
}

- (BOOL)matchesObject:(NSObject *)object
{
    NSAssert(_matchesObject, @"matchesObject called on %@, which has no _matchesObject predicate", self);
    BOOL matchesObject = _matchesObject(object);

    return (matchesObject && [object willAppearInAccessibilityHierarchy]);
}

@end


// This function cannot use -examineMatchingObject:timeout: because
// the block passed to that method ultimately executes on the main thread--we can't wait therein.
void SLWaitUntilVisible(SLElement *element, NSTimeInterval timeout, NSString *description, ...) {
    va_list args;
    va_start(args, description);
    NSString *formattedDescription = SLComposeStringv(@" ", description, args);
    va_end(args);
    
    // We allow the the element to be invalid upon waiting,
    // giving at most `timeout` for element resolution...
    NSTimeInterval resolutionStart = [NSDate timeIntervalSinceReferenceDate];
    SLAccessibilityPath *accessibilityPath = [element accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        [NSException raise:SLElementInvalidException
                    format:@"Element %@ did not become valid within %g seconds.%@",
                             element, timeout, formattedDescription];
    }

    NSTimeInterval resolutionEnd = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval resolutionDuration = resolutionEnd - resolutionStart;

    // ...and allowing that part of `timeout` remaining after resolution
    // for the element to become visible
    NSTimeInterval remainingTimeout = timeout - resolutionDuration;

    // we could have resolved the element right at the end of `timeout`
    if (remainingTimeout <= 0.0) {
        [NSException raise:SLElementNotVisibleException
                    format:@"Element %@ did not become visible within %g seconds.%@",
                             element, timeout, formattedDescription];
    }

    // Since we're waiting, it's possible, if unlikely, that the matching object
    // might drop out of scope between the path's construction and its examination
    __block BOOL didBecomeVisible = NO;
    __block BOOL matchingObjectWasOutOfScope = NO;
    NSDate *waitStartDate = [NSDate date];
    do {
        [accessibilityPath examineLastPathComponent:^(NSObject *lastPathComponent) {
            if (!lastPathComponent) {
                matchingObjectWasOutOfScope = YES;
                return;
            }
            didBecomeVisible = [lastPathComponent slAccessibilityIsVisible];
        }];

        if (matchingObjectWasOutOfScope) {
            [NSException raise:SLElementInvalidException
                        format:@"Element %@ became invalid before it became visible.%@",
                                 element, formattedDescription];
        }
        if (didBecomeVisible) break;

        [NSThread sleepForTimeInterval:SLElementWaitRetryDelay];
    } while ([[NSDate date] timeIntervalSinceDate:waitStartDate] < remainingTimeout);

    if (!didBecomeVisible) {
        [NSException raise:SLElementNotVisibleException
                    format:@"Element %@ did not become visible within %g seconds.%@",
                             element, timeout, formattedDescription];
    }
}

void SLWaitUntilInvisibleOrInvalid(SLElement *element, NSTimeInterval timeout, NSString *description, ...) {
    // succeed immediately if the element isn't valid
    if (![element isValid]) return;

    va_list args;
    va_start(args, description);
    NSString *formattedDescription = SLComposeStringv(@" ", description, args);
    va_end(args);

    // try repeated checks to visibility, allowing for the element to become invalid
    // (as -isVisible will match afresh each time)
    BOOL stillVisible = NO;
    NSDate *waitStartDate = [NSDate date];
    @try {
        do {
            stillVisible = [element isVisible];
            if (!stillVisible || !timeout) break;

            [NSThread sleepForTimeInterval:SLElementWaitRetryDelay];
        } while ([[NSDate date] timeIntervalSinceDate:waitStartDate] < timeout);
    }
    @catch (NSException *exception) {
        if ([[exception name] isEqualToString:SLElementInvalidException]) {
            stillVisible = NO;
        } else {
            @throw exception;
        }
    }

    if (stillVisible) {
        [NSException raise:SLElementVisibleException
                    format:@"Element %@ was still visible after %g seconds.%@",
                             element, timeout, formattedDescription];
    }
}
