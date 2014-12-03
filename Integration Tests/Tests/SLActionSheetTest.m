//
//  SLActionSheetTest.m
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

// Popover action sheets are only supported on the iPad.
@interface SLActionSheetTest_iPad : SLIntegrationTest

@end

@implementation SLActionSheetTest_iPad

+ (NSString *)testCaseViewControllerClassName {
    return @"SLActionSheetTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(hideActionSheet);

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

// this test isn't very specific but we can't confirm
// any other attributes of the popover independent of UIAutomation
// testDismiss shows that we are actually manipulating the popover
- (void)testCanMatchActionSheet {
    SLAssertFalse([UIAElement([SLActionSheet currentActionSheet]) isValid],
                  @"There should not currently be any action sheets.");

    SLAskApp(showActionSheet);

    SLAssertTrue([UIAElement([SLActionSheet currentActionSheet]) isValid],
                 @"There should be an action sheet.");
    BOOL expectedActionSheetVisibility = SLAskAppYesNo(isActionSheetVisible);
    BOOL actualActionSheetVisibility = [UIAElement([SLActionSheet currentActionSheet]) isVisible];
    SLAssertTrue(expectedActionSheetVisibility == actualActionSheetVisibility,
                 @"The current action sheet had a mismatched visibility.");
}

- (void)testDismiss {
    SLAskApp(showActionSheet);

    SLAssertTrueWithTimeout(SLAskAppYesNo(isActionSheetVisible), 2.0, @"Action sheet should have become visible.");
    [UIAElement([SLActionSheet currentActionSheet]) dismiss];
    SLAssertFalse(SLAskAppYesNo(isActionSheetVisible), @"Action sheet should have been dismissed.");
}

- (void)testClickButtonAtIndex {
    SLAskApp(showActionSheet);

    SLAssertTrueWithTimeout(SLAskAppYesNo(isActionSheetVisible), 2.0, @"Action sheet should have become visible.");

    SLActionSheet *actionSheet = [SLActionSheet currentActionSheet];

    SLAssertTrue([UIAElement(actionSheet) isValid],
                 @"There should be an action sheet.");

    [UIAElement(actionSheet) clickButtonWithAccessibilityLabel:@"OK"];

    SLAssertFalse(SLAskAppYesNo(isActionSheetVisible), @"Action sheet should have been dismissed.");
}

@end
