//
//  SLTextFieldTest.m
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
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"aName"];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"rectOnly" inRect:CGRectMake(100, 100, -100, -100)];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"rectOnly" inRect:CGRectMake(0, 0, 100, 100)];
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
