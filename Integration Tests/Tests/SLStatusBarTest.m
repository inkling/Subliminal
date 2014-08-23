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
    SLAssertTrue([SLAskApp(contentOffsetY) floatValue] == 0.0f,
                 @"For the purposes of this test case, the scroll view should start at the top.");

    // Use a label just to scroll down.
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    // Sanity check.
    SLAssertFalse([UIAElement(bottomLabel) isVisible],
                  @"Bottom label should be off the bottom of the screen.");
    
    [UIAElement(bottomLabel) scrollToVisible];
    SLAssertTrue([SLAskApp(contentOffsetY) floatValue] > 0.0f,
                 @"App should have scrolled down.");

    SLStatusBar *statusBar = [SLStatusBar statusBar];
    [UIAElement(statusBar) tap];
    SLAssertTrueWithTimeout([SLAskApp(contentOffsetY) floatValue] == 0.0f, 2.0,
                            @"The app should have scrolled back to the top.");
    
    // The app can crash due to a bad-access exception in `UIScrollView`
    // if a scroll view is deallocated before it finishes scrolling to top in response to a scroll bar tap.
    // We should be totally to the top by now but Travis appears to be a little slower.
    [self wait:0.1];
}


@end
