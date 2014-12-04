//
//  SLActionSheet.h
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

#import "SLStaticElement.h"

/**
 SLActionSheet provides methods for accessing and manipulating the current action sheet.
 */
@interface SLActionSheet : SLStaticElement

/**
 Returns an element representing the action sheet currently shown by the application,
 if any.

 This element will be (valid)[-isValid] if and only if the application
 is currently showing a action sheet.
 */
+ (instancetype)currentActionSheet;

/**
 Dismisses the specified action sheet by tapping outside the action sheet
 and within the region defined for dismissal.

 This method will block until the action sheet has been fully dismissed.
 */
- (void)dismiss;

/**
 Dismisses the specified action sheet by clicking on the button with the specified label.

 This method will block until the action sheet has been fully dismissed.
 */
- (void)clickButtonWithAccessibilityLabel:(NSString *)label;

@end
