//
//  SLElement.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIAccessibilityConstants.h>
#import <QuartzCore/QuartzCore.h>


#pragma mark - SLElement

// all exceptions thrown by SLElement will have names beginning with this prefix
extern NSString *const SLElementExceptionNamePrefix;

extern NSString *const SLElementInvalidException;
extern NSString *const SLElementNotVisibleException;
extern NSString *const SLElementVisibleException;

extern const NSTimeInterval SLElementWaitRetryDelay;

@interface SLElement : NSObject

// Defaults - to be set by the test controller
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout;

// Returns an element for an NSObject in the accessibility hierarchy that matches predicate.
+ (id)elementMatching:(BOOL (^)(NSObject *obj))predicate;

/**
 Returns an element which matches any object in the accessibility hierarchy.

 SLElement defines this constructor primarily for the benefit of subclasses
 that match a certain kind of object by default, such that a match is likely 
 unique even without the developer specifying additional information. For instance, 
 if your application only has one webview onscreen at a time, you could match
 that webview (using SLWebView) by matching "any" webview, without having to 
 give that webview an accessibility label or identifier.

 @return An element which matches any object in the accessibility hierarchy.
 */
+ (instancetype)anyElement;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName.
+ (id)elementWithAccessibilityLabel:(NSString *)label;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName, accessibilityValue, and matching the traits accessibilityTraits mask.
// If label is nil the condition on slAccessibilityName is ignored.
// If value is nil the condition on accessibilityValue is ignored.
+ (id)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

// If the UIAccessibilityElement corresponding to the receiver does not exist, isValid will return NO.
// All other methods below will throw an SLInvalidElementException.
- (BOOL)isValid;
- (BOOL)isVisible;
- (void)waitUntilVisible:(NSTimeInterval)timeout;
- (void)waitUntilInvisibleOrInvalid:(NSTimeInterval)timeout;

- (void)tap;

// Triggers the JavaScript call dragInsideWithOptions, passing the start and end points in floating point format.
// This causes the automation JavaScript system to interpret the points in the normalized coordinates of the target
// SLElement's view.  That is, a start or end point of {0.5, 0.5} is interpretted to be at the center of the target
// element's view.
//
// Uses a drag duration of 1.0 seconds because this is the documented default duration for touch-and-hold gestures
// according to Apple's UIAElement class reference.
- (void)dragWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (NSString *)value;

/**
 Returns the position of the object on the main screen.

 The relevant coordinates are screen-relative
 and are adjusted to account for device orientation.

 This is the same value as is returned by -[NSObject accessibilityFrame], 
 for the object which matches this element.
 
 @return The frame of the accessibility element, in screen coordinates.
 */
- (CGRect)rect;

- (void)logElement;
- (void)logElementTree;

/** Returns YES if the instance of SLElement should 'match' object, no otherwise.

  Subclasses of SLElement can override this method to provide custom matching behavior.
  Default implementation returns [object.slAccessibilityName isEqualToString:self.label].

  @param object The object to which the instance of SLElement should be compared.
  @return a BOOL indicating whether or not the instance of SLElement matches object.
  */
- (BOOL)matchesObject:(NSObject *)object;

@end

#pragma mark - SLElement Subclasses

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

@interface SLControl : SLElement
- (BOOL)isEnabled;
@end

// SLButton will match any object, and only objects, with the UIAccessibilityTraitButton accessibility trait.
@interface SLButton : SLControl
@end

/**
 SLTextField allows access to, and control of, text field elements in your app. 
 */
@interface SLTextField : SLElement

/** The text displayed by the text field. */
@property (nonatomic, strong) NSString *text;

@end

/**
 SLSearchBarTextField allows access to, and control of, search bar elements in your app.
  
 @warning For reasons out of Subliminal's control, it is not possible to match 
 accessibility properties on search bars. Search bars can only be matched 
 using +anyElement.

 (The text field inside a UISearchBar is the accessible element, not the
 search bar itself. This means that the accessibility properties of the search bar 
 don't matter--and unfortunately, you can't set accessibility properties on the 
 text field because it's private.)
 */
@interface SLSearchBar : SLTextField
@end

/**
 SLWebTextField matches text fields displayed in UIWebViews.
 
 Such as form inputs.
 
 A web text field's value is its text (i.e. the value of a form input's "value" 
 attribute). A web text field's label is the text of an element specified by the 
 "aria-labelled-by" attribute, if present. See SLWebTextField.html and the 
 SLWebTextField test cases of SLTextFieldTest.
 */
@interface SLWebTextField : SLElement

/** The text displayed by the text field. */
@property (nonatomic, strong) NSString *text;

@end

// Instances always refer to mainWindow()
@interface SLWindow : SLElement
+ (SLWindow *)mainWindow;
@end

// Instances always refer to the keyboard.  Use to check if the keyboard is visible.
// To use individual keys on the keyboard, use SLKeyboardKey.
@interface SLKeyboard : SLElement
+ (SLWindow *)keyboard;
@end

// Instances refer to individual keys on the keyboard.
@interface SLKeyboardKey : SLButton
@end

// Instances refer to the first instance of (a kind of) UIWebView that appears in the view hierarchy.
@interface SLCurrentWebView : SLElement
@end
