//
//  SLEditingMenuTest.m
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

@interface SLEditingMenuTest : SLIntegrationTest

@end

@implementation SLEditingMenuTest {
    SLEditingMenu *_menu;
    SLElement *_testText, *_otherText;
    NSString *_menuItemTitle;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLEditingMenuTestViewController";
}

+ (BOOL)supportsCurrentPlatform {
    // Don't run these tests on Travis, because the editing menu
    // intermittently fails to appear on Travis, while it consistently
    // appears in other environments.
    return [super supportsCurrentPlatform] && !getenv("TRAVIS");
}

- (void)setUpTest {
    [super setUpTest];

    _menu = [SLEditingMenu menu];

    _testText = [SLElement elementMatching:^BOOL(NSObject *obj) {
        return [obj.accessibilityLabel hasPrefix:@"A corner of the pub"];
    } withDescription:@"text element"];
    _otherText = [SLElement elementWithAccessibilityLabel:@"Inklings"];

    _menuItemTitle = @"Copy";
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0, @"Webview did not load test HTML.");

    if (testCaseSelector == @selector(testTapCustomMenuItem)) {
        // It's important that this item have the same title as a standard item
        // (see the implementation of `-[SLEditingMenuItem itemWithAccessibilityLabel:]`)
        SLAskApp1(installCustomMenuItemWithTitle:, _menuItemTitle);
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    // we never need to hide the editing menu because view controllers are not reused between tests
    // the view controller will automatically restore the standard menu items, too

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)showEditingMenu {
    [UIAElement(_testText) touchAndHoldWithDuration:1.0];

    // wait for editing menu to appear before proceeding
    static const NSTimeInterval kMenuAnimationDuration = 0.5;
    (void)SLWaitUntilTrue([UIAElement(_menu) isValidAndVisible], kMenuAnimationDuration);
}

- (void)testCanMatchEditingMenu {
    SLAssertFalse([UIAElement(_menu) isValidAndVisible], @"The editing menu should not be visible.");

    [self showEditingMenu];

    SLAssertTrue([UIAElement(_menu) isVisible], @"The editing menu should be visible.");
}

- (void)testTapMenuItem {
    [self showEditingMenu];

    SLEditingMenuItem *menuItem = [SLEditingMenuItem itemWithAccessibilityLabel:_menuItemTitle];
    SLAssertTrue([UIAElement(menuItem) isVisible], nil);
    SLAssertNoThrow([UIAElement(menuItem) tap], nil);

    // give a little bit of time for the responder to perform the menu item action to be received
    SLAssertTrueWithTimeout(SLAskAppYesNo(menuItemWasTapped), 0.2, @"The menu item should have been tapped.");
}

// Something of an internal test--see the implementation of `-[SLEditingMenuItem itemWithAccessibilityLabel:]`.
// It's important that the custom item have the same label as a standard item.
- (void)testTapCustomMenuItem {
    SLAssertNoThrow([self testTapMenuItem], @"Tapping the custom menu item did not work as expected.");
}

@end
