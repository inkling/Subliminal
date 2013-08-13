//
//  SLStatusBarTest.m
//  Subliminal
//
//  Created by Leon Jiang on 8/12/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLStatusBarTest : SLIntegrationTest
@end

@implementation SLStatusBarTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLStatusBarTestViewController";
}

- (void)testMatchStatusBar {
    SLStatusBar *statusBar = [SLStatusBar statusBar];
    CGRect statusBarRect = [statusBar rect];
    CGRect expectedStatusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    SLAssertTrue(CGRectEqualToRect(statusBarRect, expectedStatusBarRect), @"Element's frame does not match the expected status bar frame");
}

- (void)testScrollToTop {
    // Make sure the labels start out the way we expect (top is visible, bottom is not).
    SLElement *topLabel = [SLElement elementWithAccessibilityLabel:@"Top"];
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertTrue([UIAElement(topLabel) isVisible], @"Top label should be visible at this point in the test.");
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"Bottom label should not be visible at this point in the test.");
    
    [bottomLabel scrollToVisible];
    
    SLAssertTrueWithTimeout([UIAElement(topLabel) isInvalidOrInvisible], 3.0, @"The top label failed to become invisible after scrolling.");
    SLAssertTrueWithTimeout([UIAElement(bottomLabel) isValidAndVisible], 3.0, @"The bottom label failed to become visible after scrolling.");
    SLStatusBar *statusBar = [SLStatusBar statusBar];
    [UIAElement(statusBar) tap];
    
    SLAssertTrueWithTimeout([UIAElement(bottomLabel) isInvalidOrInvisible], 3.0, @"The bottom label failed to become invisible after scrolling.");
    SLAssertTrueWithTimeout([UIAElement(topLabel) isValidAndVisible], 3.0, @"The top label failed to become visible after scrolling.");
}


@end
