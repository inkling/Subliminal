//
//  SLElement.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLElement.h"

#import "SLAccessibility.h"
#import "SLTerminal.h"
#import "NSString+SLJavaScript.h"

#import <objc/runtime.h>


NSString *const SLInvalidElementException = @"SLInvalidElementException";

static const NSTimeInterval kDefaultRetryDelay = 0.25;


#pragma mark SLElement

@interface SLElement ()

- (id)initWithPredicate:(BOOL (^)(NSObject *obj))predicate description:(NSString *)description;

- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);
- (NSString *)uiaSelf;

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

+ (id)elementWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return [obj.slAccessibilityName isEqualToString:label];
    } description:label];
}

+ (id)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        BOOL matchesLabel = (label == nil || [obj.slAccessibilityName isEqualToString:label]);
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

#pragma mark Sending Actions

- (NSString *)uiaPrefix {
    __block NSString *uiaPrefix = nil;
    
    // Attempt the find the element the same way UIAutomation does (including the 5 second timeout)
    NSDate *startDate = [NSDate date];
    while ([[NSDate date] timeIntervalSinceDate:startDate] < [[self class] defaultTimeout]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            uiaPrefix = [self currentUIAPrefix];
        });
        if (uiaPrefix) {
            break;
        }
        [NSThread sleepForTimeInterval:kDefaultRetryDelay];
    }

    return uiaPrefix;
}

- (NSString *)uiaSelf {
	NSString *uiaPrefix = [self uiaPrefix];
    
    if (!uiaPrefix) {
        @throw [NSException exceptionWithName:SLInvalidElementException reason:[NSString stringWithFormat:@"Element '%@' does not exist.", [_description slStringByEscapingForJavaScriptLiteral]] userInfo:nil];
    } else {
        return uiaPrefix;
    }
}

- (NSString *)sendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    return [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@", [self uiaSelf], formattedAction];
}

- (BOOL)isValid {
    return [self uiaPrefix] != nil;
}

- (BOOL)isVisible {
    return [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isVisible() ? 'YES' : 'NO')", [self uiaSelf]] boolValue];
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
    if (![self waitFor:timeout untilCondition:[NSString stringWithFormat:@"%@.isVisible()", [self uiaSelf]]]) {
        [NSException raise:@"SLWaitUntilVisibleException" format:@"Element %@ did not become visible within %g seconds.", self, timeout];
    }
}

- (void)waitUntilInvisible:(NSTimeInterval)timeout {
    if (![self waitFor:timeout untilCondition:[NSString stringWithFormat:@"!%@.isVisible()", [self uiaSelf]]]) {
        [NSException raise:@"SLWaitUntilInvisibleException" format:@"Element %@ was still visible after %g seconds.", self, timeout];
    }
}

- (void)tap {
    [self sendMessage:@"tap()"];
}

- (NSString *)value {
    return [self sendMessage:@"value()"];
}

- (void)logElement {
    [self sendMessage:@"logElement()"];
}

- (void)logElementTree {
    [self sendMessage:@"logElementTree()"];
}

- (BOOL)matchesObject:(NSObject *)object
{
    return _matchesObject(object);
}

@end

@implementation SLElement (Debugging)

- (NSString *)currentUIAPrefix {
    // TODO: If the application's going to search all the windows,
    // we should not here assume the element's going to be found in the keyWindow.
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

    NSMutableString *uiaPrefix;
    NSArray *accessorChain = [keyWindow slAccessibilityChainToElement:self];
    if (accessorChain) {
        uiaPrefix = [@"UIATarget.localTarget().frontMostApp().mainWindow()" mutableCopy];

        // Skip the window element
        for (int i = 1; i < [accessorChain count]; i++) {
            // Some objects (in particular instances of several internal UIKit classes) refuse to respect the setting of accessibilityLabel, accessibilityIdentifier, etc.
            // In these cases we can't get a non-nil slAccessibilityName despite our best efforts.  If we get back a nil accessibility name then we should just skip this
            // element in the chain.  We have found by experiment that skipping these troublesome elements usually results in a chain that the automation instrument
            // can interpret successfully.
            NSString *accessibilityName = [[accessorChain[i] slAccessibilityName] slStringByEscapingForJavaScriptLiteral];
            if ([accessibilityName length] > 0) {
                [uiaPrefix appendFormat:@".elements()['%@']", accessibilityName];
            }
        }
    }

    return uiaPrefix;
}

@end


#pragma mark - SLAlert

@implementation SLAlert

// only one alert shows at a time, and it doesn't have an accessibility label
// -- we match the title of the alert instead
- (NSString *)uiaSelf {
    return [NSString stringWithFormat:
            @"((UIATarget.localTarget().frontMostApp().alert().staticTexts()[0].label() == \"%@\") \
                            ? UIATarget.localTarget().frontMostApp().alert() : null)", [_description slStringByEscapingForJavaScriptLiteral]];
}

- (void)dismiss {
    [self sendMessage:@"defaultButton().tap()"];
}

- (void)dismissWithButtonTitled:(NSString *)buttonTitle {
    [self sendMessage:@"buttons()['%@'].tap()", [buttonTitle slStringByEscapingForJavaScriptLiteral]];
}

@end

#pragma mark - SLControl

@implementation SLControl

- (BOOL)isEnabled {
    return [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isEnabled() ? 'YES' : 'NO')", [self uiaSelf]] boolValue];
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

@end

#pragma mark - SLWindow

@implementation SLWindow

+ (SLWindow *)mainWindow {
    return [[SLWindow alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return YES;
    } description:@"Main Window"];
}

- (NSString *)uiaSelf {
	return @"UIATarget.localTarget().frontMostApp().mainWindow()";
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
