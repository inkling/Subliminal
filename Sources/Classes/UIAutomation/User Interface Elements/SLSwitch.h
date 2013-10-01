//
//  SLSwitch.h
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLButton.h"

/**
 `SLSwitch` matches against instances of `UISwitch`
 
  Tappipng an `SLSwitch` will toggle its value, which can be queried with the `on` property, or the switch may be set to a specific value.
 */
@interface SLSwitch : SLButton

/**
 The boolean value of the switch.
 
 `setOn:` will set the value of the switch regardless of the current state, as opposed to tapping which will toggle it.
 */
@property (nonatomic, getter=isOn) BOOL on;

@end
