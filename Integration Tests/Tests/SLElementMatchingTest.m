//
//  SLElementMatchingTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementMatchingTest : SLIntegrationTest

@end

@implementation SLElementMatchingTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementMatchingTestViewController";
}

- (void)testAnyElement {
    SLSearchBar *anySearchBar = [SLSearchBar anyElement];
    SLAssertTrue([[UIAElement(anySearchBar) text] isEqualToString:@"barText"], @"SLSearchBar should have matched the search bar onscreen.");
}

- (void)testElementWithAccessibilityLabel {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[UIAElement(fooButton) value] isEqualToString:@"fooValue"], @"SLElement should have matched the button onscreen.");
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

@end
