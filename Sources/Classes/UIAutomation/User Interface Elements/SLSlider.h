//
//  SLSlider.h
//  Subliminal
//
//  Created by Maximilian Tagher on 4/27/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>
#import "SLUIAElement+Subclassing.h"

/**
 `SLSlider` matches against instances of `UISlider`.
 
 The slider's thumb can be dragged to a specified value, and the value can be queried using `floatValue` or `value`.
 */
@interface SLSlider : SLElement

/**
  Drags the slider to the specified value.
 
 @param value The desired decimal value from 0 to 1, inclusive. A 0 value represents far left and a value of 1 represents far right.
 
 @exception NSInternalInconsistencyException if `value` is not between 0 and 1, inclusive.
 */
- (void)dragToValue:(float)value;

/**
 The current value of the slider.
 
 @return A float between 0 and 1, inclusive.
 */
- (float)floatValue;

/**
 Returns the slider's value as a percentage between 0 and 100, inclusive.
 
 @warning The returned value is between 0 and 100, whereas `dragToValue` is between 0 and 1. Use `floatValue` to get a value between 0 and 1.
 
 @return A string between 0 and 100 with a percent sign, e.g. @"100%".
 
 @exception SLUIAElementInvalidException Raised if the element is not valid
 by the end of the [default timeout](+defaultTimeout).
 */
- (NSString *)value;

@end
