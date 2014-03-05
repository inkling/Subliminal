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
                 @"Did not type string as expected: '%@' (expected) vs. '%@' (actual).", kExpectedText, actualText);
}

- (void)testTypeStringChangesKeyplanesAsNecessary {
    SLAskApp(showKeyboard);
    [self wait:[SLAskApp(keyboardInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];

    NSString *specialCharacter = @">";
    SLKeyboardKey *specialCharacterKey = [SLKeyboardKey elementWithAccessibilityLabel:specialCharacter];
    SLAssertFalse([UIAElement(specialCharacterKey) isValidAndVisible],
                  @"For the purposes of this test case, the keyboard should not currently be showing this key.");

    NSString *const kExpectedText = @"Foo'Bar_123>Baz<Buz";
    // Just to make the test consistent.
    SLAssertTrue([kExpectedText rangeOfString:specialCharacter].location != NSNotFound,
                 @"For the purposes of this test case, the string to be typed\
                 must contain a special character not visible before typing.");

    SLAssertNoThrow([UIAElement([SLKeyboard keyboard]) typeString:kExpectedText],
                    @"The keyboard was not able to type a string containing a special character\
                    (not visible before typing).");
    NSString *actualText = SLAskApp(text);
    SLAssertTrue([kExpectedText isEqualToString:actualText],
                 @"Did not type string as expected: '%@' (expected) vs. '%@' (actual).", kExpectedText, actualText);
}

- (void)testTapKeyboardKey {
    SLAskApp(showKeyboard);

    // On iOS 7 on Travis, tapping this key does not register sometimes,
    // so we use a longer delay than the notification would suggest (see the other cases)
    // to try to make sure that the key will be fully visible and tappable.
    [self wait:0.5];

    NSString *const kExpectedText = @"J";
    [UIAElement([SLKeyboardKey elementWithAccessibilityLabel:kExpectedText]) tap];
    NSString *actualText = SLAskApp(text);
    SLAssertTrue([kExpectedText isEqualToString:actualText],
                 @"Did not type character as expected: '%@' (expected) vs. '%@' (actual).", kExpectedText, actualText);
}

- (void)testHideKeyboard_iPad {
    SLAskApp(showKeyboard);
    [self wait:[SLAskApp(keyboardInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    [[SLKeyboard keyboard] hide];
    [self wait:[SLAskApp(keyboardInfo)[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    SLAssertTrueWithTimeout([[SLKeyboard keyboard] isValid] == NO, 2.0 , @"Keyboard should not be valid.");
}

@end
