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
 SLDatePicker elements represent instances of UIDatePicker, which aren't subclassed
 from UIPickerView. This object gives access to viewing and manipulating the individual
 components (or as UIA calls them 'wheels') of the Picker. UIA represents the controls
 in almost the exact same way, so we treat it as a subclass of SLPickerView.

 The only difference is that the UIDatePicker element shows up in the accessibility
 hierarchy as a UIAElement rather than a UIAPicker. The UIAPicker is actually a child
 element, which is backed by a UIView object with no accessibility information on it.
 Ideally, we'd match on the UIView within the UIDatePicker, but that seems harder to 
 make work given the existing infrastructure.

 If this control is the inputView for a text field, it will be contained within the
 'UITextEffectsWindow' window rather than the keyWindow. In this case, set
 isPickerForTextInputView to YES.
  */
@interface SLDatePicker : SLPickerView

@end
