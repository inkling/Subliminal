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
//    SLLogAsync(@"favoritButton is %@", favoriteButton);
//    SLLogAsync(@"favoriteButton recursive is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];


//    SLLogAsync(@"testing");
//    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    SLLogAsync(@"now log element tree for favorite button");
//    [favoriteButton logElementTree];
}

//- (void)testOriginalHackMatchingTableViewCell
//{
////    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    SLButton *favoriteButton = [SLButton elementMatching:^BOOL(NSObject *obj) {
//
//        if ([obj.accessibilityLabel isEqualToString:@"Favorite"]) {
//
//            id accessibilityParent = [obj slAccessibilityParent];
//
//            //SLLogAsync(@"starting: accessibilityParent is %@", accessibilityParent);
//            while (accessibilityParent && ![NSStringFromClass([accessibilityParent class]) isEqualToString:@"UITableViewCellAccessibilityElement"]) {
//
//                accessibilityParent = [accessibilityParent slAccessibilityParent];
//                //SLLogAsync(@"get accessibilityParent that is now %@", accessibilityParent);
//
//            }
//
//            //SLLogAsync(@"[accessibilityParent accessibilityLabel] is %@", [accessibilityParent accessibilityLabel]);
//            return [[accessibilityParent accessibilityLabel] isEqualToString:@"Cell 2"];
//
//        }
//
//        return NO;
//
//    } withDescription:@"searching for favoritebutton"];
//
////    SLLogAsync(@"favoriteButton is %@", favoriteButton);
////
////    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [favoriteButton isValidAndVisible]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
////    SLLogAsync(@"testing");
////    SLLogAsync(@"favoriteButton is %@", favoriteButton);
////    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
////    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
////    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
////    SLLogAsync(@"now log element tree for favorite button");
//    [favoriteButton logElementTree];
//
//
//}

//- (void)testOriginalHackMatchingTableViewCellWithNoAXMatching
//{
////    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    SLButton *favoriteButton = [SLButton elementMatching:^BOOL(NSObject *obj) {
//
//        if ([obj.accessibilityLabel isEqualToString:@"Favorite"]) {
//
//            id accessibilityParent = [obj slAccessibilityParent];
//
//            //SLLogAsync(@"starting: accessibilityParent is %@", accessibilityParent);
//            while (accessibilityParent && (![accessibilityParent isKindOfClass:[UITableViewCell class]] || ![NSStringFromClass([accessibilityParent class]) isEqualToString:@"UITableViewCellAccessibilityElement"])) {
//
//                accessibilityParent = [accessibilityParent slAccessibilityParent];
//                //SLLogAsync(@"get accessibilityParent that is now %@", accessibilityParent);
//
//            }
//
//            //SLLogAsync(@"[accessibilityParent accessibilityLabel] is %@", [accessibilityParent accessibilityLabel]);
//            return [[accessibilityParent accessibilityLabel] isEqualToString:@"Cell 2"];
//
//        }
//
//        return NO;
//
//    } withDescription:@"searching for favoritebutton"];
//
//    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//
//    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    //SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    //SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    SLLogAsync(@"testing");
//    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    SLLogAsync(@"now log element tree for favorite button");
//    [favoriteButton logElementTree];
//
//
//}

- (void)testMatchingTableViewCellByMatchingTableViewCellAndTableView
{
//    [[SLWindow mainWindow] logElementTree];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    SLButton *favoriteButton = [SLButton elementMatching:^BOOL(NSObject *obj) {

        if ([obj.accessibilityLabel isEqualToString:@"Favorite"]) {

            id accessibilityParent = [obj slAccessibilityParent];

            //SLLogAsync(@"starting: accessibilityParent is %@", accessibilityParent);
            while (accessibilityParent && ![[accessibilityParent accessibilityLabel] isEqualToString:@"Cell 2"]) {

                accessibilityParent = [accessibilityParent slAccessibilityParent];
                //SLLogAsync(@"get accessibilityParent that is now %@", accessibilityParent);

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

//    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//
//    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
    
    
//    SLLogAsync(@"testing");
//    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    SLLogAsync(@"now log element tree for favorite button");
//    [favoriteButton logElementTree];

    
}

- (void)testMatchingTableViewCellWithNewMethod
{
    //    [[SLWindow mainWindow] logElementTree];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
    //SLAccessibilityParent *cell2 = [SLAccessibilityParent elementWithAccessibilityLabel:@"Cell 2"];
    //SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"]];
    //SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"] andParentType:SLTableViewCellElement];
//    SLAccessibilityParent *cell2 = [SLAccessibilityParent elementWithAccessibilityLabel:@"Cell 2"];
//    cell2.parentElementType = SLTableViewCellElement;
//    //SLElementDescriptor *favoriteDescriptor = [SLElementDescriptor descriptorWithLabel:@"Favorite"];
//    SLButton *matchingFavoriteButton = [SLButton elementWithAccessibilityLabel:@"Favorite"];
//    SLElement *favoriteButton = [cell2 achildElementMatching:matchingFavoriteButton];
    SLAccessibilityContainer *tableViewCell = [SLAccessibilityContainer containerWithLabel:@"Cell 2" andContainerType:SLTableViewAccessibilityContainer];
    SLButton *favoriteButton = [tableViewCell childElementMatching:[SLButton elementWithAccessibilityLabel:@"Favorite"]];

    SLLogAsync(@"favoriteButton.value is %@", UIAElement(favoriteButton.value));

    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
    //
    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];

    [UIAElement(favoriteButton) tap];

    [self wait:1];
    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];

    [UIAElement(favoriteButton) isValidAndVisible];

    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
    [UIAElement(favoriteButton) tap];

    [self wait:1];

    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];


    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];


    //    SLLogAsync(@"testing");
    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
    //    SLLogAsync(@"now log element tree for favorite button");
    //    [favoriteButton logElementTree];
    
    
}


//- (void)testMatchingTableViewCellWithNewMethod
//{
//    //    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    //SLAccessibilityParent *cell2 = [SLAccessibilityParent elementWithAccessibilityLabel:@"Cell 2"];
//    //SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"]];
//    SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"] andParentType:SLTableViewCellElement];
//    SLElementDescriptor *favoriteDescriptor = [SLElementDescriptor descriptorWithLabel:@"Favorite"];
//    SLElement *favoriteButton = [cell2 childElementMatching:favoriteDescriptor];
//
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //
//    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    //    SLLogAsync(@"testing");
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    //    SLLogAsync(@"now log element tree for favorite button");
//    //    [favoriteButton logElementTree];
//    
//    
//}

//- (void)testMatchingTableViewCellWithNewMethodTVCSubclass
//{
//    //    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    //SLAccessibilityParent *cell2 = [SLAccessibilityParent elementWithAccessibilityLabel:@"Cell 2"];
//    //SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"]];
//    //SLAccessibilityParent *cell2 = [SLAccessibilityParent parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"] andParentType:SLTableViewCellElement];
//    SLTableViewCell *cell2 = [SLTableViewCell parentWithDescriptor:[SLElementDescriptor descriptorWithLabel:@"Cell 2"]];
//    SLElementDescriptor *favoriteDescriptor = [SLElementDescriptor descriptorWithLabel:@"Favorite"];
//    SLElement *favoriteButton = [cell2 childElementMatching:favoriteDescriptor];
//
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //
//    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    //    SLLogAsync(@"testing");
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    //    SLLogAsync(@"now log element tree for favorite button");
//    //    [favoriteButton logElementTree];
//    
//    
//}


//- (void)testMatchingTableViewCellWithNewMethod
//{
//    //    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    SLButton *favoriteButton = [SLButton elementWithAccessibilityLabel:@"Favorite" value:nil traits:UIAccessibilityTraitButton inTableViewCellWithLabel:@"Cell 2" andValue:nil];
//
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //
//    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    //    SLLogAsync(@"testing");
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    //    SLLogAsync(@"now log element tree for favorite button");
//    //    [favoriteButton logElementTree];
//    
//    
//}

//- (void)testMatchingTableViewCellWithNewMethodAnyTraits
//{
//    //    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    SLButton *favoriteButton = [SLButton elementWithAccessibilityLabel:@"Favorite" value:nil traits:SLUIAccessibilityTraitAny inTableViewCellWithLabel:@"Cell 2" andValue:nil];
//
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //
//    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    //    SLLogAsync(@"testing");
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    //    SLLogAsync(@"now log element tree for favorite button");
//    //    [favoriteButton logElementTree];
//    
//    
//}

//- (void)testMatchingTableViewCellWithNewMethodAnyTraitsAndElement
//{
//    //    [[SLWindow mainWindow] logElementTree];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"start"];
//    SLElement *favoriteButton = [SLElement elementWithAccessibilityLabel:@"Favorite" value:nil traits:SLUIAccessibilityTraitAny inTableViewCellWithLabel:@"Cell 2" andValue:nil];
//
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //
//    //    SLLogAsync(@"favoriteButton isValidAndVisible is %d", [UIAElement(favoriteButton) isValidAndVisible]);
//    //    SLLogAsync(@"favoriteButton value is %@", [UIAElement(favoriteButton) value]);
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not originally off");
//    //    SLLogAsync(@"favoriteButton isValid is %d", [UIAElement(favoriteButton) isValid]);
//    //    SLLogAsync(@"favoriteButton isVisible is %d", [UIAElement(favoriteButton) isVisible]);
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: starting"];
//
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"after tap"];
//    [favoriteButton captureScreenshotWithFilename:@"fb: after first tap"];
//
//    //SLButton *unfavoriteButton = [SLButton elementWithAccessibilityLabel:@"Unfavorite"];
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"favorite button is not valid and visible after first time tapping");
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"on"], @"Favorite button does not has ax value of on");
//    [UIAElement(favoriteButton) tap];
//
//    [self wait:1];
//
//    SLAssertTrue([UIAElement(favoriteButton.value) isEqualToString:@"off"], @"favorite button is not off at end of test");
//    SLAssertTrue([UIAElement(favoriteButton) isValidAndVisible], @"Favorite button is not valid and visible");
//    [favoriteButton captureScreenshotWithFilename:@"fb: ending"];
//
//
//    [[SLDevice currentDevice] captureScreenshotWithFilename:@"end of test"];
//
//
//    //    SLLogAsync(@"testing");
//    //    SLLogAsync(@"favoriteButton is %@", favoriteButton);
//    //    SLLogAsync(@"favoriteButton description is %@", [favoriteButton slAccessibilityDescription]);
//    //    SLLogAsync(@"favoriteButton parent is %@", [favoriteButton slAccessibilityParent]);
//    //    SLLogAsync(@"favoriteButton recursive description is %@", [favoriteButton slRecursiveAccessibilityDescription]);
//    //    SLLogAsync(@"now log element tree for favorite button");
//    //    [favoriteButton logElementTree];
//    
//    
//}


@end
