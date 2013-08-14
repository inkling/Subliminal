//
//  SLTextViewTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 7/29/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLTextViewTest : SLIntegrationTest

@end

@implementation SLTextViewTest {
    // `_textView` is id-typed so that it can represent `SLTextViews`
    // and `SLWebTextViews`
    id _textView;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTextViewTestViewController";
}

static NSString *const kExpectedText = @"foo";
- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if ((testCaseSelector == @selector(testSetText)) ||
        (testCaseSelector == @selector(testSetTextClearsCurrentText)) ||
        (testCaseSelector == @selector(testGetText)) ||
        (testCaseSelector == @selector(testDoNotMatchEditorAccessibilityObjects))) {
        _textView = [SLTextView elementWithAccessibilityLabel:@"test element"];
    } else if ((testCaseSelector == @selector(testMatchesWebTextView)) ||
               (testCaseSelector == @selector(testSetWebTextViewText)) ||
               (testCaseSelector == @selector(testSetWebTextViewTextClearsCurrentText)) ||
               (testCaseSelector == @selector(testGetWebTextViewText))) {
        _textView = [SLWebTextView elementWithAccessibilityLabel:@"test element"];
        SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0, @"Webview did not load test HTML.");
    }

    if ((testCaseSelector == @selector(testGetText)) ||
        (testCaseSelector == @selector(testDoNotMatchEditorAccessibilityObjects)) ||
        (testCaseSelector == @selector(testMatchesWebTextView)) ||
        (testCaseSelector == @selector(testGetWebTextViewText))) {
        SLAskApp1(setText:, kExpectedText);
    }
}

- (void)testSetText {
    SLAssertNoThrow([UIAElement(_textView) setText:kExpectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:kExpectedText], @"Text was not set to expected value.");
}

- (void)testSetTextClearsCurrentText {
    NSString *const expectedText1 = @"foo";
    SLAssertNoThrow([UIAElement(_textView) setText:expectedText1], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText1], @"Text was not set to expected value.");

    NSString *const expectedText2 = @"bar";
    SLAssertNoThrow([UIAElement(_textView) setText:expectedText2], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText2], @"Text was not set to expected value.");
}

- (void)testGetText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textView) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:kExpectedText], @"Retrieved unexpected text: %@.", text);
}

// An internal test. See `-[NSObject (SLAccessibility_Internal) accessibilityAncestorPreventsPresenceInAccessibilityHierarchy]`.
- (void)testDoNotMatchEditorAccessibilityObjects {
    SLAssertFalse([SLAskApp(text) isEqualToString:@""],
                  @"For the purposes of this test case, the text view must have some initial value.");

    SLElement *textElement = [SLElement elementWithAccessibilityLabel:kExpectedText];
    SLAssertFalse([UIAElement(textElement) isValid], @"Should not have matched internal text object.");
}

#pragma mark - SLWebTextField test cases

- (void)testMatchesWebTextView {
    SLAssertTrue([UIAElement(_textView) isValid], @"Web text view should be valid.");
    SLAssertTrue([[UIAElement(_textView) text] isEqualToString:kExpectedText], @"Did not match expected element.");
}

- (void)testSetWebTextViewText {
    SLAssertNoThrow([UIAElement(_textView) setText:kExpectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:kExpectedText], @"Text was not set to expected value.");
}

- (void)testSetWebTextViewTextClearsCurrentText {
    NSString *const expectedText1 = @"foo";
    SLAssertNoThrow([UIAElement(_textView) setText:expectedText1], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText1], @"Text was not set to expected value.");

    NSString *const expectedText2 = @"bar";
    SLAssertNoThrow([UIAElement(_textView) setText:expectedText2], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:expectedText2], @"Text was not set to expected value.");
}

- (void)testGetWebTextViewText {
    NSString *text;
    SLAssertNoThrow(text = [UIAElement(_textView) text], @"Should not have thrown.");
    SLAssertTrue([text isEqualToString:kExpectedText], @"Retrieved unexpected text: %@.", text);
}

@end
