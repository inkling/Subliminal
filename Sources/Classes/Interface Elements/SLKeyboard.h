//
//  SLKeyboard.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"
#import "SLButton.h"

// Instances always refer to the keyboard.  Use to check if the keyboard is visible.
// To use individual keys on the keyboard, use SLKeyboardKey.
@interface SLKeyboard : SLElement

+ (SLKeyboard *)keyboard;

@end

// Instances refer to individual keys on the keyboard.
@interface SLKeyboardKey : SLButton

@end
