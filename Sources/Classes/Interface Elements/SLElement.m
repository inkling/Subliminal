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

- (id)initWithAccessibilityLabel:(NSString *)label;

- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);
- (NSString *)uiaSelf;

@end


@implementation SLElement

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

+ (id)elementWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithAccessibilityLabel:label];
}

- (id)initWithAccessibilityLabel:(NSString *)label {
    self = [super init];
    if (self) {
        _label = label;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label:\"%@\">", NSStringFromClass([self class]), _label];
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
        @throw [NSException exceptionWithName:SLInvalidElementException reason:[NSString stringWithFormat:@"Element '%@' does not exist.", [_label slStringByEscapingForJavaScriptLiteral]] userInfo:nil];
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
            [uiaPrefix appendFormat:@".elements()['%@']", [[accessorChain[i] slAccessibilityName] slStringByEscapingForJavaScriptLiteral]];
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
                            ? UIATarget.localTarget().frontMostApp().alert() : null)", [self.label slStringByEscapingForJavaScriptLiteral]];
}

- (void)dismiss {
    [self sendMessage:@"defaultButton().tap()"];
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
    return [[SLWindow alloc] initWithAccessibilityLabel:nil];
}

- (NSString *)uiaSelf {
	return @"UIATarget.localTarget().frontMostApp().mainWindow()";
}

@end

#pragma mark - SLCurrentWebView

@implementation SLCurrentWebView

- (BOOL)matchesObject:(NSObject *)object
{
    return [object isKindOfClass:[UIWebView class]];
}

@end
