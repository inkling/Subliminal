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
 SLPickerView elements represent instances of UIPickerView. This object gives access
 to viewing and manipulating the individual components (or as UIA calls them 'wheels') 
 of the Picker.
 
 To manipulate a date picker control, use UIDatePicker as it isn't a direct subclass
 of UIPickerView.
 */
@interface SLPickerView : SLElement

/**
 Fetches the number of components from UIA.

 @return The actual number of components visible on the screen
 */
- (NSUInteger)numberOfComponentsInPickerView;

/**
 Runs a script that gets the value of each individual component and returns it as an
 array of strings.

 @return An array of strings containing the value for each wheel component. The string
 values are of the format "%@ (%d of %d)", where the first portion is current selected
 wheel's value, and the two numbers represent the current selected element row and the
 total number of rows.
 */
- (NSArray *)valueOfPickerComponents;

/**
 Changes the selected value of a given component to a specified value on the wheel. If
 invalid values are passed, an exception will be thrown.

 @param title The title to make selected by spinning the picker.
 @param componentIndex The index for which to reference the values.
 */
- (void)selectValue:(NSString *)title forComponent:(NSUInteger)componentIndex;

@end
