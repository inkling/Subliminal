//
//  SLAlert.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

/// The amount of time it takes for an alert to be fully dismissed
/// by manual and automatic alert handlers (including the alert's dismissal animation,
/// and the alert's delegate receiving the alertView:didDismissWithButtonIndex: callback),
/// as measured from the time the alert appears.
extern const NSTimeInterval SLAlertHandlerDefaultTimeout;

/// The interval that elapses between SLAlertHandler checking whether
/// a waited-for alert has shown.
extern const NSTimeInterval SLAlertHandlerWaitRetryDelay;

/// Thrown by -[SLAlertHandler waitUntilAlertHandled:] if a corresponding
/// alert was not shown before the wait timed-out.
extern NSString *const SLAlertDidNotShowException;

@class SLAlertHandler;

/**
 The SLAlert class allows access to, and control of, alerts within your application.

 Tests do not manipulate alerts directly. Rather than waiting till an alert
 appears to dismiss it, a test calls -dismiss or -dismissWithButtonTitled: 
 to retrieve an SLAlertHandler, and registers that handler with the SLAlertHandler 
 class, _before_ the alert appears. When a matching alert appears, the handler
 will dismiss the alert. The test then asks the handler to see if the alert 
 was dismissed as expected.
 
    SLAlert *alert = [SLAlert alertWithTitle:@"foo];

    // dismiss an alert with title "foo", when it appears
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];

    // test causes an alert with title "foo" to appear

    [handler waitUntilAlertHandled:SLAlertHandlerDefaultTimeout];

 If an alert is not handled by any handler, it will be automatically dismissed
 by tapping the cancel button, if the button exists, then tapping the default button,
 if one is identifiable. If the alert is still not dismissed, the tests will abort.
 */
@interface SLAlert : NSObject

/**
 Returns an alert object that matches an alert view with the specified title.

 @param title The title of the alert.
 @return A newly created alert object.
 */
+ (instancetype)alertWithTitle:(NSString *)title;

/**
 Returns a handler that dismisses a matching alert 
 using UIAutomation's default procedure.
 
 Which is to tap the cancel button, if the button exists, else tapping the 
 default button, if one is identifiable.
 
 @return A handler that dismisses the corresponding alert using 
 UIAutomation's default procedure.
 */
- (SLAlertHandler *)dismiss;

/**
 Returns a handler that dismisses a matching alert 
 by tapping the button with the specified title.

 @param buttonTitle The title of the button to tap to dismiss the alert.
 @return A handler that dismisses the corresponding alert by tapping 
 the button with the specified title.
 */
- (SLAlertHandler *)dismissWithButtonTitled:(NSString *)buttonTitle;

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
 (-[SLAlert isEqualToUIAAlertPredicate]) is given the chance to handle the alert. 
 If the handler successfully dismisses the alert, it is considered to have handled 
 the alert and is removed; otherwise, the remaining handlers are checked.
 
 If an alert is not handled by any handler, it will be automatically dismissed
 by tapping the cancel button, if the button exists, then tapping the default button,
 if one is identifiable. If the alert is still not dismissed, the tests will abort.
 
 Each handler must be added only once.

 @warning Handlers must be added _before_ the alerts they handle might appear.

 @param handler An alert handler.
 
 @exception NSInternalInconsistencyException if a handler is added multiple times.
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
