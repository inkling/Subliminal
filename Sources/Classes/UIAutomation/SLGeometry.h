//
//  SLGeometry.h
//  Subliminal
//
//  Created by Maximilian Tagher on 7/2/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Creating a JavaScript Primitive from a Struct Primitive
/// ----------------------------------------------------------------------
/// @name Creating a JavaScript Primitive from a Struct Primitive
/// ----------------------------------------------------------------------

/**
 Converts a `CGRect` to a string of JavaScript that evaluates to an equivalent
 `Rect` object, as described in
 http://developer.apple.com/library/ios/#documentation/ToolsLanguages/Reference/UIATargetClassReference/UIATargetClass/UIATargetClass.html
 
 @param rect A non-null `CGRect`.
 @return JavaScript which evaluates to a `Rect` object equivalent to _rect_.

 @exception NSInternalInconsistencyException if `rect` is `CGRectNull`.
 */
NSString *SLUIARectFromCGRect(CGRect rect);

#pragma mark - Creating a Struct Primitive from a JavaScript Primitive
/// ----------------------------------------------------------------------
/// @name Creating a Struct Primitive from a JavaScript Primitive
/// ----------------------------------------------------------------------

/**
 Converts a string of JavaScript (that evaluates to a `Rect` object) to a `CGRect`.
 
 @param rect JavaScript which evaluates to a `Rect` object, e.g.
 `UIATarget.localTarget().frontMostApp().mainWindow().rect()`.
 @return A `CGRect`, or `CGRectNull` if _rect_ was `nil`.
 */
CGRect SLCGRectFromUIARect(NSString *rect);

#pragma mark - Comparing Values
/// ------------------------------------------
/// @name Comparing Values
/// ------------------------------------------

/**
 Returns the name of a JavaScript function used to evaluate whether two `Rect`
 objects are equal in size and position., loading it into the terminal's namespace
 if necessary.

 This function accepts two parameters, _rect1_ and _rect2_, both `Rect` objects.
 It returns `true` if _rect1_ and _rect2_ have equal size and origin values, or
 if both rectangles are `null`; otherwise, `false`.

 @return The name of the JavaScript function used to evaluate whether two `Rect`
 objects are equal in size and position.
 */
NSString *SLUIARectEqualToRectFunctionName();

#pragma mark - Checking for Membership
/// ------------------------------------------
/// @name Checking for Membership
/// ------------------------------------------

/**
 Returns the name of a JavaScript function used to evaluate whether a `Rect`
 contains another `Rect`, loading it into the terminal's namespace if necessary.
 
 This function accepts two parameters, _rect1_ and _rect2_, both `Rect` objects.
 It returns `true` if the rectangle specified by _rect2_ is contained in the
 rectangle passed in _rect1_; otherwise, `false`. The first rectangle contains
 the second if the union of the two rectangles is equal to the first rectangle.

 @return The name of the JavaScript function used to evaluate whether a `Rect`
 contains another `Rect`.
 */
NSString *SLUIARectContainsRectFunctionName();
