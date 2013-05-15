//
//  SLElement.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#pragma mark - SLElement

// all exceptions thrown by SLElement will have names beginning with this prefix
extern NSString *const SLElementExceptionNamePrefix;

extern NSString *const SLElementInvalidException;
extern NSString *const SLElementNotTappableException;
extern NSString *const SLElementNotVisibleException;
extern NSString *const SLElementVisibleException;

extern const NSTimeInterval SLElementWaitRetryDelay;

/// Represents an invalid CGPoint.
extern const CGPoint SLCGPointNull;

/// Returns YES if `point` is the null point, NO otherwise.
extern BOOL SLCGPointIsNull(CGPoint point);


@interface SLElement : NSObject

// Defaults - to be set by the test controller
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout;
+ (NSTimeInterval)defaultTimeout;

/**
 Creates and returns an element that evaluates the accessibility hierarchy
 using a specified block object.
 
 @param predicate The block is applied to the object to be evaluated.
 The block returns YES if the element matches the object, otherwise NO.
 @param description An optional description of the element, for use in debugging.
 (The other SLElement constructors derive element descriptions from their arguments.)
 @return A new element that evaluates objects using predicate.
 */
+ (id)elementMatching:(BOOL (^)(NSObject *obj))predicate withDescription:(NSString *)description;

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

/**
 Determines whether the specified element is visible on the screen.
 
 @return YES if the user interface element represented by the specified element 
 is visible onscreen, NO otherwise.
 */
- (BOOL)isVisible;

/**
 Determines whether it is possible to interact with the specified element.

 @return YES if it is possible to tap on or otherwise interact with the element, 
 NO otherwise.
 */
- (BOOL)isTappable;

/**
 Taps the specified element.
 
 The tap occurs at the element's [hitpoint](-hitpoint).
 
 This method requires that the element be [tappable](-isTappable), and will wait 
 for it to become so, for the amount of time remaining (of SLElement's 
 [default timeout](+defaultTimeout)) after the element becomes valid.
 
 @exception SLJavaScriptException if the element is not [tappable](-isTappable).
 */
- (void)tap;

/**
 Triggers the JavaScript call dragInsideWithOptions with the specified 
 start and end points.
 
 This method passes the start and end points in floating point format.
 This causes UIAutomation to interpret the points in the normalized coordinates 
 of the specified element's view.  That is, a start or end point of {0.5, 0.5}
 is interpreted to be at the center of the target element's view.

 This method uses a drag duration of 1.0 seconds because this is the documented 
 default duration for touch-and-hold gestures according to Apple's UIAElement 
 class reference.
 
 This method requires that the element be [tappable](-isTappable), and will wait
 for it to become so, for the amount of time remaining (of SLElement's
 [default timeout](+defaultTimeout)) after the element becomes valid.

 @param startPoint The start point for the drag.
 @param endPoint The end point for the drag.

 @exception SLJavaScriptException if the element is not [tappable](-isTappable).
 */
- (void)dragWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 Returns the element's label attribute.
 
 This wraps UIAElement.label(), which returns the [accessibility label](-[NSObject accessibilityLabel]) 
 of the matching object.
 */
- (NSString *)label;

- (NSString *)value;

/**
 Returns the screen position to tap for the element.
 
 This is the midpoint of the element's -rect, unless that point cannot be tapped, 
 in which case this method returns an alternate point, if possible.
 
 @return The position to tap for the element, in screen coordinates,
 or SLCGPointNull if a hitpoint cannot be determined.
 */
- (CGPoint)hitpoint;

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

@end


extern void SLWaitUntilVisible(SLElement *element, NSTimeInterval timeout, NSString *description, ...);
extern void SLWaitUntilInvisibleOrInvalid(SLElement *element, NSTimeInterval timeout, NSString *description, ...);
