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

/** A string Subliminal will use to reference this element when communicating with UIAutomation.
 
 The name is considered to be the object's accessibilityIdentifier if available, 
 otherwise the object's accessibilityLabel (otherwise, if the object is a UIButton, 
 the button's title).
 
 If none of the above are available, an identifier will be created and assigned to the object.
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

