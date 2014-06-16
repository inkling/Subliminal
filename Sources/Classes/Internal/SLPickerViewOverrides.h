//
//  SLPickerView+Internal.h
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
 Allows PickerView behavior to be overriden to enable supporting both the
 UIPickerView and the UIDatePicker objects. 
 
 This needed to be implemented as a protocol instead of as a class extension, 
 because otherwise they were appearing in the appledoc despite not being a
 published header and being in the ignore list.
 */
@protocol SLPickerViewOverrides

/**
 Determines which Class should be matched in SLElement -matchesObject

 @return Class object representing the type of class to match on
 */
- (Class)classToMatchOn;

/**
 Specifies the JS path to find the wheels underneath the UIElement that is
 matched on. For DatePicker's, there is a UIView contained within it that
 represents the real picker object, but it doesn't retain the accessibility
 identifiers.

 @return A string representing the UIA path to the picker wheels
 */
- (NSString *)wheelsObjectPathInUIA;

@end
