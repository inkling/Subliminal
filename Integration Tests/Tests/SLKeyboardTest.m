//
//  SLKeyboardTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/16/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
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
