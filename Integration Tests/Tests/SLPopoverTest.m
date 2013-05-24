//
//  SLPopoverTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

// Popovers are only supported on the iPad.
@interface SLPopoverTest_iPad : SLIntegrationTest

@end

@implementation SLPopoverTest_iPad

+ (NSString *)testCaseViewControllerClassName {
    return @"SLPopoverTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(hidePopover);

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

// this test isn't very specific but we can't confirm
// any other attributes of the popover independent of UIAutomation
// testDismiss shows that we are actually manipulating the popover
- (void)testCanMatchPopover {
    SLAssertFalse([UIAElement([SLPopover currentPopover]) isValid],
                 @"There should not currently be any popover.");

    SLAskApp(showPopover);

    SLAssertTrue([UIAElement([SLPopover currentPopover]) isValid],
                 @"There should be a popover.");
    BOOL expectedPopoverVisibility = SLAskAppYesNo(isPopoverVisible);
    BOOL actualPopoverVisibility = [UIAElement([SLPopover currentPopover]) isVisible];
    SLAssertTrue(expectedPopoverVisibility == actualPopoverVisibility,
                 @"The current popover did not match the expected object.");
}

- (void)testDismiss {
    SLAskApp(showPopover);

    SLAssertTrueWithTimeout(SLAskAppYesNo(isPopoverVisible), 2.0, @"Popover should have become visible.");
    [UIAElement([SLPopover currentPopover]) dismiss];
    SLAssertFalse(SLAskAppYesNo(isPopoverVisible), @"Popover should have been dismissed.");
}

@end
