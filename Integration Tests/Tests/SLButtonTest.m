//
//  SLButtonTest.m
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

#import "SLIntegrationTest.h"

@interface SLButtonTest : SLIntegrationTest

@end

@implementation SLButtonTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLButtonTestViewController";
}

- (void)testSLButtonMatchesObjectsWithButtonTrait {
    // SLButton matches UIButtons
    SLButton *button = [SLButton elementWithAccessibilityLabel:@"button"];
    SLAssertTrue([[UIAElement(button) value] isEqualToString:@"button value"],
                 @"SLButton should have matched a UIButton.");

    // but really any object (here, a plain UIView) with UIAccessibilityTraitButton
    SLButton *buttonElement = [SLButton elementWithAccessibilityLabel:@"button element"];
    SLAssertTrue([[UIAElement(buttonElement) value] isEqualToString:@"button element value"],
                 @"SLButton should have matched a UIView with UIAccessibilityButtonTrait.");
}

@end
