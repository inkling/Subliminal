//
//  SLPickerView.h
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import "SLElement.h"

/**
 SLPickerView elements represent instances of UIPickerView.

 If it is the inputView for a text field, set isPickerForTextInputView to YES and it will
 be contained looked for in the 'UITextEffectsWindow' window rather than the keyWindow.

 This object gives access to viewing and manipulating the individual components (or as UIA
 calls them 'wheels') of the Picker.
 */
@interface SLPickerView : SLElement

/**
 Calls the equivalent of 'wheels().length' on the picker in UIA. This will return
 the number of components (or wheels as UIA calls them) in the picker.

 @return The actual number of components visible on the screen
 */
- (int)numberOfComponentsInPickerView;

/**
 Runs a script that gets the value of each individual component and returns it as an
 array of strings.

 @return An array of strings containing the output of value() for each wheel component.
 The string values are of the format "%@ (%d of %d)", where the first portion is current
 selected wheel's value, and the two numbers represent the current selected element row
 and the total number of rows.
 */
- (NSArray *)valueOfPickerComponents;

/**
 Changes the selected value of a given component to a specified value on the wheel. If
 invalid values are passed, an exception will be thrown. This is done by the equivalent
 UIA script 'wheels()[&lt;componentIndex&gt;].selectValue(&quot;&lt;title&gt;&quot;)'
 on the picker.

 @param title The title to make selected by spinning the picker.
 @param componentIndex The index for which to reference the values.
 */
- (void)selectValue:(NSString *)title forComponent:(int)componentIndex;

/**
 If the UIPickerView is set as the inputView for a UITextField, it will appear in a
 different window that the regular keyWindow. This boolean flag determines which
 window should be used to find the element.

 Potentially, this should be moved up to SLElement, because any view could be hosted
 as the inputView for a UITextField element.
 */
@property BOOL isPickerForTextInputView;

@end
