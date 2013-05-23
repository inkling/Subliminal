//
//  SLElementMatchingTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
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
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    if (testCaseSelector == @selector(testMatchingPopoverChildElement_iPad)) {
        SLAskApp(hidePopover);
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
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < SLUIAElementWaitRetryDelay,
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
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
    SLAssertTrue(ABS(actualWaitTimeInterval - expectedWaitTimeInterval) < SLUIAElementWaitRetryDelay,
                 @"Test waited for %g but should not have waited appreciably longer or shorter than %g.",
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
    SLSearchBar *anySearchBar = [SLSearchBar anyElement];
    SLAssertTrue([[UIAElement(anySearchBar) text] isEqualToString:@"barText"],
                 @"SLSearchBar should have matched the search bar onscreen.");
}

#pragma mark - UIControls

- (void)testCannotMatchUIControlDescendant {
    SLElement *uiControl = [SLElement elementWithAccessibilityIdentifier:@"fooUIControl"];
    SLAssertTrue([uiControl isValid], @"Should be able to match the UIControl");

    SLElement *uiControlDescendant = [SLElement elementWithAccessibilityLabel:@"fooTestView"];
    SLAssertFalse([uiControlDescendant isValid], @"Should not be able to match descendant of UIControl.");
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
        return [obj.accessibilityHint isEqualToString:@"Open main menu"];
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

    SLElement *memorabiliaLink = [SLElement elementWithAccessibilityLabel:@"memorabilia"];
    SLAssertTrue([[UIAElement(memorabiliaLink) label] isEqualToString:@"memorabilia"],
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

@end
