//
//  NSObject+SLVisibility.h
//  Subliminal
//
//  Created by Jeffrey Wear on 6/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The methods in the `NSObject (SLVisibility)` category allow Subliminal 
 to determine if an object is visible on the screen.
 */
@interface NSObject (SLVisibility)

/**
 Determines if the specified object is visible on the screen.

 @return YES if the receiver is visible within the accessibility hierarchy,
 NO otherwise.
 */
- (BOOL)slAccessibilityIsVisible;

@end
