//
//  SLPopoverTest.m
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
