//
//  SLAlert.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLAlert.h"
#import "SLTerminal.h"
#import "SLTerminal+ConvenienceMethods.h"
#import "NSString+SLJavaScript.h"

NSString *const SLAlertDidNotShowException = @"SLAlertDidNotShowException";

const NSTimeInterval SLAlertHandlerWaitRetryDelay = 0.25;
const NSTimeInterval SLAlertHandlerDefaultTimeout = 1.5;

#pragma mark - SLAlertHandler

@interface SLAlertHandler ()

/**
 Returns a value unique to this handler, for use in identifying
 it among the handlers registered.

 @return A value that uniquely identifies this handler.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 Returns a UIAAlert handler modeled after UIAutomation's default onAlert handler.

 @return A UIAAlert handler (suitable to initialize an SLAlertHandler) 
 which taps the alert's cancel button, if the button exists, else taps the 
 default button, if one is identifiable.
 */
+ (NSString *)defaultUIAAlertHandler;

/**
 Initializes and returns a newly allocated handler for the specified alert.
 
 @param alert The alert to handle.
 @param UIAAlertHandler The logic to execute to handle alert. This should be the 
 body of a JS function--one or more statements, with no function closure--taking 
 one argument, "alert" (a UIAAlert) as argument, and returning true if the alert 
 was successfully dismissed, false otherwise.
 @return An initialized handler.
 */
- (instancetype)initWithSLAlert:(SLAlert *)alert
             andUIAAlertHandler:(NSString *)UIAAlertHandler;

@end

@implementation SLAlertHandler {
    SLAlert *_alert;
    NSString *_UIAAlertHandler;

    BOOL _hasBeenAdded;
}

+ (void)loadUIAAlertHandling {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // The onAlert handler returns true for an alert
        // iff the tests handle and dismiss that alert.
        // SLAlertHandler manipulates onAlert via _alertHandlers.
        [[SLTerminal sharedTerminal] eval:@"\
            var _alertHandlers = [];\
            UIATarget.onAlert = function(alert) {"
                // enumerate registered handlers, from first to last
                @"for (var handlerIndex = 0; handlerIndex < _alertHandlers.length; handlerIndex++) {\
                    var handler = _alertHandlers[handlerIndex];"
                    // if a handler matches the alert, remove it and return true
                    @"if (handler.handleAlert(alert) === true) {\
                        _alertHandlers.splice(handlerIndex, 1);\
                        return true;\
                    }\
                }\
                "
                // the tests haven't handled this alert, so UIAutomation should dismiss it
                @"return false;\
            }\
         "];
    });
}

+ (void)addHandler:(SLAlertHandler *)handler {
    // We don't use NSParameterAssert here because if it failed
    // it'd leak the implementation (in the form of this condition) to the client
    if (handler->_hasBeenAdded) {
        [NSException raise:NSInternalInconsistencyException format:@"Handler for alert %@ must not be added twice.", handler->_alert];
    }

    NSString *alertHandler = [NSString stringWithFormat:@"{\
                                  id: \"%@\",\
                                  handleAlert: function(alert){ %@ }\
                              }",
                              [[handler identifier] slStringByEscapingForJavaScriptLiteral], [handler JSHandler]];
    [[SLTerminal sharedTerminal] evalWithFormat:@"_alertHandlers.push(%@);", alertHandler];
    handler->_hasBeenAdded = YES;
}

+ (NSString *)defaultUIAAlertHandler {
    return @"\
        var didDismissAlert = false;\
        if (alert.cancelButton().isValid()) {\
            alert.cancelButton().tap();\
            didDismissAlert = true;\
        } else if (alert.defaultButton().isValid()) {\
            alert.defaultButton().tap();\
            didDismissAlert = true;\
        }\
        return didDismissAlert;\
    ";
}

- (instancetype)initWithSLAlert:(SLAlert *)alert
             andUIAAlertHandler:(NSString *)UIAAlertHandler {
    self = [super init];
    if (self) {
        _alert = alert;
        _UIAAlertHandler = UIAAlertHandler;
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%p", self];
}

- (NSString *)JSHandler {
    return [NSString stringWithFormat:@"\
                var shouldHandleAlert = (function(alert){%@})(alert);\
                if (shouldHandleAlert) {\
                    return (function(alert){%@})(alert);\
                } else {\
                    return false;\
                }\
        ", [_alert isEqualToUIAAlertPredicate], _UIAAlertHandler];
}

- (NSString *)didHandleAlertJS {
    return [NSString stringWithFormat:@"\
                (function(){"
                    // we've handled an alert unless we find ourselves still registered
                    @"var haveHandledAlert = true;"
                    // enumerate registered handlers, from first to last
                    @"for (var handlerIndex = 0; handlerIndex < _alertHandlers.length; handlerIndex++) {\
                        var handler = _alertHandlers[handlerIndex];\
                        if (handler.id === \"%@\") {\
                            haveHandledAlert = false;\
                            break;\
                        }\
                    };\
                    return haveHandledAlert;\
                }())\
            ", [self.identifier slStringByEscapingForJavaScriptLiteral]];
}

- (BOOL)didHandleAlert {
    if (!_hasBeenAdded) {
        [NSException raise:NSInternalInconsistencyException format:@"Handler for alert %@ must be added using +[SLAlertHandler addHandler:] before it can handle an alert.", _alert];
    }
    
    NSString *didHandleAlertJS = [NSString stringWithFormat:@"(%@ ? 'YES' : 'NO')", [self didHandleAlertJS]];
    return [[[SLTerminal sharedTerminal] eval:didHandleAlertJS] boolValue];
}

- (void)waitUntilAlertHandled:(NSTimeInterval)timeout {
    if (!_hasBeenAdded) {
        [NSException raise:NSInternalInconsistencyException format:@"Handler for alert %@ must be added using +[SLAlertHandler addHandler:] before it can handle an alert.", _alert];
    }

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    BOOL didHandleAlert = [[SLTerminal sharedTerminal] waitUntilTrue:[self didHandleAlertJS]
                                                          retryDelay:SLAlertHandlerWaitRetryDelay
                                                             timeout:timeout];
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // ensure we don't return until at least SLAlertHandlerDefaultTimeout has elapsed
    // (see note on `timeout` in method documentation)
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    if (waitTimeInterval < SLAlertHandlerDefaultTimeout) {
        [NSThread sleepForTimeInterval:(SLAlertHandlerDefaultTimeout - waitTimeInterval)];
    }

    if (!didHandleAlert) {
        [NSException raise:SLAlertDidNotShowException format:@"%@ did not show within %g seconds.", _alert, timeout];
    }
}

@end


#pragma mark - SLAlert

@implementation SLAlert {
    NSString *_title;
}

+ (instancetype)alertWithTitle:(NSString *)title {
    NSParameterAssert([title length]);
    
    SLAlert *alert = [[SLAlert alloc] init];
    alert->_title = title;
    return alert;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ title:\"%@\">", NSStringFromClass([self class]), _title];
}

- (SLAlertHandler *)dismiss {
    return [[SLAlertHandler alloc] initWithSLAlert:self andUIAAlertHandler:[SLAlertHandler defaultUIAAlertHandler]];
}

- (SLAlertHandler *)dismissWithButtonTitled:(NSString *)buttonTitle {
    NSString *UIAAlertHandler = [NSString stringWithFormat:@"\
                                     var button = alert.buttons()['%@'];\
                                     if (button.isValid()) {\
                                        button.tap();\
                                        return true;\
                                     } else {\
                                        return false;\
                                     }\
                                 ", [buttonTitle slStringByEscapingForJavaScriptLiteral]];
    return [[SLAlertHandler alloc] initWithSLAlert:self andUIAAlertHandler:UIAAlertHandler];
}

- (NSString *)isEqualToUIAAlertPredicate {
    static NSString *const kIsEqualToUIAAlertPredicateFormatString = @"\
        return alert.staticTexts()[0].label() === \"%@\";\
    ";
    NSString *isEqualToUIAAlertPredicate = [NSString stringWithFormat:kIsEqualToUIAAlertPredicateFormatString,
                                            [_title slStringByEscapingForJavaScriptLiteral]];
    return isEqualToUIAAlertPredicate;
}

@end
