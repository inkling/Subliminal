//
//  SLStaticElementTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import "SLUIAElement+Subclassing.h"

/**
 The SLStaticElementTest tests that SLStaticElement's overrides of
 methods inherited from SLElement allow it to properly match 
 and manipulate static elements. 
 */
@interface SLStaticElementTest : SLIntegrationTest

@end

@implementation SLStaticElementTest {
    SLStaticElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLStaticElementTestViewController";
}

- (void)setUpTest {
    [super setUpTest];

    // Static elements should be used to describe elements which cannot be matched
    // to objects within the accessibility hierarchy, not, ordinarily, elements
    // like buttons. The SLStaticElementTest cases describe a button only because
    // the test cases need to manipulate the matching object.
    _testElement = [[SLStaticElement alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().mainWindow().buttons()['SLTestStaticElement']"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if (testCaseSelector == @selector(testStaticElementsWaitUntilTappable) ||
        testCaseSelector == @selector(testStaticElementsThrowIfElementIsNotTappableAtEndOfTimeout)) {
        SLAskApp(hideButton); // to make the button not tappable
    }
}

- (void)testCanMatchStaticElement {
    SLAssertTrue([UIAElement(_testElement) isValid], @"Static element should be valid.");
    SLAssertTrue([[UIAElement(_testElement) value] isEqualToString:@"elementValue"],
                 @"Static element did not match the expected element.");

    // we invalidate the button by removing it from its superview
	SLAskApp(removeButtonFromSuperview);
    SLAssertFalse([UIAElement(_testElement) isValid], @"Static element should not be valid.");
}

// Checking validity is a process involving JS execution, with some variability:
// +/- one SLElementRetryDelay and two SLTerminalReadRetryDelays (one for
// SLTerminal.js receiving the command and one for SLTerminal receiving the result).
// If we tap the element that command involves another two SLTerminalReadRetryDelay's.
- (NSTimeInterval)waitDelayVariabilityIncludingTap:(BOOL)includingTap {
    return SLUIAElementWaitRetryDelay + SLTerminalReadRetryDelay * (includingTap ? 4 : 2);
}

- (void)testStaticElementsWaitToMatchValidObjects {
    // we invalidate the button by removing it from its superview
	SLAskApp(removeButtonFromSuperview);

    // isValid returns immediately, and doesn't throw if the element is invalid
    SLAssertFalse([_testElement isValid],
                  @"The static element should not be valid.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // it's not necessary to have the test explicitly wait for the static element to be shown;
    // -value will wait to match the object
    SLAskApp1(addButtonToViewAfterInterval:, @(expectedWaitTimeInterval));
    NSString *elementValue;
    SLAssertNoThrow(elementValue = [UIAElement(_testElement) value], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:NO],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);

    SLAssertTrue([elementValue isEqualToString:@"elementValue"],
                 @"Should have matched the button with label 'foo'.");
}

- (void)testStaticElementsThrowIfNoValidObjectIsFoundAtEndOfTimeout {
    // we invalidate the button by removing it from its superview
	SLAskApp(removeButtonFromSuperview);

    // isValid returns immediately, and doesn't throw if the element is invalid
    SLAssertFalse([_testElement isValid],
                  @"The static element should not be valid.");

    NSTimeInterval expectedWaitTimeInterval = [SLStaticElement defaultTimeout];
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    NSString *elementValue;
    SLAssertThrowsNamed(elementValue = [UIAElement(_testElement) value],
                        SLUIAElementInvalidException,
                        @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:NO],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testIsVisible {
    SLAssertTrue([UIAElement(_testElement) isVisible], @"Static element should be visible.");

	SLAskApp(hideButton);

    SLAssertFalse([UIAElement(_testElement) isVisible], @"Static element should not be visible.");
}

- (void)testStaticElementsWaitUntilTappable {   // as required
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // it's not necessary to have the test explicitly wait for the button
    // to become visible; -tap will wait
    SLAskApp1(showButtonAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(([UIAElement(_testElement) waitUntilTappable:YES
                                               thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                              [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                          } timeout:[SLStaticElement defaultTimeout]]),
                    @"Element should have been able to be tapped.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:YES],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);

    SLAssertTrue(SLAskAppYesNo(buttonWasTapped), @"Button should have been tapped.");
}

- (void)testStaticElementsThrowIfElementIsNotTappableAtEndOfTimeout {
    SLAssertFalse([UIAElement(_testElement) isTappable],
                  @"For the purposes of this test case, the test element should not be tappable.");

    NSTimeInterval expectedWaitTimeInterval = [SLStaticElement defaultTimeout];
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed(([UIAElement(_testElement) waitUntilTappable:YES
                              thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                                  [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                              } timeout:[SLStaticElement defaultTimeout]]),
                        SLUIAElementNotTappableException,
                        @"Element should not have been able to be tapped.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariabilityIncludingTap:NO],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

@end
