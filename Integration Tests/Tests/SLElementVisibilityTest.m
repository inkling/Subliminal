//
//  SLElementVisibilityTest.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

// So that Subliminal may continue to be built using Xcode 5/the iOS 7.1 SDK.
#ifndef kCFCoreFoundationVersionNumber_iOS_7_1
#define kCFCoreFoundationVersionNumber_iOS_7_1 847.24
#endif

/**
 Subliminal's implementation of -isVisible does not rely upon UIAutomation, 
 because UIAElement.isVisible() has a number of bugs as exercised in 
 -testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell
 -testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell
 -testViewIsVisibleIfItsCenterIsCoveredByClearRegion
 -testViewIsNotVisibleIfCenterAndAnyCornerAreCovered
 -testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView

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

    if (testSelector == @selector(testCanDetermineVisibilityOfWebAccessibilityElements)) {
        SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0, @"Webview did not load test HTML.");
    } else if ((testSelector == @selector(testViewIsVisibleInPortrait)) ||
               (testSelector == @selector(testViewIsVisibleInPortraitUpsideDown)) ||
               (testSelector == @selector(testViewIsVisibleInLandscapeLeft)) ||
               (testSelector == @selector(testViewIsVisibleInLandscapeRight))) {
        SLAskApp(showTestView);
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    if ((testCaseSelector == @selector(testViewIsVisibleInPortrait)) ||
        (testCaseSelector == @selector(testViewIsVisibleInPortraitUpsideDown)) ||
        (testCaseSelector == @selector(testViewIsVisibleInLandscapeLeft)) ||
        (testCaseSelector == @selector(testViewIsVisibleInLandscapeRight))) {
        [[SLDevice currentDevice] setOrientation:UIDeviceOrientationPortrait];
    }

    [super tearDownTestCaseWithSelector:testCaseSelector];
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

- (void)testViewIsNotVisibleIfCenterAndAnyCornerAreCovered {
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

    // In iOS 6 and below, if the center and the upper left hand corner are hidden,
    // then UIAutomation will consider the view to be not visible.
    // In iOS 7, UIAutomation only reports the view as not visible if the center and all four corners are hidden.
    //
    // Subliminal considers the view to be not visible when the center and _any_ corner is hidden:
    // barring edge cases, much of the view is likely covered if the center and at least one corner is hidden
    // (without necessarily hiding the center and all four corners); and there is no reason
    // to privilege the upper left hand corner in this determination.
    SLAskApp1(showOtherViewWithTag:, @5);   // center hidden
    SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");

    SLAskApp1(showOtherViewWithTag:, @1);
    if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1) {
        SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    } else {
        SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    }
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
    if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1) {
        SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible (even though it is!).");
    } else {
        SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    }
    SLAssertTrue([_testElement isVisible], @"Subliminal should say that the element is visible.");
}

- (void)testViewIsVisibleInPortrait {
    [[SLDevice currentDevice] setOrientation:UIDeviceOrientationPortrait];
    SLAssertTrue([UIAElement(_testElement) isVisible], @"Button should be visible");
}

- (void)testViewIsVisibleInPortraitUpsideDown {
    [[SLDevice currentDevice] setOrientation:UIDeviceOrientationPortraitUpsideDown];
    SLAssertTrue([UIAElement(_testElement) isVisible], @"Button should be visible");
}

- (void)testViewIsVisibleInLandscapeLeft {
    [[SLDevice currentDevice] setOrientation:UIDeviceOrientationLandscapeLeft];
    SLAssertTrue([UIAElement(_testElement) isVisible], @"Button should be visible");
}

- (void)testViewIsVisibleInLandscapeRight {
    [[SLDevice currentDevice] setOrientation:UIDeviceOrientationLandscapeRight];
    SLAssertTrue([UIAElement(_testElement) isVisible], @"Button should be visible");
}

- (void)testViewInNonKeyWindowIsVisibleIfNotOccluded {
    SLPickerView *picker = [SLPickerView elementWithAccessibilityIdentifier:@"Picker View"];
    SLTextField *textField = [SLTextField elementWithAccessibilityIdentifier:@"Text Field"];
    
    SLAssertFalse([UIAElement(picker) isValidAndVisible], @"The picker shouldn't be visible initially");
    [UIAElement(textField) tap];
    // allow a small timeout for the picker's animation
    SLAssertTrueWithTimeout([UIAElement(picker) isVisible], 0.3, @"The picker should be visible.");
}

- (void)testViewInKeyWindowIsNotVisibleIfOccludedByOtherWindow {
    SLPickerView *picker = [SLPickerView elementWithAccessibilityIdentifier:@"Picker View"];
    SLTextField *textField = [SLTextField elementWithAccessibilityIdentifier:@"Text Field"];
    SLButton *button = [SLButton elementWithAccessibilityLabel:@"foo"];
    
    SLAssertFalse([UIAElement(picker) isValidAndVisible], @"The picker shouldn't be visible initially.");
    SLAssertTrue([UIAElement(button) isVisible], @"The button should be visible initially.");
    SLAssertTrue([UIAElement(textField) isVisible], @"The text field should be visible initially.");
    [UIAElement(textField) tap];
    // hard wait to let the picker fully animate on-screen
    [self wait:0.3];
    SLAssertFalse([UIAElement(button) isVisible], @"The button should have been covered by the picker.");
    SLAssertTrue([UIAElement(textField) isVisible],
                 @"The text field should still be visible even below the text effects window, because it's not covered by the picker.");
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
    // on iOS 6, `UIAElement.isVisible` always returns true
    // for elements in table view cells, even if those elements' containers are hidden
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1 &&
        kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1) {
        SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible, but it doesn't.");
    } else {
        SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    }
    SLAssertFalse([_testElement isVisible], @"Subliminal should say that the element is not visible.");

    // the test view is the container of the test element
    SLAskApp(showTestView);

    // on iOS 5 and iOS 7, table view cells appear to cache their accessibility state,
    // so, the test view having started out hidden, `UIAElement.isVisible` will return false
    // even though its container is now visible
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_6_0 ||
        kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
        SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible, but it doesn't.");
    } else {
        SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is visible.");
    }
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
    if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_7_1) {
        SLAssertFalse([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible.");
    } else {
        SLAssertTrue([_testElement uiaIsVisible], @"UIAutomation should say that the element is not visible, but it doesn't.");
    }
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

#pragma mark - -isValidAndVisible, -isInvalidOrInvisible

- (void)testIsValidAndVisibleDoesNotThrowIfElementIsInvalid {
    SLAskApp(removeTestViewFromSuperview);

    BOOL isValidAndVisible = NO;
    SLAssertThrowsNamed([UIAElement(_testElement) isVisible],
                        SLUIAElementInvalidException,
                        @"Should have thrown--the visibility of an invalid element is indeterminate.");
    SLAssertNoThrow((isValidAndVisible = [UIAElement(_testElement) isValidAndVisible]),
                    @"Should not have thrown.");
    SLAssertFalse(isValidAndVisible, @"Element should not be valid.");
}

- (void)testIsValidAndVisibleReturnsYESIfElementIsBothValidAndVisible {
    SLAskApp(removeTestViewFromSuperview);

    SLAssertFalse([UIAElement(_testElement) isValidAndVisible], @"Element should not be valid.");

    SLAskApp(addTestViewToView);
    SLAskApp(hideTestView);
    SLAssertFalse([UIAElement(_testElement) isValidAndVisible], @"Element should not be visible.");

    SLAskApp(showTestView);
    SLAssertTrue([UIAElement(_testElement) isValidAndVisible], @"Element should be visible.");
}

- (void)testIsInvalidOrInvisibleDoesNotThrowIfElementIsInvalid {
    SLAskApp(removeTestViewFromSuperview);

    BOOL isInvalidOrInvisible = NO;
    SLAssertThrowsNamed([UIAElement(_testElement) isVisible],
                        SLUIAElementInvalidException,
                        @"Should have thrown--the visibility of an invalid element is indeterminate.");
    SLAssertNoThrow((isInvalidOrInvisible = [UIAElement(_testElement) isInvalidOrInvisible]),
                    @"Should not have thrown.");
    SLAssertTrue(isInvalidOrInvisible, @"Element should be invalid.");
}

- (void)testIsInvalidOrInvisibleReturnsYESIfElementIsInvalidOrInvisible {
    SLAskApp(showTestView);

    SLAssertFalse([UIAElement(_testElement) isInvalidOrInvisible], @"Element should be valid and visible.");

    SLAskApp(removeTestViewFromSuperview);
    SLAssertTrue([UIAElement(_testElement) isInvalidOrInvisible], @"Element should be invalid.");

    SLAskApp(addTestViewToView);
    SLAskApp(hideTestView);
    SLAssertTrue([UIAElement(_testElement) isInvalidOrInvisible], @"Element should be invisible.");
}

@end
