//
//  SLKeyboardTest.m
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

@interface SLKeyboardTest : SLIntegrationTest

@end

@implementation SLKeyboardTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLKeyboardTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(hideKeyboard);
    
    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)testCanMatchKeyboard {
	SLAskApp(showKeyboard);
    NSDictionary *keyboardInfo = SLAskApp(keyboardInfo);
    [self wait:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    CGRect expectedKeyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect actualKeyboardFrame = [UIAElement([SLKeyboard keyboard]) rect];
    SLAssertTrue(CGRectEqualToRect(expectedKeyboardFrame, actualKeyboardFrame),
                 @"The shared keyboard did not match the expected object.");
}

- (void)testTypeString {
    SLAskApp(showKeyboard);
    [self wait:[SLAskApp(keyboardInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    NSString *const kExpectedText = @"foo";
    [UIAElement([SLKeyboard keyboard]) typeString:kExpectedText];
    NSString *actualText = SLAskApp(text);
    SLAssertTrue([kExpectedText isEqualToString:actualText],
                 @"Did not type string as expected.");
}

- (void)testTapKeyboardKey {
    SLAskApp(showKeyboard);
    [self wait:[SLAskApp(keyboardInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    NSString *const kExpectedText = @"J";
    [UIAElement([SLKeyboardKey elementWithAccessibilityLabel:kExpectedText]) tap];
    NSString *actualText = SLAskApp(text);
    SLAssertTrue([kExpectedText isEqualToString:actualText],
                 @"Did not type character as expected.");
}

@end
