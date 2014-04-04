//
//  SLTableViewCellChildElementsTest.m
//  Subliminal
//
//  Created by Jordan Zucker on 3/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface focus_SLTableViewCellChildElementsTest : SLIntegrationTest

@end

@implementation focus_SLTableViewCellChildElementsTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTableViewCellChildElementsTestViewController";
}

// If you override set-up methods,
// you must call super at the beginning of your implementations.

// If you override tear-down methods,
// you must call super at the *end* of your implementations.

- (void)testTapBroadMatchingTableViewCellButton {
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];

    SLButton *favoriteButton = [SLButton elementWithAccessibilityLabel:@"Favorite"];
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
}

- (void)testMatchingTableViewCellByMatchingTableViewCellAndTableView
{
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    SLButton *favoriteButton = [SLButton elementMatching:^BOOL(NSObject *obj) {

        if ([obj.accessibilityLabel isEqualToString:@"Favorite"]) {

            id accessibilityParent = [obj slAccessibilityParent];

            while (accessibilityParent && ![[accessibilityParent accessibilityLabel] isEqualToString:@"Cell 2"]) {

                accessibilityParent = [accessibilityParent slAccessibilityParent];

            }


            id doubleAccessibilityParent = [accessibilityParent slAccessibilityParent];

            while (doubleAccessibilityParent && ![doubleAccessibilityParent isKindOfClass:[UITableView class]]) {
                doubleAccessibilityParent = [doubleAccessibilityParent slAccessibilityParent];
            }

            if (doubleAccessibilityParent) {
                return YES;
            }
            else {
                return NO;
            }


        }

        return NO;

    } withDescription:@"searching for favoritebutton"];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
}

- (void)testMatchingTableViewCellWithAccessibilityContainerMethod
{
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    SLAccessibilityContainer *tableViewCell = [SLAccessibilityContainer containerWithLabel:@"Cell 2" andContainerType:SLTableViewAccessibilityContainer];
    SLButton *favoriteButton = [tableViewCell childElementMatching:[SLButton elementWithAccessibilityLabel:@"Favorite"]];

    SLLogAsync(@"favoriteButton.value is %@", UIAElement(favoriteButton.value));

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    [UIAElement(favoriteButton) isValidAndVisible];

    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
}

- (void)testMatchingTableViewCellWithTableViewCellMethodSubclass
{
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    SLTableViewCell *tableViewCell = [SLTableViewCell tableViewCellWithLabel:@"Cell 2"];
    SLButton *favoriteButton = [tableViewCell childElementMatching:[SLButton elementWithAccessibilityLabel:@"Favorite"]];

    SLLogAsync(@"favoriteButton.value is %@", UIAElement(favoriteButton.value));

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    [UIAElement(favoriteButton) isValidAndVisible];

    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
}

- (void)testMatchingTableViewCellWithTableViewCellMethodSubclassIndex
{
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    SLTableViewCell *tableViewCell = [SLTableViewCell tableViewCellAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    SLButton *favoriteButton = [tableViewCell childElementMatching:[SLButton elementWithAccessibilityLabel:@"Favorite"]];

    SLLogAsync(@"favoriteButton.value is %@", UIAElement(favoriteButton.value));

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    [UIAElement(favoriteButton) isValidAndVisible];

    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
}

@end
