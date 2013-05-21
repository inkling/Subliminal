//
//  SLUIAElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


// all exceptions thrown by SLUIAElement will have names beginning with this prefix
extern NSString *const SLUIAElementExceptionNamePrefix;

extern NSString *const SLUIAElementInvalidException;
extern NSString *const SLUIAElementNotTappableException;

extern const NSTimeInterval SLUIAElementWaitRetryDelay;

/// Represents an invalid CGPoint.
extern const CGPoint SLCGPointNull;

/// Returns YES if `point` is the null point, NO otherwise.
extern BOOL SLCGPointIsNull(CGPoint point);


/**
 SLUIAElement is an abstract class that defines an interface to 
 access and manipulate a user interface element within your application.
 SLUIAElement's concrete subclass SLElement handles the specifics of matching 
 particular elements.
 */
@interface SLUIAElement : NSObject

// Defaults - to be set by the test controller
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout;
+ (NSTimeInterval)defaultTimeout;

// If the UIAccessibilityElement corresponding to the receiver does not exist, isValid will return NO.
// All other methods below will throw an SLInvalidElementException.
- (BOOL)isValid;

/**
 Determines whether the specified element is visible on the screen.

 @return YES if the user interface element represented by the specified element 
 is visible onscreen, NO otherwise.
 @exception SLUIAElementInvalidException if the element is not valid. For this 
 reason, developers are encouraged to use -isValidAndVisible and 
 -isInvalidOrInvisible with SLAssertTrueWithTimeout, rather than this method.
 */
- (BOOL)isVisible;

/**
 Determines whether the specified element is valid, and if so, 
 if it is visible on the screen.
 
 Unlike -isVisible, this method will not throw an SLUIAElementInvalidException 
 if the element is not valid--it will just return NO. This allows test writers
 to wait for an element to appear without having to worry about whether the element
 is valid at the start of the wait.

 @return YES if the element is both valid and visible, NO otherwise.
 */
- (BOOL)isValidAndVisible;

/**
 Determines whether the specified element is invalid or, if it is valid, 
 if it is invisible.
 
 Unlike -isVisible, this method will not throw an SLUIAElementInvalidException 
 if the element is not valid--it will just return NO. This allows test writers 
 to wait for an element to disappear without having to worry about whether 
 the element will become invisible or simply invalid.
 
 @return YES if the element is invalid or invisible, NO otherwise.
 */
- (BOOL)isInvalidOrInvisible;

/**
 Determines whether the specified element is enabled.
 
 The matching object appears to define what "enabled" means. 
 When the matching object is an instance of UIControl, this appears to evaluate
 to -[UIControl isEnabled]. It otherwise appears to evaluate to YES.

 @return YES if the specified element is enabled, NO otherwise.
 */
- (BOOL)isEnabled;

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
