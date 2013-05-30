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
    // _textField is id-typed so that it can represent SLTextFields
    // and SLWebTextFields
    id _textField;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTextFieldTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];

    if (testSelector == @selector(testSetText) ||
        testSelector == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        testSelector == @selector(testGetText)) {
        _textField = [SLTextField elementWithAccessibilityLabel:@"test element"];
    } else if (testSelector == @selector(testMatchesSearchBarTextField) ||
               testSelector == @selector(testSetSearchBarText) ||
               testSelector == @selector(testGetSearchBarText)) {
        _textField = [SLSearchField anyElement];
    } else if (testSelector == @selector(testMatchesWebTextField) ||
               testSelector == @selector(testSetWebTextFieldText) ||
               testSelector == @selector(testGetWebTextFieldText)) {
        _textField = [SLWebTextField elementWithAccessibilityLabel:@"Test"];
        SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0, @"Webview did not load test HTML.");
    }
}

#pragma mark - SLTextField test cases

- (void)testSetText {
    NSString *const expectedText = @"foo";
    SLAssertNoThrow([UIAElement(_textField) setText:expectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText], @"Text was not set to expected value.");
}

- (void)testSetTextWhenFieldClearsOnBeginEditing {
    NSString *const expectedText = @"foo";
    SLAssertNoThrow([UIAElement(_textField) setText:expectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText], @"Text was not set to expected value.");
}

- (void)testGetText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textField) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:@"foo"], @"Retrieved unexpected text: %@.", text);
}

#pragma mark - SLSearchField test cases

- (void)testMatchesSearchBarTextField {
    SLAssertTrue([UIAElement(_textField) isValid], @"Search bar should be valid.");
    SLAssertTrue([[UIAElement(_textField) text] isEqualToString:@"bar"], @"Did not match expected element.");
}

- (void)testSetSearchBarText {
    NSString *const expectedText = @"bar";
    SLAssertNoThrow([UIAElement(_textField) setText:expectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText], @"Text was not set to expected value.");
}

- (void)testGetSearchBarText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textField) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:@"bar"], @"Retrieved unexpected text: %@.", text);
}

#pragma mark - SLWebTextField test cases

- (void)testMatchesWebTextField {
    SLAssertTrue([UIAElement(_textField) isValid], @"Web text field should be valid.");
    SLAssertTrue([[UIAElement(_textField) text] isEqualToString:@"baz"], @"Did not match expected element.");
}

- (void)testSetWebTextFieldText {
    NSString *const expectedText = @"baz";
    SLAssertNoThrow([UIAElement(_textField) setText:expectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText], @"Text was not set to expected value.");
}

- (void)testGetWebTextFieldText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textField) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:@"baz"], @"Retrieved unexpected text: %@.", text);
}

@end
