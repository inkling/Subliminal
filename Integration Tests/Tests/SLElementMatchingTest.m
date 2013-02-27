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

- (void)testElementWithAccessibilityLabel {
    SLElement *fooButton = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([[fooButton value] isEqualToString:@"fooValue"], @"SLElement should have matched fooButton.");
}

- (void)testMatchingTableViewChildElement {
    SLElement *fooCell = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertTrue([fooCell isValid], @"Matching of UITableViewCell by label with SLElement failed.");
}

- (void)testTappingTableViewChildElement {
    SLElement *fooCell = [SLElement elementWithAccessibilityLabel:@"foo"];
    SLAssertNoThrow([UIAElement(fooCell) tap], @"An exception should not have been thrown tapping on the table view cell.");
}

@end
