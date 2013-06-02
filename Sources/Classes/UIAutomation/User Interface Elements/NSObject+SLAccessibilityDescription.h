//
//  NSObject+SLAccessibilityDescription.h
//  Subliminal
//
//  Created by Jeffrey Wear on 6/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The methods in the `NSObject (SLAccessibilityDescription)` allow developers 
 to examine the accessibility properties of objects within their application, 
 for use in making their application accessible to disabled users and to 
 Subliminal.
 */
@interface NSObject (SLAccessibilityDescription)

/**
 Returns a string that describes the receiver in terms of its accessibility properties.

 @return A string that describes the receiver in terms of its accessibility properties.
 */
- (NSString *)slAccessibilityDescription;

/**
 Returns a string that recursively describes accessibility elements contained
 within the receiver.

 In terms of their accessibility properties, using `-slAccessibilityDescription`.

 If the receiver is a `UIView`, this also enumerates the subviews of the receiver.

 @warning This method describes all elements contained within the receiver,
 even if they [will not appear in the accessibility hierarchy](-willAppearInAccessibilityHierarchy).
 That is, the set of elements described by this method is a superset of those
 elements that will appear in the accessibility hierarchy. To log only those
 elements that will appear in the accessibility hierarchy, use `-[SLUIAElement logElementTree]`.

 @return A string that recursively describes the receiver and its accessibility children
 in terms of their accessibility properties.
 */
- (NSString *)slRecursiveAccessibilityDescription;

@end
