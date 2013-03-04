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


@interface SLElement : NSObject

// Defaults - to be set by the test controller, from the testing thread.
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
- (void)waitUntilInvisible:(NSTimeInterval)timeout;

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

/**
 The SLAlert class allows access to, and control of, alerts within your application.
 
 @warning By default, UIAlertViews do not have an accessibility label. You should 
 use the +alertWithTitle: or +anyElement constructors.
 @warning If [[SLTestController sharedTestController] automaticallyDismissAlerts]
 is YES, alerts will be dismissed as soon as they are shown, with no opportunity 
 to examine or otherwise manipulate them.
 */
@interface SLAlert : SLElement

/**
 Returns an element that matches an alert with the specified title.
 
 @param title The title of the alert.
 */
+ (instancetype)alertWithTitle:(NSString *)title;

- (void)dismiss;

- (void)dismissWithButtonTitled:(NSString *)buttonTitle;

@end

@interface SLControl : SLElement
- (BOOL)isEnabled;
@end

// SLButton will match any object, and only objects, with the UIAccessibilityTraitButton accessibility trait.
@interface SLButton : SLControl
@end

@interface SLTextField : SLElement
@property (nonatomic, strong) NSString *text;
@end

/**
 SLSearchBar will match any object, and only objects, with the UIAccessibilityTraitSearchField 
 accessibility trait.
 
 @warning By default, the text field inside a UISearchBar is the accessible element, 
 not the search bar itself. You should not attempt to set and match accessibility 
 properties of the search bar itself, but rather match the search text field by its 
 accessibility value (its text), or use the +anyElement constructor.
 */
@interface SLSearchBar : SLTextField
@end

// SLWebTextField should be used to match any textfields displayed in UIWebviews.
// It is necessary to match these objects with SLWebTextField instead of SLTextField
// in order to be able to set the element's value successfully.
@interface SLWebTextField : SLTextField
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
