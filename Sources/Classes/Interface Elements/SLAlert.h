//
//  SLAlert.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>


/// The amount of time it generally takes for an alert to be fully dismissed
/// by a manual or automatic alert handler (including the alert's dismissal animation,
/// and the alert's delegate receiving the alertView:didDismissWithButtonIndex: callback),
/// as measured from the time the alert appears.
///
/// This timeout should suffice to dismiss alerts of all alertViewStyles
/// (using handlers which simply dismiss the alerts, as well as those that enter text).
extern const NSTimeInterval SLAlertHandlerDefaultTimeout;

/// The interval that elapses between SLAlertHandler checking whether
/// a waited-for alert has shown.
extern const NSTimeInterval SLAlertHandlerWaitRetryDelay;

/// Thrown by -[SLAlertHandler waitUntilAlertHandled:] if a corresponding
/// alert was not shown before the wait timed-out.
extern NSString *const SLAlertDidNotShowException;

/// Types of textfields contained by UIAlertViews, as determined by the
/// alert view's alertViewStyle.
typedef NS_ENUM(NSInteger, SLAlertTextFieldType) {
    SLAlertTextFieldTypeSecureText  = UIAlertViewStyleSecureTextInput,
    SLAlertTextFieldTypePlainText   = UIAlertViewStylePlainTextInput,
    SLAlertTextFieldTypeLogin       = UIAlertViewStyleLoginAndPasswordInput,
    SLAlertTextFieldTypePassword // = UIAlertViewStyleLoginAndPasswordInput
};


@class SLAlertHandler, SLAlertDismissHandler;

/**
 The SLAlert class allows access to, and control of, alerts within your application.

 Alerts do not need to be handled by the tests. If they are not handled,
 they will be automatically dismissed (by tapping the cancel button,
 if the button exists, then tapping the default button, if one is identifiable).

 A test may optionally specify an alternate handler for an alert, by constructing
 an SLAlertHandler from the SLAlert that matches that alert, and registering that 
 handler with the SLAlertHandler class. When a matching alert appears, the handler 
 dismisses the alert. The test then asks the handler to see if the alert was 
 dismissed as expected.
 
    SLAlert *alert = [SLAlert alertWithTitle:@"foo];

    // dismiss an alert with title "foo", when it appears
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];

    // test causes an alert with title "foo" to appear

    [handler waitUntilAlertHandled:SLAlertHandlerDefaultTimeout];

 @warning If a test wishes to manually handle an alert, it must register 
 a handler _before_ that alert appears.

 @warning If the alert has no cancel nor default button, it will not be able
 to be dismissed by any handler, and the tests will hang. (If the tests are being 
 run via the command line, Instruments will eventually time out; if the tests are 
 being run via the GUI, the developer will need to stop the tests.)

 */
@interface SLAlert : NSObject

/**
 Returns an alert object that matches an alert view with the specified title.

 @param title The title of the alert.
 @return A newly created alert object.
 */
+ (instancetype)alertWithTitle:(NSString *)title;

/**
 Returns a handler that dismisses a matching alert using the default 
 handling behavior.
 
 Which is to tap the cancel button, if the button exists, else tapping the 
 default button, if one is identifiable.
 
 @warning If the alert has no cancel nor default button, it will not be able
 to be dismissed and the tests will hang. (If the tests are being run via the command
 line, Instruments will eventually time out; if the tests are being run via the
 GUI, the developer can abort.)

 @return A handler that dismisses the corresponding alert using 
 UIAutomation's default procedure.
 */
- (SLAlertDismissHandler *)dismiss;

/**
 Returns a handler that dismisses a matching alert 
 by tapping the button with the specified title.

 @param buttonTitle The title of the button to tap to dismiss the alert.
 @return A handler that dismisses the corresponding alert by tapping 
 the button with the specified title.
 */
- (SLAlertDismissHandler *)dismissWithButtonTitled:(NSString *)buttonTitle;

/**
 Returns a handler that sets the text 
 of the specified text field of a matching alert.
 
 @param fieldType The type of text field, corresponding to the alert's 
 presentation style.
 @param text The text to enter into the field.
 */
- (SLAlertHandler *)setText:(NSString *)text ofFieldOfType:(SLAlertTextFieldType)fieldType;

@end


/**
 SLAlert's dismiss methods vend SLAlertHandlers to dismiss corresponding alerts 
 when they appear, and report the status of dismissal to the tests.
 */
@interface SLAlertHandler : NSObject

/**
 Allows tests to manually handle particular alerts.

 Tests can add multiple handlers at one time; when an alert is shown,
 they are checked in order of addition, and the first one that [matches the alert]
 (-[SLAlert isEqualToUIAAlertPredicate]) is given the chance to handle (dismiss) 
 the alert. If the handler succeeds, it is removed; otherwise, the remaining 
 handlers are checked.

 If an alert is not handled by any handler, it will be automatically dismissed
 by tapping the cancel button, if the button exists, then tapping the default button,
 if one is identifiable. If the alert is still not dismissed, the tests will hang.
 
 Each handler must be added only once.

 @warning Handlers must be added _before_ the alerts they handle might appear.
 
 @param handler An alert handler.
 
 @exception NSInternalInconsistencyException if a handler is added multiple times.
 @exception NSInternalInconsistencyException If the handler will not ultimately
 try to dismiss a corresponding alert: handler must either be an SLAlertDismissHandler, 
 or must be a handler produced using -andThen: where the last "chained" handler 
 is an SLAlertDismissHandler.
 */
+ (void)addHandler:(SLAlertHandler *)handler;

/**
 Returns YES if the receiver has dismissed an alert, NO otherwise.
 
 @return YES if the receiver has dismissed an alert, NO otherwise.
 
 @exception NSInternalInconsistencyException If the receiver has not been added.

 @see +addHandler:
 */
- (BOOL)didHandleAlert;

/**
 Waits for the specified timeout for the receiver to handle an alert.

 @param timeout The interval to wait for a corresponding alert to be shown.
 SLAlertHandlerDefaultTimeout is a reasonable default.
 
 This method will only wait timeout for the alert to be shown--but will not return 
 until an interval at least as long as SLAlertHandlerDefaultTimeout has elapsed, 
 to ensure that the alert's delegate has received the dismissal callbacks 
 before the tests proceed.
 
 @exception NSInternalInconsistencyException If the receiver has not been added.
 @exception SLAlertDidNotShowException If the receiver has not handled an alert
 at the end of timeout.
 
 @see +addHandler:
 */
- (void)waitUntilAlertHandled:(NSTimeInterval)timeout;

/**
 Creates and returns an alert handler which handles a corresponding alert 
 by performing the action of the receiver and then that of the specified handler.
 
 This method allows alert handlers to be "chained", so that (for instance) 
 text can be entered into an alert's text field, and then the alert dismissed:
 
     SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
 
     SLAlertHandler *setUsername = [alert setText:@"user" ofFieldOfType:SLAlertTextFieldTypeLogin];
     SLAlertHandler *setPassword = [alert setText:@"password" ofFieldOfType:SLAlertTextFieldTypePassword];
     SLAlertHandler *dismiss = [alert dismissWithButtonTitled:@"Ok"];
     SLAlertHandler *alertHandler = [[setUsername andThen:setPassword] andThen:dismiss];
 
     [SLAlertHandler addHandler:alertHandler];

 @param nextHandler A handler whose action should be performed after the action 
 of the receiver.
 @return A newly created alert handler that performs the action of the receiver 
 and then the action of nextHandler.
 */
- (SLAlertHandler *)andThen:(SLAlertHandler *)nextHandler;

@end


/**
 The methods in the SLAlert (Subclassing) category are to be used only by
 subclasses of SLAlert.
 */
@interface SLAlert (Subclassing)

/**
 Returns the body of a JS function which
 evaluates a UIAAlert to see if it matches the receiver.

 The JS function will take one argument, "alert" (a UIAAlert), as argument,
 and should return true if alert is equivalent to the receiver, false otherwise.
 This method should return the _body_ of that function: one or more statements,
 with no function closure.

 The default implementation simply compares the titles of the receiving SLAlert
 and provided UIAAlert.

 @return The body of a JS function which evaluates a UIAAlert "alert"
 to see if it matches a particular SLAlert.
 */
- (NSString *)isEqualToUIAAlertPredicate;

@end

/**
 SLAlertDismissHandler is a class used solely to distinguish handlers 
 that try to dismiss alerts from those that do not.
 
 @see +[SLAlertHandler addHandler:]
 */
@interface SLAlertDismissHandler : SLAlertHandler
@end


/**
 The methods in the SLAlert (Internal) category are to be used only within 
 Subliminal.
 */
@interface SLAlertHandler (Internal)

/**
 Loads Subliminal's alert-handling mechanism into UIAutomation.
 
 SLAlertHandler is not fully functional until this method is called.
 
 This method is to be called by the test controller on startup.
 */
+ (void)loadUIAAlertHandling;

@end
