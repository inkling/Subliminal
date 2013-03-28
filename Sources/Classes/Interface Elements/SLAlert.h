//
//  SLAlert.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"

extern NSString *const SLAlertCouldNotDismissException;

/**
 The SLAlert class allows access to, and control of, alerts within your application.

 @warning By default, UIAlertViews do not have an accessibility label. You should
 use the +alertWithTitle: or +anyElement constructors.
 @warning By default, alerts are automatically dismissed immediately after showing.
 To interact with alerts, tests can override the default handler either
 [globally](-[SLTestController setAutomaticallyDismissAlerts:])or on a
 [per-alert basis](-[SLTestController pushHandlerForAlert:]).
 */
@interface SLAlert : SLElement

/**
 Returns an element that matches an alert with the specified title.

 @param title The title of the alert.
 */
+ (instancetype)alertWithTitle:(NSString *)title;

/**
 Dismisses the alert by tapping the cancel button, if the button exists,
 else tapping the default button, if one is identifiable.

 @exception SLAlertCouldNotDismissException If the alert has no buttons.
 */
- (void)dismiss;

/**
 Dismisses the alert by tapping the button with the specified name.

 @param buttonTitle The title of the button to tap to dismiss the alert.
 */
- (void)dismissWithButtonTitled:(NSString *)buttonTitle;

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
