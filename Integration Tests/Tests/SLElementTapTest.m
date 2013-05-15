//
//  SLElementTapTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/8/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import "SLElement+Subclassing.h"

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
    if (testCaseSelector == @selector(testUserInteractionRequiresTappability) ||
        testCaseSelector == @selector(testWaitUntilTappableNOThenPerformActionWithUIARepresentationDoesNotWaitUntilTappable) ||
        testCaseSelector == @selector(testWaitUntilTappableYESThenPerformActionWithUIARepresentationWaitsUntilTappable) ||
        testCaseSelector == @selector(testWaitUntilTappableYESThenPerformActionWithUIARepresentationThrowsIfElementIsNotTappableAtEndOfTimeout)) {
        SLAskApp(hideTestView); // to make the test view not tappable
    }
}

- (void)testCanTapElement {
    SLAssertNoThrow([UIAElement(_testElement) tap], @"Should not have thrown.");
    SLAssertTrue(SLAskApp(tapPoint) != nil, @"Tap should have been recognized.");
}

- (void)testTapOccursAtHitpoint {
    [UIAElement(_testElement) tap];
    CGPoint tapPoint = [SLAskApp(tapPoint) CGPointValue];
    CGPoint expectedTapPoint = [UIAElement(_testElement) hitpoint];
    SLAssertTrue(CGPointEqualToPoint(tapPoint, expectedTapPoint),
                 @"-tap tapped the element at %@, not at %@ as expected.",
                 NSStringFromCGPoint(tapPoint), NSStringFromCGPoint(expectedTapPoint));
}

#pragma mark - Internal tests

// UIAutomation calls involving (simulated) user interaction will fail
// if the element is not tappable (contrast to -[SLElementStateTest
// testCanRetrieveLabelEvenIfNotTappable]). For this reason, Subliminal
// protects all calls that require user interaction by waiting until tappable
// (see the test cases below this one).
- (void)testUserInteractionRequiresTappability {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");
    SLLog(@"*** The UIAutomation errors seen in the test output immediately below are an expected part of the tests.");
    // force Subliminal not to wait for tappability
    SLAssertThrowsNamed([UIAElement(_testElement) waitUntilTappable:NO thenSendMessage:@"tap()"],
                        SLTerminalJavaScriptException,
                        @"Element should not have been able to be tapped.");
    // sanity check
    SLAssertTrue(SLAskApp(tapPoint) == nil, @"Element should not have been tapped.");

    SLAskApp(resetTapRecognition);

    SLAskApp(showTestView);
    SLAssertTrue([UIAElement(_testElement) isTappable],
                 @"The test element should now be tappable.");
    SLAssertNoThrow([UIAElement(_testElement) waitUntilTappable:NO thenSendMessage:@"tap()"],
                    @"Element should have been able to be tapped.");
    SLAssertTrue(SLAskApp(tapPoint) != nil, @"Tap should have been recognized.");
}

// Tapping is a process involving JS execution,
// with some variability in waiting for tappability (+/- one SLElementRetryDelay
// and two SLTerminalReadRetryDelays (one for SLTerminal.js receiving the command
// and one for SLTerminal receiving the result)), and tapping
// (two more SLTerminalReadRetryDelays).
- (NSTimeInterval)waitDelayVariabilityIncludingTap:(BOOL)includingTap {
    return SLElementWaitRetryDelay + SLTerminalReadRetryDelay * (includingTap ? 4 : 2);
}

- (void)testWaitUntilTappableNOThenPerformActionWithUIARepresentationDoesNotWaitUntilTappable {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");
    SLLog(@"*** The UIAutomation errors seen in the test output immediately below are an expected part of the tests.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    SLAssertThrowsNamed(([UIAElement(_testElement) waitUntilTappable:NO
                                                   thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                            [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                        }]),
                        SLTerminalJavaScriptException,
                        @"Element should not have been able to be tapped.");
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;

    SLAssertTrue(waitTimeInterval < [self waitDelayVariabilityIncludingTap:YES],
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
    
    // sanity check
    SLAssertTrue(SLAskApp(tapPoint) == nil, @"Element should not have been tapped.");
}

- (void)testWaitUntilTappableYESThenPerformActionWithUIARepresentationWaitsUntilTappable {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // it's not necessary to have the test explicitly wait for the button
    // to become visible; -tap will wait
    SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(([UIAElement(_testElement) waitUntilTappable:YES
                                              thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                        [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                     }]),
                    @"Element should have been able to be tapped.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:YES],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);

    SLAssertTrue(SLAskApp(tapPoint) != nil, @"Tap should have been recognized.");
}

- (void)testWaitUntilTappableYESThenPerformActionWithUIARepresentationThrowsIfElementIsNotTappableAtEndOfTimeout {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");

    NSTimeInterval expectedWaitTimeInterval = [SLElement defaultTimeout];
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    SLAssertThrowsNamed(([UIAElement(_testElement) waitUntilTappable:YES
                                                   thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                            [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                        }]),
                        SLElementNotTappableException,
                        @"Element should not have been able to be tapped.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:NO],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

@end
