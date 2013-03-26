//
//  SLTextFieldTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/25/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLTextFieldTest : SLIntegrationTest

@end

@implementation SLTextFieldTest {
    SLTextField *_textField;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTextFieldTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    
    _textField = [SLTextField elementWithAccessibilityLabel:@"test element"];
}

#pragma mark - SLTextField test cases

- (void)testSetText {
    NSString *const expectedText = @"foo";
    SLAssertNoThrow([UIAElement(_textField) setText:expectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText], @"Text was not set to expected value.");
}

- (void)testGetText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textField) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:@"foo"], @"Retrieved unexpected text.");
}

@end
