//
//  SLNavigationBarTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLNavigationBarTest : SLIntegrationTest

@end

@implementation SLNavigationBarTest {
    NSString *_leftButtonTitle, *_rightButtonTitle;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLNavigationBarTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if (testCaseSelector == @selector(testCurrentNavigationBarMatchesFrontmostNavigationBar_iPad)) {
        SLAskApp(presentBarInFormSheet);
    } else if (testCaseSelector == @selector(testCanMatchLeftButton)) {
        // replace the nav bar back button with our own left button so we can control the title
        // (the navigation bar might replace the back button's title with "Back" if space is tight)
        _leftButtonTitle = @"Test";
        SLAskApp1(addLeftButtonWithTitle:, _leftButtonTitle);
    } else if (testCaseSelector == @selector(testLeftButtonIsInvalidIfThereIsNoLeftButton)) {
        // The regular nav bar's left button is the automatic "Back" button.
        SLAskApp(presentBarWithoutLeftButton);
    } else if (testCaseSelector == @selector(testCanMatchRightButton)) {
        _rightButtonTitle = @"Test";
        SLAskApp1(addRightButtonWithTitle:, _rightButtonTitle);
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    if (testCaseSelector == @selector(testCurrentNavigationBarMatchesFrontmostNavigationBar_iPad)) {
        SLAskApp(dismissBarInFormSheet);
    } else if (testCaseSelector == @selector(testLeftButtonIsInvalidIfThereIsNoLeftButton)) {
        SLAskApp(dismissBarWithoutLeftButton);
    }
    
    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)testCanMatchNavigationBar {
    CGRect navigationBarRect, expectedNavigationBarRect = [SLAskApp(navigationBarFrameValue) CGRectValue];
    SLAssertNoThrow(navigationBarRect = [[SLNavigationBar currentNavigationBar] rect],
                    @"The navigation bar should exist.");
    SLAssertTrue(CGRectEqualToRect(navigationBarRect, expectedNavigationBarRect),
                 @"The navigation bar's frame does not match the expected navigation bar frame.");
}

// it's only likely that there would be multiple navigation bars visible
// when a view controller is modally presented on the iPad
- (void)testCurrentNavigationBarMatchesFrontmostNavigationBar_iPad {
    NSString *actualTitle, *expectedTitle = @"Child VC";
    SLAssertNoThrow(actualTitle = [[SLNavigationBar currentNavigationBar] title],
                    @"Should have been able to retrieve the title of the frontmost navigation bar.");
    SLAssertTrue([actualTitle isEqualToString:expectedTitle],
                 @"Title of frontmost navigation bar was not equal to expected value.");
}

- (void)testCanReadTitle {
    NSString *expectedNavigationBarTitle = NSStringFromSelector(_cmd);
    NSString *actualNavigationBarTitle = [[SLNavigationBar currentNavigationBar] title];
    SLAssertTrue([actualNavigationBarTitle isEqualToString:expectedNavigationBarTitle],
                 @"The navigation bar's title was not equal to the expected value.");
}

- (void)testCanMatchLeftButton {
    NSString *actualLeftButtonTitle, *expectedLeftButtonTitle = _leftButtonTitle;
    SLAssertNoThrow(actualLeftButtonTitle = [[[SLNavigationBar currentNavigationBar] leftButton] label],
                    @"Should have been able to retrieve the title of the navigation bar's left button.");
    SLAssertTrue([actualLeftButtonTitle isEqualToString:expectedLeftButtonTitle],
                 @"The navigation bar's left button did not have the expected title.");
}

- (void)testLeftButtonIsInvalidIfThereIsNoLeftButton {
    BOOL leftButtonIsValid = NO;
    SLAssertNoThrow(leftButtonIsValid = [[[SLNavigationBar currentNavigationBar] leftButton] isValid],
                    @"It should have been safe to access the navigation bar's left button even though the button doesn't exist.");
    SLAssertFalse(leftButtonIsValid,
                  @"The navigation bar's left button should be invalid.");
}

- (void)testCanMatchRightButton {
    NSString *actualRightButtonTitle, *expectedRightButtonTitle = _rightButtonTitle;
    SLAssertNoThrow(actualRightButtonTitle = [[[SLNavigationBar currentNavigationBar] rightButton] label],
                    @"Should have been able to retrieve the title of the navigation bar's right button.");
    SLAssertTrue([actualRightButtonTitle isEqualToString:expectedRightButtonTitle],
                 @"The navigation bar's right button did not have the expected title.");
}

- (void)testRightButtonIsInvalidIfThereIsNoRightButton {
    BOOL rightButtonIsValid = NO;
    SLAssertNoThrow(rightButtonIsValid = [[[SLNavigationBar currentNavigationBar] rightButton] isValid],
                    @"It should have been safe to access the navigation bar's right button even though the button doesn't exist.");
    SLAssertFalse(rightButtonIsValid,
                  @"The navigation bar's right button should be invalid.");
}

@end
