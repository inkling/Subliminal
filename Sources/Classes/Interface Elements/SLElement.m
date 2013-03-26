//
//  SLElement.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLElement.h"
#import "SLLogger.h"
#import "SLAccessibility.h"
#import "SLTerminal.h"
#import "NSString+SLJavaScript.h"

#import <objc/runtime.h>


// all exceptions thrown by SLElement must have names beginning with this prefix
// so that they may be identified as "expected" throughout the testing framework
NSString *const SLElementExceptionNamePrefix    = @"SLElement";

NSString *const SLElementInvalidException       = @"SLElementInvalidException";
NSString *const SLElementNotVisibleException    = @"SLElementNotVisibleException";
NSString *const SLElementVisibleException       = @"SLElementVisibleException";

static const NSTimeInterval kDefaultRetryDelay = 0.25;
static const NSTimeInterval kWebviewTextfieldDelay = 1;


#pragma mark SLElement

@interface SLElement ()

- (id)initWithPredicate:(BOOL (^)(NSObject *obj))predicate description:(NSString *)description;
- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);
- (NSString *)staticUIASelf;

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

        [[SLTerminal sharedTerminal] evalWithFormat:@"UIATarget.localTarget().setTimeout(%g);", defaultTimeout];
    }
}

+ (NSTimeInterval)defaultTimeout {
    return (NSTimeInterval)[objc_getAssociatedObject([SLElement class], kDefaultTimeoutKey) doubleValue];
}

+ (id)elementMatching:(BOOL (^)(NSObject *obj))predicate
{
    return [[self alloc] initWithPredicate:predicate description:[predicate description]];
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

- (NSString *)staticUIASelf {
    return nil;
}

#pragma mark Sending Actions


- (void)performActionWithUIASelf:(void(^)(NSString *uiaSelf))block {

    // A uiaSelf is created, unless a staticUIASelf is provided, and is passed to the action block. uiaSelf is created
    // by creating one chain from the main window to a matching element that prefers to match on a UIView, and another
    // chain that prefers to match to UIAccessibilityElements. Unique identifiers are set on the objects in the first
    // chain, and then the elements in the second chain are serialized to create the uiaSelf which is passed to the
    // action. This ensures that the identifiers are set successfully, and that the chain does not contain any extra
    // elements. After the action has been performed the accessibilityLabels and accessibilityIdentifiers on each
    // element in the view matching chain are reset.
    
    NSString *staticUIASelf = [self staticUIASelf];
    if (staticUIASelf) {
        block(staticUIASelf);
        return;
    }
    
    NSDictionary *accessibilityChains = [self waitForAccessibilityChains];
    NSArray *uiAccessibilityElementFirstAccessorChain = accessibilityChains[SLMockViewAccessibilityChainKey];
    NSArray *viewFirstAccessorChain = accessibilityChains[SLUIViewAccessibilityChainKey];
    
    if ([uiAccessibilityElementFirstAccessorChain count] == 0) {
        @throw [NSException exceptionWithName:SLElementInvalidException reason:[NSString stringWithFormat:@"Element '%@' does not exist.", [_description slStringByEscapingForJavaScriptLiteral]] userInfo:nil];
    }

    // Previous accessibility chains and labels are stored in a separate loop, before they are reassigned. This is because
    // some subclasses' accessibility identification values depend on their parent view's, and will change when they are
    // updated.
    __block NSMutableArray *previousAccessorChainIdentifiers = [[NSMutableArray alloc] init];
    __block NSMutableArray *previousAccessorChainLabels = [[NSMutableArray alloc] init];
    __block NSMutableString *targettedUIAPrefix = [@"UIATarget.localTarget().frontMostApp().mainWindow()" mutableCopy];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (NSObject *obj in viewFirstAccessorChain) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)], @"elements in the accessibility chain must conform to UIAccessibilityIdentification");
            
            NSObject *previousIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if (previousIdentifier == nil) {
                previousIdentifier = [NSNull null];
            }
            [previousAccessorChainIdentifiers addObject:previousIdentifier];

            NSObject *previousLabel = [obj accessibilityLabel];
            if (previousLabel == nil) {
                previousLabel = [NSNull null];
            }
            [previousAccessorChainLabels addObject:previousLabel];
        }
    
        // viewFirstAccessorChain was created putting a priority on matching UIViews. We set the unique identifiers
        // on the members of this chain, instead of uiAccessibilityElementFirstAccessorChain, because the new
        // identifiers will be mirrored on all the objects in uiAccessibilityElementFirstAccessorChain
        
        // The chain's elements' accessibility information is updated in reverse order, because of the issue listed in the
        // above note
        for (NSObject *obj in [viewFirstAccessorChain reverseObjectEnumerator]) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)], @"elements in the accessibility chain must conform to UIAccessibilityIdentification");
            [obj setAccessibilityIdentifierWithStandardReplacement];

            // Some objects will not allow their accessibilityIdentifier to be modified. In these cases, if the accessibilityIdentifer
            // is empty, we can uniquely identify the object with its label.
            if ([[obj performSelector:@selector(accessibilityIdentifier)] length] == 0) {
                obj.accessibilityLabel = [obj standardAccessibilityIdentifierReplacement];
            }
        }
        
        // The prefix must be generated from the accessibility information on the elements of uiAccessibilityElementFirstAccessorChain
        // instead of viewFirstAccessorChain because uiAccessibilityElementFirstAccessorChain contains the actual elements
        // UIAutomation will interact with, and its chain may be shorter than that in viewFirstAccessorChain.
        
        for (NSObject *obj in uiAccessibilityElementFirstAccessorChain) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)], @"elements in the accessibility chain must conform to UIAccessibilityIdentification");
            
            // Elements must be identified by their accessibility identifier as long as one exists. The accessiblity identifier may be nil
            // for some classes on which you cannot set an accessibility identifer ex UISegmentedControl. In these cases the element can
            // be identified by its label.
            NSString *currentIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if ([currentIdentifier length] > 0) {
                [targettedUIAPrefix appendFormat:@".elements()['%@']",  [currentIdentifier slStringByEscapingForJavaScriptLiteral]];
                
            } else  {
                [targettedUIAPrefix appendFormat:@".elements()['%@']",  [obj.accessibilityLabel slStringByEscapingForJavaScriptLiteral]];
            }
        }
    });
        
    block(targettedUIAPrefix);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        // The chain's elements' accessibility information is updated in reverse order, because of the issue listed in the
        // above note
        [viewFirstAccessorChain enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSObject *identifierObj = [previousAccessorChainIdentifiers objectAtIndex:idx];
            NSString *identifier = ([identifierObj isEqual:[NSNull null]] ? nil : (NSString *)identifierObj);
            NSObject *labelObj = [previousAccessorChainLabels objectAtIndex:idx];
            NSString *label = ([labelObj isEqual:[NSNull null]] ? nil : (NSString *)labelObj);
            [obj resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:identifier previousLabel:label];
        }];
    });
}

// We force waitForAccessibilityChains to return a retained dictionary here to prevent the returned
// dictionary from being added to an autorelease pool on Subliminal's (non-main) thread.
- (NSDictionary *)waitForAccessibilityChains NS_RETURNS_RETAINED {
    __block NSDictionary *accessibilityChains = nil;
    NSDate *startDate = [NSDate date];
    while ([[NSDate date] timeIntervalSinceDate:startDate] < [[self class] defaultTimeout]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            accessibilityChains = [[[UIApplication sharedApplication] keyWindow] slAccessibilityChainsToElement:self];
        });
        if ([accessibilityChains[SLUIViewAccessibilityChainKey] count] > 0) {
            break;
        }
        [NSThread sleepForTimeInterval:kDefaultRetryDelay];
    }
    return accessibilityChains;
}


- (NSString *)sendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    __block NSString *returnValue = nil;
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
            returnValue = [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@", uiaSelf, formattedAction];
    }];
    
    return returnValue;
}

- (BOOL)isValid {
    return ([[self waitForAccessibilityChains][SLMockViewAccessibilityChainKey] count] > 0);
}

- (BOOL)isVisible {
    __block BOOL isVisible = NO;
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        isVisible = [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isVisible() ? 'YES' : 'NO')", uiaSelf] boolValue];
    }];
    return isVisible;
}

- (BOOL)waitFor:(NSTimeInterval)timeout untilCondition:(NSString *)condition {
    NSString *javascript = [NSString stringWithFormat:
      @"var cond = function() { return (%@); };"
      @"var timeout = %g;"
      @"var retryDelay = %g;"
      @""
      @"var startTime = Math.round(Date.now() / 1000);"
      @"var condTrue = false;"
      @"while (!(condTrue = cond()) && ((Math.round(Date.now() / 1000) - startTime) < timeout)) {"
      @"    UIATarget.localTarget().delay(retryDelay);"
      @"};"
      @"(condTrue ? 'YES' : 'NO')", condition, timeout, kDefaultRetryDelay];
    
    return [[[SLTerminal sharedTerminal] eval:javascript] boolValue];
}

- (void)waitUntilVisible:(NSTimeInterval)timeout {
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        if (![self waitFor:timeout untilCondition:[NSString stringWithFormat:@"%@.isVisible()", uiaSelf]]) {
            [NSException raise:SLElementNotVisibleException format:@"Element %@ did not become visible within %g seconds.", self, timeout];
        }
    }];
}

- (void)waitUntilInvisible:(NSTimeInterval)timeout {
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        if (![self waitFor:timeout untilCondition:[NSString stringWithFormat:@"!%@.isVisible()", uiaSelf]]) {
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
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        rectString = [[SLTerminal sharedTerminal] evalWithFormat:@"%@(%@.rect())",
                          CGRectStringFromJSRectFunctionName, uiaSelf];
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


#pragma mark - SLAlert

NSString *const SLAlertCouldNotDismissException = @"SLAlertCouldNotDismissException";

@implementation SLAlert {
    NSString *_title;
}

+ (instancetype)alertWithTitle:(NSString *)title {
    SLAlert *alert = [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        if ([obj isKindOfClass:[UIAlertView class]]) {
            UIAlertView *alert = (UIAlertView *)obj;
            return [alert.title isEqualToString:title];
        } else {
            return NO;
        }
    } description:title];
    alert->_title = title;
    return alert;
}

- (BOOL)matchesObject:(NSObject *)object {
    return [object isKindOfClass:[UIAlertView class]] && [super matchesObject:object];
}

- (void)dismiss {
    static NSString *const SLUIAAlertDismissFunctionName = @"SLUIAAlertDismiss";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *SLUIAAlertDismissFunction = @"\
            function %@(alert) {\
                var didDismissAlert = false;\
                if (alert.cancelButton().isValid()) {\
                    alert.cancelButton().tap();\
                    didDismissAlert = true;\
                } else if (alert.defaultButton().isValid()) {\
                    alert.defaultButton().tap();\
                    didDismissAlert = true;\
                }\
                return (didDismissAlert ? 'YES' : 'NO');\
            }\
        ";
        [[SLTerminal sharedTerminal] evalWithFormat:SLUIAAlertDismissFunction,
             SLUIAAlertDismissFunctionName];
    });
    
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        BOOL didDismissAlert = [[[SLTerminal sharedTerminal] evalWithFormat:@"%@(%@)",
                                 SLUIAAlertDismissFunctionName, uiaSelf] boolValue];
        if (!didDismissAlert) {
            [NSException raise:SLAlertCouldNotDismissException
                        format:@"%@ appears to have no buttons to tap.", self];
        }
    }];
}

- (void)dismissWithButtonTitled:(NSString *)buttonTitle {
    [self sendMessage:@"buttons()['%@'].tap()", [buttonTitle slStringByEscapingForJavaScriptLiteral]];
}

- (NSString *)isEqualToUIAAlertPredicate {
    static NSString *const kIsEqualToUIAAlertPredicateFormatString = @"\
        var title = \"%@\";\
        if (title.length > 0) {\
            return alert.staticTexts()[0].label() === title;\
        } else {\
            return true;\
        }\
    ";
    NSString *isEqualToUIAAlertPredicate = [NSString stringWithFormat:kIsEqualToUIAAlertPredicateFormatString,
                                            (_title ? [_title slStringByEscapingForJavaScriptLiteral] : @"")];
    return isEqualToUIAAlertPredicate;
}

@end

#pragma mark - SLControl

@implementation SLControl

- (BOOL)isEnabled {
    __block BOOL isEnabled = NO;
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        isEnabled = [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isEnabled() ? 'YES' : 'NO')", uiaSelf] boolValue];
    }];
    return isEnabled;
}

@end

#pragma mark - SLButton

@implementation SLButton

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object] && ([object accessibilityTraits] & UIAccessibilityTraitButton));
}

@end


#pragma mark - SLTextField

@implementation SLTextField

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    [self sendMessage:@"setValue('%@')", [text slStringByEscapingForJavaScriptLiteral]];
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UITextField class]];
}

@end


#pragma mark - SLSearchBar

@implementation SLSearchBar

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label {
    SLLog(@"An %@ can't be matched by accessibility properties--see the comments on its @interface. \
          Returning +anyElement.", NSStringFromClass(self));
    return [self anyElement];
}

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    SLLog(@"An %@ can't be matched by accessibility properties--see the comments on its @interface. \
          Returning +anyElement.", NSStringFromClass(self));
    return [self anyElement];
}

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object] && ([object accessibilityTraits] & UIAccessibilityTraitSearchField));
}

@end


@implementation SLWebTextField
// SLWebTextField does not inherit from SLTextField
// because the elements it matches, web text fields, are not instances of UITextField
// but rather a private type of accessibility element.

- (NSString *)text {
    return [self value];
}

// Experimentation has shown that SLTextFields within a webview must be tapped, and
// a waiting period is necessary, before setValue() will have any effect. A wait period
// after setting the value is also necessary, otherwise it seems as if regardless of
// correct matching, the next actions sent to UIAutomation will be applied incorrectly
// to this webview textfield.
- (void)setText:(NSString *)text {
    [self tap];
    [NSThread sleepForTimeInterval:kWebviewTextfieldDelay];
    [self sendMessage:@"setValue('%@')", [text slStringByEscapingForJavaScriptLiteral]];
    [NSThread sleepForTimeInterval:kWebviewTextfieldDelay];
}

@end


#pragma mark - SLWindow

@implementation SLWindow

+ (SLWindow *)mainWindow {
    return [[SLWindow alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return YES;
    } description:@"Main Window"];
}


- (NSString *)staticUIASelf {
    return @"UIATarget.localTarget().frontMostApp().mainWindow()";
}

@end

#pragma mark - SLKeyboard

@implementation SLKeyboard

+ (SLKeyboard *)keyboard {
    return [[SLKeyboard alloc] initWithPredicate:^(NSObject *obj) {
        return YES;
    } description:@"Keyboard"];
}


- (NSString *)staticUIASelf {
    return @"UIATarget.localTarget().frontMostApp().keyboard()";
}

@end

@interface SLKeyboardKey ()
@property (nonatomic, retain) NSString *keyLabel;
@end

@implementation SLKeyboardKey

+ (id)elementWithAccessibilityLabel:(NSString *)label
{
    SLKeyboardKey *key = [[SLKeyboardKey alloc] initWithPredicate:^(NSObject *obj) {
        return YES;
    } description:[NSString stringWithFormat:@"Keyboard Key: %@", label]];
    key.keyLabel = label;
    return key;
}

- (NSString *)staticUIASelf {
    return [NSString stringWithFormat:@"UIATarget.localTarget().frontMostApp().keyboard().elements()['%@']", self.keyLabel];
}

@end

#pragma mark - SLCurrentWebView

@implementation SLCurrentWebView

+ (SLCurrentWebView *)currentWebView {
    return [[SLCurrentWebView alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return [obj isKindOfClass:[UIWebView class]];
    } description:@"Current WebView"];
}

@end
