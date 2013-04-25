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


// all exceptions thrown by SLElement must have names beginning with this prefix
// so that they may be identified as "expected" throughout the testing framework
NSString *const SLElementExceptionNamePrefix    = @"SLElement";

NSString *const SLElementInvalidException       = @"SLElementInvalidException";
NSString *const SLElementNotVisibleException    = @"SLElementNotVisibleException";
NSString *const SLElementVisibleException       = @"SLElementVisibleException";

const NSTimeInterval SLElementWaitRetryDelay = 0.25;


#pragma mark SLElement

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

- (void)performActionWithUIARepresentation:(void(^)(NSString *uiaRepresentation))block {
    [self performActionWithUIARepresentation:block timeout:[[self class] defaultTimeout]];
}

- (void)performActionWithUIARepresentation:(void(^)(NSString *uiaRepresentation))block timeout:(NSTimeInterval)timeout {

    // A uiaRepresentation is created, unless a staticUIARepresentation is provided, and is passed to the action block.
    
    NSString *staticUIARepresentation = [self staticUIARepresentation];
    if (staticUIARepresentation) {
        block(staticUIARepresentation);
        return;
    }
    
    SLAccessibilityPath *accessibilityPath = [self accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        @throw [NSException exceptionWithName:SLElementInvalidException reason:[NSString stringWithFormat:@"Element '%@' does not exist.", [_description slStringByEscapingForJavaScriptLiteral]] userInfo:nil];
    }

    // It's possible, if unlikely, that one or more path components could have dropped
    // out of scope between the path's construction and its binding/serialization
    // here. If the representation is invalid, UIAutomation will throw an exception,
    // and it will be caught by Subliminal.
    [accessibilityPath bindPath:^(SLAccessibilityPath *boundPath) {
        block([boundPath UIARepresentation]);
    }];
}

- (SLAccessibilityPath *)accessibilityPathWithTimeout:(NSTimeInterval)timeout {
    __block SLAccessibilityPath *accessibilityPath = nil;
    NSDate *startDate = [NSDate date];
    do {
        dispatch_sync(dispatch_get_main_queue(), ^{
            accessibilityPath = [[[UIApplication sharedApplication] keyWindow] slAccessibilityPathToElement:self];
        });
        if (accessibilityPath) break;
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

- (NSString *)sendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    __block NSString *returnValue = nil;
    [self performActionWithUIARepresentation:^(NSString *uiaRepresentation) {
            returnValue = [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@", uiaRepresentation, formattedAction];
    }];
    
    return returnValue;
}

- (BOOL)isValid {
    // isValid evaluates the current state, no waiting to resolve the element
    return ([self accessibilityPathWithTimeout:0.0] != nil);
}

/*
 Subliminal's implementation of -isVisible does not rely upon UIAutomation,
 because UIAElement.isVisible() has a number of bugs. However, Subliminal
 maintains parity with UIAutomation in all cases.
 See SLElementVisibilityTest for more information.
 */
- (BOOL)isVisible {
    __block BOOL isVisible = NO;
    // isVisible evaluates the current state, no waiting to resolve the element
    [self examineMatchingObject:^(NSObject *object) {
        isVisible = [object slAccessibilityIsVisible];
    } timeout:0.0];
    return isVisible;
}

- (void)waitUntilVisible:(NSTimeInterval)timeout {
    // We allow for the the element to be invalid upon waiting,
    // so long as it is ultimately visible, and we don't want to wait more
    // or less than `timeout`--so we provide `performActionWithUIARepresentation:`
    // at most `timeout` for element resolution...
    
    NSTimeInterval resolutionStart = [NSDate timeIntervalSinceReferenceDate];
    [self performActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSTimeInterval resolutionEnd = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval resolutionDuration = resolutionEnd - resolutionStart;

        // ...and wait for only that part of `timeout` remaining after resolution
        // for the element to become visible
        NSTimeInterval remainingTimeout = timeout - resolutionDuration;

        // `performActionWithUIARepresentation:` could have found the element
        // right at the end of timeout
        if (remainingTimeout <= 0.0) {
            [NSException raise:SLElementNotVisibleException
                        format:@"Element %@ did not become visible within %g seconds.",
                                self, timeout];
        }

        NSString *isVisible = [NSString stringWithFormat:@"%@.isVisible()", uiaRepresentation];
        if (![[SLTerminal sharedTerminal] waitUntilTrue:isVisible
                                             retryDelay:SLElementWaitRetryDelay
                                                timeout:remainingTimeout]) {
            [NSException raise:SLElementNotVisibleException
                        format:@"Element %@ did not become visible within %g seconds.",
                                self, timeout];
        }
    } timeout:timeout];
}

- (void)waitUntilInvisibleOrInvalid:(NSTimeInterval)timeout {
    // succeed immediately if we're not valid (otherwise performAction... will throw)
    if (![self isValid]) return;

    [self performActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        // The method lists "invisible" before "invalid" because the element not being visible
        // is what the user really cares about.
        // But we check validity first in case isVisible() might throw.
        // (It doesn't--it returns NO, given an invalid element--but this is safest
        // (and matches Subliminal's semantics).)
        NSString *isInvalidOrInvisible = [NSString stringWithFormat:@"!%@.isValid() || !%@.isVisible()", uiaRepresentation, uiaRepresentation];
        if (![[SLTerminal sharedTerminal] waitUntilTrue:isInvalidOrInvisible
                                             retryDelay:SLElementWaitRetryDelay
                                                timeout:timeout]) {
            [NSException raise:SLElementVisibleException format:@"Element %@ was still visible after %g seconds.", self, timeout];
        }
    }];
}

- (void)tap {
    [self sendMessage:@"tap()"];
}

- (void)dragWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [self sendMessage:@"dragInsideWithOptions({startOffset:{x:%f, y:%f}, endOffset:{x:%f, y:%f}, duration:1.0})", startPoint.x, startPoint.y, endPoint.x, endPoint.y];
}

- (NSString *)value {
    return [self sendMessage:@"value()"];
}

- (CGRect)rect {
    static NSString *const CGRectStringFromJSRectFunctionName = @"SLCGRectStringFromJSRect";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *CGRectStringFromJSRectFunction = @"\
            function %@(rect) {\
                return '{{' + rect.origin.x + ',' + rect.origin.y + '},{'\
                            + rect.size.width + ',' + rect.size.height + '}}';\
            }\
        ";
        [[SLTerminal sharedTerminal] evalWithFormat:CGRectStringFromJSRectFunction,
             CGRectStringFromJSRectFunctionName];
    });

    NSString *__block rectString = nil;
    [self performActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        rectString = [[SLTerminal sharedTerminal] evalWithFormat:@"%@(%@.rect())",
                          CGRectStringFromJSRectFunctionName, uiaRepresentation];
    }];
    return ([rectString length] ? CGRectFromString(rectString) : CGRectNull);
}

- (void)logElement {
    [self sendMessage:@"logElement()"];
}

- (void)logElementTree {
    [self sendMessage:@"logElementTree()"];
}

- (BOOL)matchesObject:(NSObject *)object
{
    NSAssert(_matchesObject, @"matchesObject called on %@, which has no _matchesObject predicate", self);
    return _matchesObject(object);
}

@end
