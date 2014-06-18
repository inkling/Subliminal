//
//  SLDatePicker.h
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

#import "SLPickerView.h"

/**
 SLDatePicker elements represent instances of UIDatePicker. This object gives access
 to viewing and manipulating the individual components (or as UIA calls them 'wheels')
 of the Picker.
 */
@interface SLDatePicker : SLElement

/**
 Fetches the number of components from UIA.
 
 @return The actual number of components visible on the screen
 
 @exception SLUIAElementInvalidException Raised if the there is no UIPickerView on or
 above the keyWindow.
 */
- (NSUInteger)numberOfComponentsInPickerView;

/**
 Runs a script that gets the value of each individual component and returns it as an
 array of strings.
 
 @return An array of strings containing the value for each wheel component. The string
 values are of the format "%@ (%d of %d)", where the first portion is current selected
 wheel's value, and the two numbers represent the current selected element row and the
 total number of rows.
 
 @exception SLUIAElementInvalidException Raised if the there is no UIPickerView on or
 above the keyWindow.
 */
- (NSArray *)valueOfPickerComponents;

/**
 Changes the selected value of a given component to a specified value on the wheel.
 
 @param title The title to make selected by spinning the picker.
 @param componentIndex The index for which to reference the values.
 
 @exception SLUIAElementInvalidException Raised if the _title_ doesn't exist within the
 picker wheel at _componentIndex_ before [default timeout](+[SLUIAElement defaultTimeout]).
 
 @exception SLUIAElementAutomationException Raised if the _title_ doesn't exist within
 the picker wheel at _componentIndex_.
 */
- (void)selectValue:(NSString *)title forComponent:(NSUInteger)componentIndex;

@end
