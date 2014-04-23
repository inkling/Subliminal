//
//  SLNavigationBarTests.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/4/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLNavigationBarTests : SLIntegrationTest

@end

@implementation SLNavigationBarTests

+ (NSString *)testCaseViewControllerClassName {
    return @"SLNavigationBarTestsViewController";
}

// If you override set-up methods,
// you must call super at the beginning of your implementations.

// If you override tear-down methods,
// you must call super at the *end* of your implementations.

- (void)testRightButtonBroadMatching {
    SLButton *rightButton = [SLButton elementWithAccessibilityLabel:@"Right"];
    SLAssertTrue([UIAElement(rightButton) isValidAndVisible], @"Right button didn't appear");

    [UIAElement(rightButton) tap];
}

- (void)testRightButtonWithNewMethod
{
    SLAccessibilityContainer *navBar = [SLAccessibilityContainer containerWithIdentifier:@"NavigationBar" andContainerType:SLAccessibilityContainerTypeNavigationBar];
    SLLogAsync(@"navBar is %@", navBar);
    SLAssertTrue([UIAElement(navBar) isValidAndVisible], @"Couldn't find nav bar matching specifications");
    SLButton *rightButton = [navBar childElementMatching:[SLButton elementWithAccessibilityLabel:@"Right"]];
    SLAssertTrue([UIAElement(rightButton) isValidAndVisible], @"Couldn't find right button bar");

    [UIAElement(rightButton) tap];

}

- (void)testTitleLabel
{
    SLAccessibilityContainer *navBar = [SLAccessibilityContainer containerWithIdentifier:@"NavigationBar" andContainerType:SLAccessibilityContainerTypeNavigationBar];
    SLLogAsync(@"navBar is %@", navBar);
    SLAssertTrue([UIAElement(navBar) isValidAndVisible], @"Couldn't find nav bar matching specifications");
    SLElement *title = [navBar childElementMatching:[SLElement elementWithAccessibilityLabel:@"Testing" value:nil traits:UIAccessibilityTraitStaticText]];
    SLAssertTrue([UIAElement(title) isValidAndVisible], @"title isn't valid and visible");
    SLLogAsync(@"title is %@", title.label);
    SLAssertTrue([UIAElement(title.label) isEqualToString:@"Testing"], @"title doesn't match expected string");

}

@end
