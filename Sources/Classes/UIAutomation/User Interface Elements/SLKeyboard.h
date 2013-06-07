//
//  SLKeyboard.h
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

/**
 Taps the keys of the specified keyboard as required 
 to generate the specified string.
 
 @param string The string to be typed on the keyboard.
 */
- (void)typeString:(NSString *)string;

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
