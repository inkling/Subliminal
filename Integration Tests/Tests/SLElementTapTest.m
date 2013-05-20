//
//  SLElementTapTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/8/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import "SLUIAElement+Subclassing.h"

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

// If UIAutomation is asked to simulate user interaction with an untappable element,
// it will throw an exception (contrast -[SLElementStateTest testCanRetrieveLabelEvenIfNotTappable]).
// For this reason, Subliminal defines an API for communicating with UIAutomation
// that optionally waits until the specified element is tappable (see the test cases below this one).
- (void)testUserInteractionRequiresTappability {
    NSString *const kTestElementUIARepresentation = @"UIATarget.localTarget().frontMostApp().mainWindow().elements()['test']";
    NSString *const kTestElementIsTappable = [NSString stringWithFormat:@"%@.hitpoint() != null", kTestElementUIARepresentation];

    SLAssertFalse([[[SLTerminal sharedTerminal] eval:kTestElementIsTappable] boolValue],
                  @"For the purposes of this test, the test element should not be tappable.");

    SLLog(@"*** The UIAutomation errors seen in the test output immediately below are an expected part of the tests.");
    SLAssertThrowsNamed(([[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", kTestElementUIARepresentation]),
                        SLTerminalJavaScriptException,
                        @"Element should not have been able to be tapped.");
    // sanity check
    SLAssertTrue(SLAskApp(tapPoint) == nil, @"Element should not have been tapped.");

    SLAskApp(resetTapRecognition);

    SLAskApp(showTestView);
    SLAssertTrue([[[SLTerminal sharedTerminal] eval:kTestElementIsTappable] boolValue],
                 @"For the purposes of this test, the test element should be tappable.");
    SLAssertNoThrow(([[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", kTestElementUIARepresentation]),
                    @"Element should have been able to be tapped.");
    SLAssertTrue(SLAskApp(tapPoint) != nil, @"Tap should have been recognized.");
}

// Tapping is a process involving JS execution,
// with some variability in waiting for tappability (+/- one SLElementRetryDelay
// and two SLTerminalReadRetryDelays (one for SLTerminal.js receiving the command
// and one for SLTerminal receiving the result)), and tapping
// (two more SLTerminalReadRetryDelays).
- (NSTimeInterval)waitDelayVariabilityIncludingTap:(BOOL)includingTap {
    return SLUIAElementWaitRetryDelay + SLTerminalReadRetryDelay * (includingTap ? 4 : 2);
}

- (void)testWaitUntilTappableNOThenPerformActionWithUIARepresentationDoesNotWaitUntilTappable {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");
    SLLog(@"*** The UIAutomation errors seen in the test output immediately below are an expected part of the tests.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    // because Subliminal will not wait until tappable, UIAutomation will throw an exception
    SLAssertThrowsNamed(([UIAElement(_testElement) waitUntilTappable:NO
                                                   thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                            [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                        } timeout:[SLElement defaultTimeout]]),
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

    // UIAutomation should not throw an exception, because Subliminal will
    // wait until the button becomes visible
    SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(([UIAElement(_testElement) waitUntilTappable:YES
                                              thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                        [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                     } timeout:[SLElement defaultTimeout]]),
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
                        } timeout:[SLElement defaultTimeout]]),
                        SLUIAElementNotTappableException,
                        @"Element should not have been able to be tapped.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:NO],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

@end
