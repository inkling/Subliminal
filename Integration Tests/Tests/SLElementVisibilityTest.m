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
 -testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell and
 -testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell.

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
    __block BOOL isVisible = NO;
    [self performActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        isVisible = [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isVisible() ? 'YES' : 'NO')", uiaRepresentation] boolValue];
    }];
    return isVisible;
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

- (void)testViewIsNotVisibleIfItsCenterIsCovered {
    SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    SLAskApp(uncoverTestView);
    
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
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
    SLAskApp(uncoverTestView);

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

#pragma mark - Test waitUntil{Visible:,Invisible:}

// Depending on slight timing variances, whenever we wait,
// the wait may vary by the retry delay used by SLElement
- (NSTimeInterval)waitDelayVariability {
    return SLElementWaitRetryDelay;
}

- (void)testWaitUntilVisibleDoesNotThrowAndReturnsImmediatelyWhenConditionIsTrueUponWait {
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow([_testElement waitUntilVisible:1.5], @"Should not have thrown.");
    
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
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
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testWaitUntilInvisibleOrInvalidDoesNotThrowAndReturnsImmediatelyWhenValidityConditionIsTrueUponWait {
    SLAssertFalse([_testElement isValid], @"Test element should not be valid.");

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    SLAssertNoThrow([_testElement waitUntilInvisibleOrInvalid:1.5], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < .01,
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
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
