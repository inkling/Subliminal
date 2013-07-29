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
    SLTextView *_textView;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTextViewTestViewController";
}

- (void)setUpTest {
    [super setUpTest];

    _textView = [SLTextView elementWithAccessibilityLabel:@"test element"];
}

static NSString *const kExpectedText = @"foo";
- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if ((testCaseSelector == @selector(testGetText)) ||
        (testCaseSelector == @selector(testDoNotMatchEditorAccessibilityObjects))) {
        SLAskApp1(setText:, kExpectedText);
    }
}

- (void)testSetText {
    SLAssertNoThrow([UIAElement(_textView) setText:kExpectedText], @"Should not have thrown.");
    SLAssertTrue([SLAskApp(text) isEqualToString:kExpectedText], @"Text was not set to expected value.");
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

@end
