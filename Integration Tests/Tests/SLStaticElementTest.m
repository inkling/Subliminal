//
//  SLStaticElementTest.m
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
        SLAskApp(hideButton);       // to make the button not tappable
    } else if (testCaseSelector == @selector(testStaticElementsDoNotWaitUntilTappableIfIsScrollViewIsYESAndIsIPad5_x)) {
        SLAskApp(hideScrollView);   // to make it not tappable
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
// +/- one `SLUIAElementWaitRetryDelay`, two `SLTerminalReadRetryDelays` (one for
// `SLTerminal.js` receiving the command and one for `SLTerminal` receiving the result),
// and one `SLTerminalEvaluationDelay` (to evaluate the command).
// Waiting for tappability and/or an action (e.g. checking the element's value, tapping on the element)
// will involve 2 more `SLTerminalReadRetryDelays`, and another `SLTerminalEvaluationDelay`, apiece.
- (NSTimeInterval)waitDelayVariabilityIncludingTappabilityCheck:(BOOL)includeTappabilityCheck
                                                         action:(BOOL)includeAction {
    NSUInteger evaluationCount = 1;
    if (includeTappabilityCheck) evaluationCount++;
    if (includeAction) evaluationCount++;
    return SLUIAElementWaitRetryDelay + ((SLTerminalReadRetryDelay * 2) + SLTerminalEvaluationDelay) * evaluationCount;
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
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:NO action:YES],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
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
    // No action because we should have aborted after the validity check, and not asked UIAutomation for the value
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:NO action:NO],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
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
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:YES action:YES],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
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
    // we should have aborted after the tappability check, and not tapped
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:YES action:NO],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

- (void)testStaticElementsDoNotWaitUntilTappableIfIsScrollViewIsYESAndIsIPad5_x {
    SLStaticElement *scrollView = [[SLStaticElement alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().mainWindow().scrollViews()['scroll view']"];

    
    // first test with isScrollView set to YES
    scrollView.isScrollView = YES;
    
    BOOL isIPad5_x = ((kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) &&
                      ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad));
    NSTimeInterval expectedWaitTimeInterval;
    if (isIPad5_x) {
        expectedWaitTimeInterval = 0.0;
        SLAssertFalse([UIAElement(scrollView) isTappable],
                      @"UIAutomation should report scroll views as not tappable on iPad 5_x.");
    } else {
        expectedWaitTimeInterval = 2.0;
    }

    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    // make the scroll view tappable (if not for UIAutomation's bug)
    // after the expected wait interval
    SLAskApp1(showScrollViewAfterInterval:, @(expectedWaitTimeInterval));
    if (isIPad5_x) {
        // we should try to tap the scroll view, despite it not being tappable
        SLAssertThrowsNamed(([UIAElement(scrollView) waitUntilTappable:YES
                                  thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                                      [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                                  } timeout:[SLStaticElement defaultTimeout]]),
                            SLUIAElementAutomationException,
                            @"Should have tried to tap the scroll view and found it to not be tappable.");
    } else {
        SLAssertNoThrow(([UIAElement(scrollView) waitUntilTappable:YES
                              thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                                  [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                              } timeout:[SLStaticElement defaultTimeout]]),
                        @"Should have been able to tap the scroll view.");
    }
    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitInterval = endTimeInterval - startTimeInterval;
    // we should not have waited for tappability on iPad 5_x, due to `isScrollView` being `YES`
    SLAssertTrue(actualWaitInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:!isIPad5_x action:YES],
                 @"Test waited for %g but should not have waited for appreciably longer than %g.",
                 actualWaitInterval, expectedWaitTimeInterval);

    
    // now, if we're running on an iPad running 5_x, test with isScrollView off
    if (isIPad5_x) {
        scrollView.isScrollView = NO;
        // we already showed the scroll view above but just to be sure
        // --the scroll view _should_ be tappable (if not for UIAutomation's bug)
        SLAskApp1(showScrollViewAfterInterval:, @0.0);

        // now we should wait for the entire timeout
        expectedWaitTimeInterval = [SLStaticElement defaultTimeout];
        startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // and we shouldn't try to tap on the view, because we should abort beforehand,
        // saying that the scroll view is not tappable
        SLAssertThrowsNamed(([UIAElement(scrollView) waitUntilTappable:YES
                                thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
                                    [[SLTerminal sharedTerminal] evalWithFormat:@"%@.tap()", UIARepresentation];
                                } timeout:expectedWaitTimeInterval]),
                            SLUIAElementNotTappableException,
                            @"Should have tried to tap the scroll view and found it to not be tappable.");
        endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        actualWaitInterval = endTimeInterval - startTimeInterval;
        // we should have aborted after the tappability check, and not tapped
        SLAssertTrue(actualWaitInterval - expectedWaitTimeInterval < [self waitDelayVariabilityIncludingTappabilityCheck:YES action:NO],
                     @"Test waited for %g but should not have waited for appreciably longer than %g.",
                     actualWaitInterval, expectedWaitTimeInterval);
    }
}

@end
