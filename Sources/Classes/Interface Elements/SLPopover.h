//
//  SLPopover.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLStaticElement.h"

/**
 SLPopover provides methods for accessing and manipulating the current popover.
 */
@interface SLPopover : SLStaticElement

/**
 Returns an element representing the popover currently shown by the application, 
 if any.
 
 This element will be (valid)[-isValid] if and only if the application 
 is currently showing a popover.
 */
+ (instancetype)currentPopover;

/**
 Dismisses the specified popover by tapping outside the popover 
 and within the region defined for dismissal.
 */
- (void)dismiss;

@end
