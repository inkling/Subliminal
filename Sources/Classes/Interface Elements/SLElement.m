//
//  SLElement.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLElement.h"
#import "UIAccessibilityElement+SLElement.h"

#import "SLTerminal.h"

#import <objc/runtime.h>


NSString *const SLElementExceptionPrefix = @"SLElement";
NSString *const SLElementAccessException = @"SLElementAccessException";
NSString *const SLElementUIAMessageSendException = @"SLElementUIAMessageSendException";

static const NSTimeInterval kDefaultRetryDelay = 0.25;


#pragma mark SLElement

@interface SLElement ()

- (id)initWithAccessibilityLabel:(NSString *)label;

- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);

@end

@interface SLElement (Subclassing)

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
    __block NSString *uiaPrefix = @"";
    @autoreleasepool {
        __block BOOL didLocateElement = NO;
        NSDate *startDate = [NSDate date];
        // note that we do _not_ increment the heartbeat timeout here
        // these searches should conclude within the default timeout
        while (!didLocateElement && [[NSDate date] timeIntervalSinceDate:startDate] < [[self class] defaultTimeout]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                // TODO: If the application's going to search all the windows,
                // we should not here assume the element's going to be found in the keyWindow.
                UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];

                UIAccessibilityElement *matchingElement = [[UIApplication sharedApplication] accessibilityElementMatchingSLElement:self];
                if (matchingElement) {
                    didLocateElement = YES;
                    // now that we've found the accessibility element, follow its containers up to the window
                    UIAccessibilityElement *containerElement = matchingElement.accessibilityContainer;
                    while (containerElement && (containerElement != (UIAccessibilityElement *)mainWindow)) {
                        NSString *previousAccessor = [NSString stringWithFormat:@".elements()[\"%@\"]", [containerElement slAccessibilityName]];
                        uiaPrefix = [previousAccessor stringByAppendingString:uiaPrefix];
                        containerElement = containerElement.accessibilityContainer;
                    }
                }
            });
            if (!didLocateElement) {
                [NSThread sleepForTimeInterval:kDefaultRetryDelay];
            }
        }
        if (!didLocateElement) {
            return nil;
        }
    }
    uiaPrefix = [@"UIATarget.localTarget().frontMostApp().mainWindow()" stringByAppendingString:uiaPrefix];
    return uiaPrefix;
}

- (NSString *)uiaSelf {
	NSString *uiaPrefix = [self uiaPrefix];
	return ([uiaPrefix length] ? [NSString stringWithFormat:@"%@.elements()[\"%@\"]",
								  [self uiaPrefix], _label] : nil);
}

- (BOOL)sendMessageReturningBool:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    BOOL response = NO;
    @try {
        NSString *uiaSelf = [self uiaSelf];
        if (![uiaSelf length]) {
            // no UIAccessibilityElement could be located. No need to talk to UIAutomation -- abort
            [NSException raise:SLElementAccessException format:@"Element %@ is not valid.", self];
        } else {
            response = [[SLTerminal sharedTerminal] sendAndReturnBool:@"%@.%@", [self uiaSelf], formattedAction];
        }
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:SLElementUIAMessageSendException reason:[exception reason] userInfo:nil];
    }
    return response;
}

- (NSString *)sendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    NSString *response = nil;
    @try {
        NSString *uiaSelf = [self uiaSelf];
        if (![uiaSelf length]) {
            // no UIAccessibilityElement could be located. No need to talk to UIAutomation -- abort
            [NSException raise:SLElementAccessException format:@"Element %@ is not valid.", self];
        } else {
            response = [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@;", [self uiaSelf], formattedAction];
        }
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:SLElementUIAMessageSendException reason:[exception reason] userInfo:nil];
    }
    return response;
}

- (BOOL)isValid {
    return [self uiaSelf] != nil;
}

- (BOOL)waitFor:(NSTimeInterval)timeout untilCondition:(NSString *)condition, ... NS_FORMAT_FUNCTION(2, 3) {
    va_list(args);
    va_start(args, condition);
    NSString *expr = [[NSString alloc] initWithFormat:condition arguments:args];
    va_end(args);
    
    BOOL conditionDidBecomeTrue =
    [[[SLTerminal sharedTerminal] evalWithFormat:@"(wait(function() { return (%@); }, %g, %g) ? \"YES\" : \"NO\");", expr, timeout, kDefaultRetryDelay] boolValue];
    
    return conditionDidBecomeTrue;
}

- (void)waitUntilVisible:(NSTimeInterval)timeout {    
    if (![self waitFor:timeout untilCondition:@"%@.isVisible()", [self uiaSelf]]) {
        [NSException raise:SLElementAccessException format:@"Element %@ did not become visible within %g seconds.", self, timeout];
    }
}

- (void)waitUntilInvisible:(NSTimeInterval)timeout {
    if (![self waitFor:timeout untilCondition:@"!%@.isVisible()", [self uiaSelf]]) {
        [NSException raise:SLElementAccessException format:@"Element %@ was still visible after %g seconds.", self, timeout];
    }
}

- (void)tap {
    (void)[self sendMessage:@"tap()"];
}

- (NSString *)value {
    // must check validity before checking value:
    // UIAutomation will not warn if this element does not exist
    if (![self isValid]) {
        [NSException raise:SLElementAccessException format:@"Element %@ is not valid.", self];
    }
    
    return [self sendMessage:@"value()"];
}

- (void)logElement {
    [[SLTerminal sharedTerminal] evalWithFormat:@"%@.logElement()", [self uiaSelf]];
}

- (void)logElementTree {
	[[SLTerminal sharedTerminal] evalWithFormat:@"%@.logElementTree()", [self uiaSelf]];
}

@end


#pragma mark - SLAlert

@implementation SLAlert

// only one alert shows at a time, and it doesn't have an accessibility label
// -- we match the title of the alert instead
- (NSString *)uiaSelf {
    return [NSString stringWithFormat:
            @"((UIATarget.localTarget().frontMostApp().alert().staticTexts()[0].label() == \"%@\") \
                            ? UIATarget.localTarget().frontMostApp().alert() : null)", self.label];
}

- (void)dismiss {
    (void)[self sendMessage:@"defaultButton().tap()"];
}

@end


#pragma mark - SLButton

@implementation SLButton
@end


#pragma mark - SLTextField

@implementation SLTextField

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    (void)[self sendMessage:@"setValue(\"%@\")", text];
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
