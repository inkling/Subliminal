//
//  SLElementVisibilityTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementVisibilityTest : SLIntegrationTest

@end

@implementation SLElementVisibilityTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementVisibilityTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    
    _testElement = [SLElement elementWithAccessibilityLabel:@"test"];
}

#pragma mark - Test isVisible for elements that are views

- (void)testViewIsNotVisibleIfItIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(showTestView);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfSuperviewIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(showTestViewSuperview);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItHasAlphaBelow0_01 {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(increaseTestViewAlpha);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(moveTestViewOnscreen);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItsCenterIsCovered {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(uncoverTestView);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

#pragma mark - Test isVisible for elements that are not views

- (void)testAccessibilityElementIsNotVisibleIfContainerIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(showTestView);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(moveTestViewOnscreen);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(uncoverTestView);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(uncoverTestElement);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

#pragma mark - Test waitUntil{Visible:,Invisible:}

// Because we wait on a process involving UIAutomation,
// there is some variability in the duration of UIAutomation's execution
// and in the interval before we find out that it timed out.
// Thus, the variability is +/- one SLElementWaitRetryDelay,
// and one SLTerminalWaitRetryDelay.
- (NSTimeInterval)waitDelayVariability {
    return SLTerminalReadRetryDelay + SLElementWaitRetryDelay;
}

- (void)testWaitUntilVisibleDoesNotThrowAndReturnsImmediatelyWhenConditionIsTrueUponWait {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow([_testElement waitUntilVisible:1.5], @"Should not have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .25, @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testWaitUntilVisibleDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow([_testElement waitUntilVisible:waitTimeInterval], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

- (void)testWaitUntilVisibleDoesNotThrowIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // we cause the test element to become valid by relabeling the test view
    // to the test element's label
    SLAskApp1(relabelTestViewToTestAndShowAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow([_testElement waitUntilVisible:waitTimeInterval], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

// the specified timeout is used both to resolve the element
// and to wait for it to become visible
- (void)testWaitUntilVisibleWaitsForSpecifiedTimeoutEvenIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval waitTimeInterval = [SLElement defaultTimeout] + 5.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(relabelTestViewToTestAndShowAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow([_testElement waitUntilVisible:waitTimeInterval], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

- (void)testWaitUntilVisibleThrowsIfConditionIsStillFalseAtEndOfTimeout {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed([_testElement waitUntilVisible:expectedWaitTimeInterval],
                        SLElementNotVisibleException, @"Should have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

// the specified timeout is used both to resolve the element
// and to wait for it to become visible
- (void)testWaitUntilVisibleThrowsAfterSpecifiedTimeoutEvenIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval expectedWaitTimeInterval = [SLElement defaultTimeout] - 3.0;
    // The default timeout is 5.0--guard against it becoming shorter for some reason
    SLAssertTrue(expectedWaitTimeInterval > 0.0, @"The default timeout is too short for the purposes of this test.");
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed([_testElement waitUntilVisible:expectedWaitTimeInterval],
                        SLElementInvalidException, @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyWhenVisibilityConditionIsTrueUponWait {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow([_testElement waitUntilInvisibleOrInvalid:1.5], @"Should not have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .25, @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyWhenValidityConditionIsTrueUponWait {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow([_testElement waitUntilInvisibleOrInvalid:1.5], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .25, @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(hideTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow([_testElement waitUntilInvisibleOrInvalid:waitTimeInterval], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidDoesNotThrowIfElementBecomesDirectlyInvalid {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // we invalidate the view by removing it from its superview
    // this will cause it to be considered "not visible", even though -isVisible
    // would throw (because the state of an invalid element is indeterminate)
    SLAskApp1(removeTestViewFromSuperviewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow([_testElement waitUntilInvisibleOrInvalid:waitTimeInterval], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidThrowsIfConditionIsStillFalseAtEndOfTimeout {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed([_testElement waitUntilInvisibleOrInvalid:expectedWaitTimeInterval],
                        SLElementVisibleException, @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

@end
