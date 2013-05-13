//
//  SLElementTapTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/8/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementTapTest : SLIntegrationTest

@end

@implementation SLElementTapTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementTapTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    
    _testElement = [SLElement elementWithAccessibilityLabel:@"test"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    SLAskApp(resetTapRecognition);
    if (testCaseSelector == @selector(testCanTapElementOnlyIfTappable)) {
        SLAskApp(hideTestView); // to make the test view not tappable
    }
}

- (void)testCanTapElement {
    SLAssertNoThrow([UIAElement(_testElement) tap], @"Should not have thrown.");
    SLAssertTrue(SLAskApp(tapPoint) != nil, @"Tap should have been recognized.");
}

- (void)testCanTapElementOnlyIfTappable {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");
    SLLog(@"*** The errors seen in the test output immediately below are an expected part of the tests.");
    SLAssertThrowsNamed([UIAElement(_testElement) tap],
                        SLTerminalJavaScriptException,
                        @"Element should not have been able to be tapped.");

    // sanity check
    SLAssertTrue(SLAskApp(tapPoint) == nil, @"Element should not have been tapped.");

    SLAskApp(resetTapRecognition);

    SLAskApp(showTestView);
    SLAssertTrue([UIAElement(_testElement) isTappable],
                 @"For the purposes of this test case, the test element should be tappable.");
    SLAssertNoThrow([UIAElement(_testElement) tap], @"Element should have been able to be tapped.");
}

- (void)testTapOccursAtHitpoint {
    [UIAElement(_testElement) tap];
    CGPoint tapPoint = [SLAskApp(tapPoint) CGPointValue];
    CGPoint expectedTapPoint = [UIAElement(_testElement) hitpoint];
    SLAssertTrue(CGPointEqualToPoint(tapPoint, expectedTapPoint),
                 @"-tap tapped the element at %@, not at %@ as expected.",
                 NSStringFromCGPoint(tapPoint), NSStringFromCGPoint(expectedTapPoint));
}

@end
