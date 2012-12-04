//
//  SLAccessibility.h
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLElement;


@interface NSObject (SLAccessibility)

/** A string Subliminal will use to reference this element in UIAutomation.
 
 The default implementation returns the object's accessibility label. Subclasses of UIView and UIAccessibilityElement return the object's accessibility identifier or accessibility label or creates an accessibility identifier if both are `nil`. UIButton's return the accessibility identifier or the button's title is the identifier is `nil`.
 */
@property (nonatomic, readonly) NSString *slAccessibilityName;

/** Returns an array of objects that are child accessibility elements of this object.
 
 This method is mostly a wrapper around the UIAccessibilityContainer protocol but also includes subviews if the object is a UIView. It attempts to represent the accessibilty hierarchy used by the system.
 
 @return An array of objects that are child accessibility elements of this object.
 */
- (NSArray *)slChildAccessibilityElements;

/** Returns a chain of objects that can used by UIAutomation to access the element.
 
 The array starts at index 0 with this object and ends with the target element.
 
 @param element The element whose label to find.
 @return A chain of objects that can used by UIAutomation to access the element or `nil` if the element is not found within this object's accessibility hierarchy.
 */
- (NSArray *)slAccessibilityChainToElement:(SLElement *)element;

/// ----------------------------------------
/// @name Debug methods
/// ----------------------------------------
- (NSString *)slAccessibilityDescription;
- (NSString *)slRecursiveAccessibilityDescription;

@end


@interface UIAccessibilityElement (SLAccessibility)
@end


@interface UIView (SLAccessibility)
@end


@interface UIButton (SLAccessibility)
@end

