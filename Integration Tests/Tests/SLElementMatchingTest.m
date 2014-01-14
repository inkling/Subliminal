//
//  SLElementMatchingTest.m
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


@interface SLElementMatchingTest : SLIntegrationTest
@end


@implementation SLElementMatchingTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementMatchingTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];
    
    if (testCaseSelector == @selector(testElementsWaitToMatchValidObjects) ||
        testCaseSelector == @selector(testElementsThrowIfNoValidObjectIsFoundAtEndOfTimeout)) {
        SLAskApp(removeFooButtonFromSuperview);
    } else if (testCaseSelector == @selector(testElementWithAccessibilityLabelValueTraits)) {
        SLAskApp(applyUniqueTraitToFooButton);
    } else if (testCaseSelector == @selector(testMatchingWebViewChildElements_iPhone)) {
        SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0,
                                @"Webview did not load test HTML.");
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    // popovers must be hidden before they are deallocated or else will raise an exception
    if ((testCaseSelector == @selector(testMatchingPopoverChildElement_iPad)) ||
        (testCaseSelector == @selector(testMatchingButtonsOfActionSheetsInPopovers_iPad))){
        SLAskApp(hidePopover);
    } else if (testCaseSelector == @selector(testMatchingActionSheetButtons)) {
        SLAskApp(hideActionSheet);
    }
    [super tearDownTestCaseWithSelector:testCaseSelector];
}

#pragma mark - Matching basics

// Elements match afresh each time
- (void)testElementsDoNotCaptureTheirMatches {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the first button with label 'foo'.");

    SLAskApp(swapButtons);

    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"foo2Value"],
                 @"Should have matched the second button with label 'foo'.");
}

// The converse of the above test
// (Also something of an internal test)
- (void)testElementsCanMatchTheSameObjectTwice {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the button with label 'foo'.");

    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the button with label 'foo' again.");
}

// Reading an element's value is a process involving JS execution, with some variability:
// +/- one `SLElementRetryDelay`, two `SLTerminalReadRetryDelays` (one for
// SLTerminal.js receiving the command and one for SLTerminal receiving the result),
// and one `SLTerminalEvaluationDelay` to evaluate the command.
- (NSTimeInterval)waitDelayVariability {
    return SLUIAElementWaitRetryDelay + (SLTerminalReadRetryDelay * 2) + SLTerminalEvaluationDelay;
}

- (void)testElementsWaitToMatchValidObjects {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    // isValid returns immediately, and doesn't throw if the element is invalid
    SLAssertFalse([fooButton isValid],
                  @"There should be no button with the label 'foo' in the view hierarchy.");

    NSTimeInterval expectedWaitTimeInterval = 2.0;
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    // it's not necessary to have the test explicitly wait for the button to be shown;
    // -value will wait to match an object
    SLAskApp1(addFooButtonToViewAfterInterval:, @(expectedWaitTimeInterval));
    NSString *fooButtonValue;
    SLAssertNoThrow(fooButtonValue = [UIAElement(fooButton) value], @"Should not have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);

    SLAssertTrue([fooButtonValue isEqualToString:@"fooValue"],
                 @"Should have matched the button with label 'foo'.");
}

- (void)testElementsThrowIfNoValidObjectIsFoundAtEndOfTimeout {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    // isValid returns immediately, and doesn't throw if the element is invalid
    SLAssertFalse([fooButton isValid],
                  @"There should be no button with the label 'foo' in the view hierarchy.");

    NSTimeInterval expectedWaitTimeInterval = [SLElement defaultTimeout];
    NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

    NSString *fooButtonValue;
    SLAssertThrowsNamed(fooButtonValue = [UIAElement(fooButton) value],
                        SLUIAElementInvalidException,
                        @"Should have thrown.");

    NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

#pragma mark - Matching criteria

- (void)testElementWithAccessibilityLabel {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the button with label 'foo'.");
}

- (void)testElementWithAccessibilityLabelValueTraits {
    for (unsigned char useLabel = 0; useLabel < 2; useLabel++) {
        for (unsigned char useValue = 0; useValue < 2; useValue++) {
            for (unsigned char useTrait = 0; useTrait < 2; useTrait++) {
                NSString *label = useLabel ? @"foo" : nil;
                NSString *value = useValue ? @"fooValue" : nil;
                UIAccessibilityTraits traits = useTrait ? UIAccessibilityTraitUpdatesFrequently : SLUIAccessibilityTraitAny;
                SLElement *fooElement = [SLElement elementWithAccessibilityLabel:label value:value traits:traits];

                // if we don't provide any information, we might match any element
                if (!useLabel && !useValue && (traits == SLUIAccessibilityTraitAny)) {
                    SLAssertTrue([UIAElement(fooElement) isValid], @"Should have matched some element.");
                } else {
                    // otherwise, every attribute above uniquely identifies fooButton
                    SLAssertTrue([[UIAElement(fooElement) value] isEqualToString:@"fooValue"],
                                 @"Should have matched the button with the specified properties (%@).", fooElement);
                }
            }
        }
    }
}

- (void)testElementWithAccessibilityIdentifier {
    SLElement *fooButton = [SLElement elementWithAccessibilityIdentifier:@"fooId"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the button with identifier 'fooId'.");
}

- (void)testElementMatchingPredicate {
    SLElement *fooButton = [SLElement elementMatching:^BOOL(NSObject *obj) {
        return [obj.accessibilityHint isEqualToString:@"fooHint"];
    } withDescription:@"hint = 'fooHint'"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"],
                 @"Should have matched the button with hint 'fooHint'.");
}

- (void)testAnyElement {
    SLSearchField *anySearchField = [SLSearchField anyElement];
    SLAssertTrue([[UIAElement(anySearchField) text] isEqualToString:@"barText"],
                 @"SLSearchField should have matched the search field onscreen.");
}

// The remaining cases in this test verify particulars of element matching
// which are internal to `NSObject(SLAccessibilityHierarchy)` and yet may serve
// as guides to developers in setting accessibility properties.
//
// Developers need peruse these only if they are curious exactly why they can or
// cannot match an element, as the Accessibility Inspector always shows
// the ground truth: an element can be matched only if the Inspector displays
// that element's information when the element is tapped upon.

#pragma mark - Children of accessible elements

- (void)testCannotMatchDescendantOfAccessibleElement {
    SLElement *otherView = [SLElement elementWithAccessibilityLabel:@"parentView"];
    SLAssertTrue([otherView isValid], @"Should be able to match the parent view.");

    SLElement *uiControlDescendant = [SLElement elementWithAccessibilityLabel:@"childView"];
    SLAssertFalse([uiControlDescendant isValid], @"Should not be able to match descendant of accessible element.");
}

#pragma mark - Table views

// note that we're not really matching the textLabel here,
// but rather the table view cell, which takes its label from its textLabel's text
// see testCannotMatchIndividualChildLabelsOfTableViewCell
- (void)testMatchingTableViewCellTextLabel {
    SLElement *fooLabel = [SLElement elementWithAccessibilityLabel:@"fooLabel"];
    SLAssertTrue([[UIAElement(fooLabel) label] isEqualToString:@"fooLabel"],
                 @"Could not match standard UITableViewCell child element.");
}

// as recommended by the "Enhancing the Accessibility of Table View Cells" document
// http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html#//apple_ref/doc/uid/TP40008785-CH102-SW3
// note that it appears that table view cells will combine sub-labels automatically anyway
- (void)testMatchingTableViewCellWithCombinedLabel {
    SLElement *currentWeatherCell = [SLElement elementWithAccessibilityLabel:@"city, temp"];
    SLAssertTrue([[UIAElement(currentWeatherCell) label] isEqualToString:@"city, temp"],
                 @"Could not match UITableViewCell with accessibility label combined from child elements' labels.");
}

// combining sublabels' accessibilityLabels appears to be done automatically,
// despite the document linked above, and child labels cannot be matched individually
// --UIAccessibility does not represent such labels within tableviews' accessibility hierarchies
- (void)testCannotMatchIndividualChildLabelsOfTableViewCell {
    SLElement *currentWeatherCell = [SLElement elementWithAccessibilityLabel:@"city, temp"];
    SLAssertTrue([[UIAElement(currentWeatherCell) label] isEqualToString:@"city, temp"],
                 @"Could not match UITableViewCell with accessibility label combined from child elements' labels.");

    SLElement *cityLabel = [SLElement elementWithAccessibilityLabel:@"city"];
    SLAssertFalse([cityLabel isValid], @"Should not be able to match individual child label.");
}

// matching child elements may be done on a per-element basis (e.g. controls)
// the Accessibility Inspector reports the ground truth
- (void)testMatchingNonLabelTableViewCellChildElement {
    SLElement *fooSwitch = [SLElement elementWithAccessibilityLabel:@"fooSwitch"];
    SLAssertTrue([[UIAElement(fooSwitch) label] isEqualToString:@"fooSwitch"], @"Could not match custom UITableViewCell child element.");
}

- (void)testMatchingTableViewHeader {
    SLElement *fooHeader = [SLElement elementWithAccessibilityLabel:@"fooHeader"];
    SLAssertTrue([[UIAElement(fooHeader) label] isEqualToString:@"fooHeader"],
                 @"Could not match UITableView header.");
}

// in order to exercise a particular (prior) bug in Subliminal,
// it's important that the header contain two views
- (void)testMatchingTableViewHeaderChildElements {
    SLElement *leftLabel = [SLElement elementWithAccessibilityLabel:@"left"];
    SLAssertTrue([[UIAElement(leftLabel) label] isEqualToString:@"left"],
                 @"Could not match UITableView header child element.");

    SLElement *rightLabel = [SLElement elementWithAccessibilityLabel:@"right"];
    SLAssertTrue([rightLabel isValid], @"Could not match UITableView header child element.");
}

#pragma mark - Web views

// This test case is restricted to the iPhone to guarantee the properties of
// the elements tested, because it uses mobile-optimized HTML.
- (void)testMatchingWebViewChildElements_iPhone {
    SLElement *openMenuLink = [SLElement elementMatching:^BOOL(NSObject *obj) {
        // below iOS 7, the value of a link tag's `title` attribute would become the `accessibilityHint`
        // of its corresponding accessibility element
        // at or above iOS 7, when the link tag is empty, the attribute's value becomes the `accessibilityLabel` of the element
        // and there is no hint (see for comparison the memorabilia link below)
        NSString *openMenuLinkTitle = @"Open main menu";
        if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
            return [obj.accessibilityLabel isEqualToString:openMenuLinkTitle];
        } else {
            return [obj.accessibilityHint isEqualToString:openMenuLinkTitle];
        }
    } withDescription:@"Open main menu link"];
    
    CGRect expectedOpenMenuLinkFrame = CGRectMake(0.0f, 63.0f, 40.0f, 46.0f);
    CGRect actualOpenMenuLinkFrame = [UIAElement(openMenuLink) rect];
    BOOL openMenuLinkFrameMatches = CGRectEqualToRect(actualOpenMenuLinkFrame, expectedOpenMenuLinkFrame);
    if (!openMenuLinkFrameMatches) {
        // the y-origin wavers depending on the device
        expectedOpenMenuLinkFrame.origin.y = 64.0f;
        openMenuLinkFrameMatches = CGRectEqualToRect(actualOpenMenuLinkFrame, expectedOpenMenuLinkFrame);
    }
    SLAssertTrue(openMenuLinkFrameMatches, @"Could not match element in webview.");

    SLElement *searchField = [SLElement elementWithAccessibilityLabel:nil value:@"Search Wikipedia" traits:0];
    SLAssertTrue([[UIAElement(searchField) value] isEqualToString:@"Search Wikipedia"],
                  @"Could not match element in webview.");

    SLElement *title = [SLElement elementWithAccessibilityLabel:@"Inklings"];
    SLAssertTrue([[UIAElement(title) label] isEqualToString:@"Inklings"],
                 @"Could not match element in webview.");

    // below iOS 7, a link tag's contents would become the `accessibilityLabel` of its corresponding
    // accessibility element, full stop.
    // at or above iOS 7, if a link tag is non-empty _and_ the link tag has a non-empty `title` attribute,
    // the value of that attribute gets tacked onto the end of the label (and then separately also becomes
    // the `accessibilityHint` of the element).
    NSString *memorabiliaLabel = @"memorabilia";
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
        memorabiliaLabel = [memorabiliaLabel stringByAppendingString:@", Memorabilia"];
    }
    SLElement *memorabiliaLink = [SLElement elementWithAccessibilityLabel:memorabiliaLabel];
    SLAssertTrue([[UIAElement(memorabiliaLink) label] isEqualToString:memorabiliaLabel],
                 @"Could not match element in webview.");
}

#pragma mark - Popovers

// Popovers are only available on the iPad.
- (void)testMatchingPopoverChildElement_iPad {
    SLAskApp(showPopover);

    SLElement *fooButtonInPopover = [SLElement elementWithAccessibilityLabel:@"fooInPopover"];
    SLAssertTrue([[UIAElement(fooButtonInPopover) label] isEqualToString:@"fooInPopover"],
                 @"Could not match button in popover.");
}

#pragma mark - Tab bar buttons

- (void)testMatchingTabBarButtons {
    NSString *actualLabel, *expectedLabel = @"Favorites";
    SLButton *favoritesButton = [SLButton elementWithAccessibilityLabel:expectedLabel];
    SLAssertNoThrow(actualLabel = [UIAElement(favoritesButton) label], @"Could not retrieve button's label.");
    SLAssertTrue([actualLabel isEqualToString:expectedLabel], @"Did not match button as expected.");
}

#pragma mark - Action sheets

- (void)testMatchingActionSheetButtons {
    SLAskApp(showActionSheet);

    NSString *actualLabel, *expectedLabel = @"Cancel";
    SLButton *cancelButton = [SLButton elementWithAccessibilityLabel:expectedLabel];
    SLAssertNoThrow(actualLabel = [UIAElement(cancelButton) label], @"Could not retrieve button's label.");
    SLAssertTrue([actualLabel isEqualToString:expectedLabel], @"Did not match button as expected.");
}

// Somewhat of an internal test--when a popover shows an action sheet,
// that changes the popover's accessibility structure in a way that
// once caused Subliminal to misidentify the action sheet
- (void)testMatchingButtonsOfActionSheetsInPopovers_iPad {
    SLAskApp(showPopoverWithActionSheet);

    NSString *actualLabel, *expectedLabel = @"Popover Cancel";
    SLButton *cancelButton = [SLButton elementWithAccessibilityLabel:expectedLabel];
    SLAssertNoThrow(actualLabel = [UIAElement(cancelButton) label], @"Could not retrieve button's label.");
    SLAssertTrue([actualLabel isEqualToString:expectedLabel], @"Did not match button as expected.");
}

#pragma mark - Internal tests

// Subliminal replaces the accessibility identifiers of objects in the accessibility
// hierarchy above the matched object while communicating with UIAutomation
// (in order to uniquely identify the elements) but restores them afterward.
- (void)testSubliminalOnlyReplacesAccessibilityIdentifiersOfElementsInvolvedInMatch {
    NSString *originalFooIdentifier = SLAskApp(fooButtonIdentifier);
    NSString *originalBarIdentifier = SLAskApp(barButtonIdentifier);

    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLElement *barButton = [SLElement elementWithAccessibilityLabel:@"bar"];

    // Sanity check
    SLAssertTrue([[UIAElement(fooButton) label] isEqualToString:@"foo"],
                 @"Should have matched the button with label 'foo'.");
    SLAssertTrue([[UIAElement(barButton) label] isEqualToString:@"bar"],
                 @"Should have matched the button with label 'bar'.");

    [fooButton waitUntilTappable:NO
               thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        SLAssertFalse([SLAskApp(fooButtonIdentifier) isEqualToString:originalFooIdentifier],
                      @"While matched, an object's identifier is replaced.");
        SLAssertTrue([SLAskApp(barButtonIdentifier) isEqualToString:originalBarIdentifier],
                     @"If an object is not involved in the hierarchy of a matched object, \
                     its identifier should not be replaced, even if it is of the same type.");
    } timeout:[SLElement defaultTimeout]];
}

- (void)testSubliminalRestoresAccessibilityIdentifiersAfterMatching {
    NSString *originalIdentifier = SLAskApp(fooButtonIdentifier);

    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];

    // Sanity check
    SLAssertTrue([[UIAElement(fooButton) label] isEqualToString:@"foo"],
                 @"Should have matched the button with label 'foo'.");

    [fooButton waitUntilTappable:NO
               thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        SLAssertFalse([SLAskApp(fooButtonIdentifier) isEqualToString:originalIdentifier],
                      @"While matched, an object's identifier is replaced.");
    } timeout:[SLElement defaultTimeout]];

    SLAssertTrue([SLAskApp(fooButtonIdentifier) isEqualToString:originalIdentifier],
                 @"After being matched, an object's identifier should have been restored.");
}

- (void)testSubliminalRestoresAccessibilityIdentifiersAfterMatchingEvenIfActionThrows {
    NSString *originalIdentifier = SLAskApp(fooButtonIdentifier);

    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];

    // Sanity check
    SLAssertTrue([[UIAElement(fooButton) label] isEqualToString:@"foo"],
                 @"Should have matched the button with label 'foo'.");

    SLAssertThrows([fooButton waitUntilTappable:NO
                              thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        SLAssertFalse([SLAskApp(fooButtonIdentifier) isEqualToString:originalIdentifier],
                      @"While matched, an object's identifier is replaced.");
        [NSException raise:@"TestException" format:nil];
    } timeout:[SLElement defaultTimeout]], @"Should have thrown test exception.");

    SLAssertTrue([SLAskApp(fooButtonIdentifier) isEqualToString:originalIdentifier],
                 @"After being matched, an object's identifier should have been restored.");
}

- (void)testSubliminalReloadsTheAccessibilityHierarchyAsNecessaryWhenMatching {
    SLElement *fooLabel = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[UIAElement(fooLabel) label] isEqualToString:@"foo"], @"Could not match label.");

    SLAskApp(invalidateAccessibilityHierarchy);

    SLAssertTrue([[UIAElement(fooLabel) label] isEqualToString:@"foo"], @"Could not match label.");
}

@end
