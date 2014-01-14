//
//  SLElementStateTest.m
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
#import <Subliminal/SLTerminal.h>

@interface SLElementStateTest : SLIntegrationTest

@end

@implementation SLElementStateTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementStateTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    _testElement = [SLElement elementWithAccessibilityLabel:@"Test Element"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];
    if (testCaseSelector == @selector(testHitpointDefaultIsNotAccessibilityActivationPointBelowIOS7)) {
        SLAskApp(modifyActivationPoint);
    }
}

- (void)testLabel {
    NSString *expectedLabel = SLAskApp(elementLabel);
    NSString *label = [UIAElement(_testElement) label];
    SLAssertTrue([label isEqualToString:expectedLabel], @"-label did not return expected.");
}

- (void)testValue {
    NSString *expectedValue = SLAskApp(elementValue);
    NSString *value = [UIAElement(_testElement) value];
    SLAssertTrue([value isEqualToString:expectedValue], @"-value did not return expected.");
}

- (void)testIsEnabledReturnsYESByDefault {
    SLAssertTrue([UIAElement(_testElement) isEnabled],
                 @"UIAElement.isEnabled() should return true for arbitrary elements.");
}

- (void)testIsEnabledMirrorsUIControlIsEnabledWhenMatchingObjectIsUIControl {
    // the matching object here is a UIButton
    SLAskApp(disableElement);
    SLAssertFalse([UIAElement(_testElement) isEnabled], @"isEnabled() should return false.");

    SLAskApp(enableElement);
    SLAssertTrue([UIAElement(_testElement) isEnabled], @"isEnabled() should return true.");
}

- (CGPoint)defaultHitpoint {
    // `-hitpoint` returns the midpoint of the element's accessibility frame below iOS 7
    // (regardless of the element's accessibility point),
    // the element's accessibility activation point at or above iOS 7
    CGPoint expectedHitpoint;
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
        expectedHitpoint = [SLAskApp(activationPoint) CGPointValue];
    } else {
        CGRect elementRect = [SLAskApp(elementRect) CGRectValue];
        expectedHitpoint = CGPointMake(CGRectGetMidX(elementRect), CGRectGetMidY(elementRect));
    }
    return expectedHitpoint;
}

- (void)testHitpointDefault {
    CGPoint hitpoint = [UIAElement(_testElement) hitpoint];
    SLAssertTrue(CGPointEqualToPoint(hitpoint, [self defaultHitpoint]), @"-hitpoint did not return expected value.");
}

// An element's accessibility activation point is by default the midpoint of its accessibility frame.
// In this test case's setup we modify the accessibility activation point to show that `-hitpoint` does not
// return the element's accessibility activation point below iOS 7, and to justify the development
// of `-[SLElement tapAtActivationPoint]` for use on older SDKs.
- (void)testHitpointDefaultIsNotAccessibilityActivationPointBelowIOS7 {
    CGPoint hitpoint = [UIAElement(_testElement) hitpoint];
    CGPoint activationPoint = [SLAskApp(activationPoint) CGPointValue];
    if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1) {
        SLAssertFalse(CGPointEqualToPoint(hitpoint, activationPoint),
                      @"`-hitpoint` should not have returned the button's modified activation point.");
    } else {
        SLAssertTrue(CGPointEqualToPoint(hitpoint, activationPoint),
                     @"-`hitpoint` should have returned the button's modified activation point.");
    }
}

// In this test case's setup, we do not modify the accessibility activation point,
// allowing us to cover the default hitpoint on iOS 7 and below by covering the midpoint of the element.
- (void)testHitpointReturnsAlternatePointIfDefaultIsCovered {
    CGPoint hitpoint = [UIAElement(_testElement) hitpoint];
    SLAssertFalse(CGPointEqualToPoint(hitpoint, [self defaultHitpoint]), @"-hitpoint did not return expected value.");
    SLAssertFalse(SLCGPointIsNull(hitpoint), @"-hitpoint did not return expected value.");
}

// UIAElement.hitpoint() may return null for other reasons, depending on the view
// --for instance, UIAScrollViews return null if their corresponding UIScrollViews
// have userInteractionEnabled = NO, whereas UIAutomation can still determine the
// hitpoint for other views with userInteractionEnabled = NO; but hiding the view
// is a reliable way to induce failure
- (void)testHitpointReturnsNullPointIfElementIsCovered {
    CGPoint hitpoint = [UIAElement(_testElement) hitpoint];
    SLAssertTrue(SLCGPointIsNull(hitpoint), @"-hitpoint did not return expected value.");
}

- (void)testElementIsTappableIfItHasANonNullHitpoint {
    CGPoint hitpoint = [UIAElement(_testElement) hitpoint];
    SLAssertTrue(SLCGPointIsNull(hitpoint), @"-hitpoint did not return expected value.");
    SLAssertFalse([UIAElement(_testElement) isTappable], @"Element should not be tappable if hitpoint is null.");

    SLAskApp(uncoverTestView);

    hitpoint = [UIAElement(_testElement) hitpoint];
    SLAssertFalse(SLCGPointIsNull(hitpoint), @"-hitpoint did not return expected value.");
    SLAssertTrue([UIAElement(_testElement) isTappable], @"Element should be tappable if hitpoint is not null.");
}

// UIAutomation does not throw an exception when asked to access a user interface
// element, so long as that access does not involve simulating user interaction
// with the element. Contrast -[SLElementTapTest testUserInteractionRequiresTappability].
- (void)testCanRetrieveLabelEvenIfNotTappable {
    NSString *const kTestElementUIARepresentation = @"UIATarget.localTarget().frontMostApp().mainWindow().elements()['Test Element']";
    NSString *const kTestElementIsTappable = [NSString stringWithFormat:@"%@.hitpoint() != null", kTestElementUIARepresentation];

    SLAssertFalse([[[SLTerminal sharedTerminal] eval:kTestElementIsTappable] boolValue],
                  @"For the purposes of this test, the test element should not be tappable.");

    NSString *expectedLabel = SLAskApp(elementLabel);
    NSString *label;
    SLAssertNoThrow(label = ([[SLTerminal sharedTerminal] evalWithFormat:@"%@.label()", kTestElementUIARepresentation]),
                    @"Accessing -label should not have thrown, despite not being tappable.");
    SLAssertTrue([label isEqualToString:expectedLabel], @"-label did not return expected.");
}

- (void)testHasKeyboardFocus {
    SLTextField *textField = [SLTextField elementWithAccessibilityLabel:@"Test Element"];
    SLAssertFalse([UIAElement(textField) hasKeyboardFocus], @"Text field should not have keyboard focus.");

    SLAskApp(makeTextFieldFirstResponder);
    
    SLAssertTrue([UIAElement(textField) hasKeyboardFocus], @"Text field should have keyboard focus.");
}

- (void)testRect {
    CGRect expectedRect = [SLAskApp(elementRect) CGRectValue];
    CGRect rect = [UIAElement(_testElement) rect];
    SLAssertTrue(CGRectEqualToRect(expectedRect, rect), @"-rect did not return expected.");
}

@end
