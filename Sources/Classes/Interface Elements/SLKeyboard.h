//
//  SLKeyboard.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLStaticElement.h"
#import "SLButton.h"

/**
 The SLKeyboard allows you to test whether your application's keyboard 
 is visible, and type strings.

 To tap individual keys on the keyboard, use SLKeyboardKey.
 */
@interface SLKeyboard : SLStaticElement

/**
 Returns an element representing the application's keyboard.
 
 @return An element representing the application's keyboard.
 */
+ (SLKeyboard *)keyboard;

@end


/**
 Instances of SLKeyboardKey refer to individual keys on the application's keyboard.
 */
@interface SLKeyboardKey : SLStaticElement

/**
 Creates and returns an element which represents the keyboard key with the specified label.
 
 This is the designated initializer for a keyboard key.

 @param label The key's accessibility label.
 @return A newly created element representing the keyboard key with the specified label.
 */
+ (instancetype)elementWithAccessibilityLabel:(NSString *)label;

@end
