//
//  SLElementVisibilityTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import "SLElement+Subclassing.h"

/**
 Subliminal's implementation of -isVisible does not rely upon UIAutomation, 
 because UIAElement.isVisible() has a number of bugs as exercised in 
 -testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell
 -testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell
 -testViewIsVisibleIfItsCenterIsCoveredByClearRegion
 -testViewIsNotVisibleIfCenterAndUpperLeftHandCornerAreCovered

 Subliminal's implementation otherwise attempts to conform to UIAutomation's 
 definition of visibility, as demonstrated by the below test cases.
 */
@interface SLElementVisibilityTest : SLIntegrationTest
@end


@interface SLElement (SLElementVisibilityTest)

/**
 Determines whether the specified element is visible on the screen 
 using UIAutomation.
 
 This method is declared only as a reference for Subliminal's implementation
 of -[SLElement isVisible], which is to be preferred to UIAElement.isVisible() 
 due to bugs in the latter function.
 */
- (BOOL)uiaIsVisible;

@end

@implementation SLElement (SLElementVisibilityTest)

- (BOOL)uiaIsVisible {
    return [[self waitUntilTappable:NO thenSendMessage:@"isVisible()"] boolValue];
}

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

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];

    if (testSelector == @selector(testDeterminingVisibilityOfWebAccessibilityElements)) {
        SLWaitUntilTrue(SLAskAppYesNo(webViewDidFinishLoad), 5.0, @"Webview did not load test HTML.");
    }
}

#pragma mark - Test isVisible for elements that are views

- (void)testViewIsNotVisibleIfItIsHidden {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(showTestView);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell {
    // once the view has been shown,
    // the table view cell appears to cache its state
    // breaking UIAElement.isVisible
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");

    SLAskApp(hideTestView);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible, but it doesn't.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");
}

- (void)testViewIsNotVisibleIfSuperviewIsHidden {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(showTestViewSuperview);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

// a view is visible if its center hit-tests to itself or a descendant
- (void)testViewIsVisibleIfDescendantIsVisible {
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the subview is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the subview is visible.");

    // we must make the superview accessible after checking the subview
    // because a view will not appear in the accessibility hierarchy if its parent is accessible
    SLAskApp(makeOtherViewAccessible);

    SLElement *otherElement = [SLElement elementWithAccessibilityLabel:@"other"];
    SLAssertTrue([otherElement uiaIsVisible], @"UIAutomation should say that the superview is visible.");
    SLAssertTrue([otherElement isVisible], @"Subliminal should say that the superview is visible.");
}

- (void)testViewIsVisibleEvenIfUserInteractionIsDisabled {
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testViewIsNotVisibleIfItHasAlphaBelow0_01 {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(increaseTestViewAlpha);
    
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testViewIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(moveTestViewOnscreen);
    
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testViewIsNotVisibleIfCenterAndUpperLeftHandCornerAreCovered {
    // The upper left hand corner (and any/all other corners) can be hidden and the view will remain visible
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
    SLAskApp1(showOtherViewWithTag:, @1);   // upper left
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
    SLAskApp1(showOtherViewWithTag:, @2);   // upper right
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
    SLAskApp1(showOtherViewWithTag:, @3);   // lower right
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
    SLAskApp1(showOtherViewWithTag:, @4);   // lower left
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");

    SLAskApp1(hideOtherViewWithTag:, @4);
    SLAskApp1(hideOtherViewWithTag:, @3);
    SLAskApp1(hideOtherViewWithTag:, @2);
    SLAskApp1(hideOtherViewWithTag:, @1);

    // But if the center and the upper left hand corner are hidden then the view will become not visible to UIAutomation
    // and Subliminal.  Subliminal treats the view as visible if the center is visible or all four corners are visible.
    // Unlike UIAutomation, Subliminal does not give any special privilege to the top left corner.
    SLAskApp1(showOtherViewWithTag:, @5);   // center hidden
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");

    SLAskApp1(showOtherViewWithTag:, @1);
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");
    SLAskApp1(hideOtherViewWithTag:, @1);

    SLAskApp1(showOtherViewWithTag:, @2);
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");
    SLAskApp1(hideOtherViewWithTag:, @2);

    SLAskApp1(showOtherViewWithTag:, @3);
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");
    SLAskApp1(hideOtherViewWithTag:, @3);

    SLAskApp1(showOtherViewWithTag:, @4);
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");
    SLAskApp1(hideOtherViewWithTag:, @4);
}

- (void)testViewIsVisibleIfItsCenterIsCoveredByClearRegion {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible (even though it is!).");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

#pragma mark - Test isVisible for elements that are not views

- (void)testAccessibilityElementIsNotVisibleIfContainerIsHidden {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    // the test view is the container of the test element
    SLAskApp(showTestView);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell {
    // for some reason, UIAElement.isVisible always returns true
    // for elements in table view cells, even if those elements' containers are hidden
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible, but it doesn't.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    // the test view is the container of the test element
    SLAskApp(showTestView);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementIsVisibleEvenIfHidden {
    // UIAutomation ignores the value of accessibilityElementsHidden and so Subliminal does too
    // --this is not clearly a bug in UIAutomation; the documentation is vague
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    // the test view is the container of the test element
    SLAskApp(moveTestViewOnscreen);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    // the test view is the container of the test element
    SLAskApp1(hideOtherViewWithTag:, @1);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(uncoverTestElement);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testCanDetermineVisibilityOfWebAccessibilityElements {
    // No accessibility elements are created to represent invisible HTML elements
    // --as far as I can tell, UIAccessibility cannot describe an HTML element as "not visible"
    // Tested by hiding elements using "display:none", "visibility:hidden", and "aria-hidden='true'".
    SLAssertFalse([_testElement isValid], @"The test element should not be valid.");

    SLAskApp(showTestText);

    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testAccessibilityElementCannotBeOccludedByPeerSubview {
    // Verify that the _testElement is considered visible by UIAutomation and by
    // Subliminal even though it is covered by a subview of its container view.
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

#pragma mark - Test SLWaitUntil{Visible:,InvisibleOrInvalid:}

// Depending on slight timing variances, whenever we wait,
// the wait may vary by the retry delay used by SLElement
- (NSTimeInterval)waitDelayVariability {
    return SLElementWaitRetryDelay;
}

- (void)testSLWaitUntilVisibleDoesNotThrowAndReturnsImmediatelyWhenConditionIsTrueUponWait {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow(SLWaitUntilVisible(_testElement, 1.5, nil), @"Should not have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testSLWaitUntilVisibleDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(SLWaitUntilVisible(_testElement, waitTimeInterval, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testSLWaitUntilVisibleDoesNotThrowIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // we cause the test element to become valid by relabeling the test view
    // to the test element's label
    SLAskApp1(relabelTestViewToTestAndShowAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(SLWaitUntilVisible(_testElement, waitTimeInterval, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

// the specified timeout is used both to resolve the element
// and to wait for it to become visible
- (void)testSLWaitUntilVisibleWaitsForSpecifiedTimeoutEvenIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval waitTimeInterval = [SLElement defaultTimeout] + 5.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(relabelTestViewToTestAndShowAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(SLWaitUntilVisible(_testElement, waitTimeInterval, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testSLWaitUntilVisibleThrowsIfConditionIsStillFalseAtEndOfTimeout {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed(SLWaitUntilVisible(_testElement, expectedWaitTimeInterval, nil),
                        SLElementNotVisibleException, @"Should have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

// the specified timeout is used both to resolve the element
// and to wait for it to become visible
- (void)testSLWaitUntilVisibleThrowsAfterSpecifiedTimeoutEvenIfElementIsInvalidUponWaiting {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval expectedWaitTimeInterval = [SLElement defaultTimeout] - 3.0;
    // The default timeout is 5.0--guard against it becoming shorter for some reason
    SLAssertTrue(expectedWaitTimeInterval > 0.0, @"The default timeout is too short for the purposes of this test.");
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed(SLWaitUntilVisible(_testElement, expectedWaitTimeInterval, nil),
                        SLElementInvalidException, @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testSLWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyWhenVisibilityConditionIsTrueUponWait {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow(SLWaitUntilInvisibleOrInvalid(_testElement, 1.5, nil), @"Should not have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testSLWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyWhenValidityConditionIsTrueUponWait {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow(SLWaitUntilInvisibleOrInvalid(_testElement, 1.5, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testSLWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAskApp1(hideTestViewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(SLWaitUntilInvisibleOrInvalid(_testElement, waitTimeInterval, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testSLWaitUntilInvisibleOrInvalidDoesNotThrowIfElementBecomesDirectlyInvalid {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // we invalidate the view by removing it from its superview
    // this will cause it to be considered "not visible", even though -isVisible
    // would throw (because the state of an invalid element is indeterminate)
    SLAskApp1(removeTestViewFromSuperviewAfterInterval:, @(expectedWaitTimeInterval));
    SLAssertNoThrow(SLWaitUntilInvisibleOrInvalid(_testElement, waitTimeInterval, nil), @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testSLWaitUntilInvisibleOrInvalidThrowsIfConditionIsStillFalseAtEndOfTimeout {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertThrowsNamed(SLWaitUntilInvisibleOrInvalid(_testElement, expectedWaitTimeInterval, nil),
                        SLElementVisibleException, @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

@end
