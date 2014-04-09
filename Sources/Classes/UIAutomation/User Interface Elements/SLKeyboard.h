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
 The iOS 7 SDK exposes the UIInputView class which allows the creation of
 custom keyboards and other input views.
 https://developer.apple.com/library/iOS/documentation/UIKit/Reference/UIInputView_class/Reference/Reference.html
 
 The SLKeyboard protocol declares a standard way to interact with these custom
 keyboards, such as -typeString:, where classes implementing the protocol define
 any logic required to enter a string via their accosiated custom UIInputView
 */

@protocol SLKeyboard <NSObject>

/**
 Returns an element representing the application's keyboard.
 
 @return An element representing the application's keyboard.
 */
+ (instancetype)keyboard;

/**
 Taps the keys of the specified keyboard as required
 to generate the specified string.
 
 This string may contain characters that do not appear on the keyboard
 in the keyboard's current state--the keyboard will change keyplanes
 as necessary to make the corresponding keys visible.

 @param string The string to be typed on the keyboard.

 @bug This method throws an exception if string contains any characters
 that can be accessed only through a tap-hold gesture, for example
 “smart-quotes.”  Note that SLTextField, SLTextView, and related classes
 work around this bug internally when their text contents are set with
 the -setText: method.
 */
- (void)typeString:(NSString *)string;

@optional
/**
 Tap the keyboard's "Hide Keyboard" button to hide the keyboard without 
 executing any done/submit actions
 */
- (void)hide;

/**
 Uses -[SLKeyboard typeString:] to tap the keys of the input string on the
 receiver.  Unlike -[SLKeyboard typeString:], this method will not throw an
 exception if the input string contains characters that can be accessed on
 the receiver only through a tap-hold gesture.  Instead, this method will
 send the setValue JavaScript message to the input element as a "fallback"
 procedure.
 
 @param string The string to be typed on the keyboard or set as the value for
 element.
 @param element The user interface element on which the setValue JavaScript
 method will be called if the internal call to -[SLKeyboard typeString:]
 throws an exception.
 */
- (void)typeString:(NSString *)string withSetValueFallbackUsingElement:(SLUIAElement *)element;

@end

/**
 The SLKeyboard allows you to test whether your application's keyboard
 is visible, and type strings.

 To tap individual keys on the keyboard, use SLKeyboardKey.
 */
@interface SLKeyboard : SLStaticElement <SLKeyboard>

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
