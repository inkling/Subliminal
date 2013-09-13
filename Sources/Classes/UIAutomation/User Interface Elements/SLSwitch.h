//
//  SLSwitch.h
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>

#define ON YES
#define OFF NO

@interface SLSwitch : SLButton

@property (readonly,getter=isOn) BOOL on;

- (void)setValue:(BOOL)value;

@end
