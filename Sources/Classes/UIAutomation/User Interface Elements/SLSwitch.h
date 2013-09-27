//
//  SLSwitch.h
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLButton.h"

#define ON YES
#define OFF NO

/**
 `SLSwitch` will match against any `UIButton` object, but provides extra functionality for instances of `UISwitch`.
 
  Tappipng an `SLSwitch` will toggle it's value, which can be querried with the `on` property, or the switch may be set to a specific value.
 */
@interface SLSwitch : SLButton

/**
 The boolean value of the switch.
 */
@property (readonly,getter=isOn) BOOL on;

/**
 Sets the value of the switch, regardless of it's current value.

 @param value The boolean value to set the switch to.
*/
- (void)setValue:(BOOL)value;

@end
