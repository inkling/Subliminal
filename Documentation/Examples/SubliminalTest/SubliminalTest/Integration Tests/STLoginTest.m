//
//  STLoginTest.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Subliminal/Subliminal.h>


@interface STLoginTest : SLTest
@end


@implementation STLoginTest {
    SLElement *_messageField;
    SLTextField *_usernameField, *_passwordField;
    SLElement *_submitButton;
    SLElement *_loginSpinner;
}

#pragma mark - Setup and Teardown

- (void)setUpTest {
    // set up elements common to all tests
    _usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
    _passwordField = [SLTextField elementWithAccessibilityLabel:@"password field"];
    _submitButton = [SLElement elementWithAccessibilityLabel:@"Submit"];
    _loginSpinner = [SLElement elementWithAccessibilityLabel:@"Logging in..."];
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    // ask STLoginViewController to clear the login UI between tests
    [[SLTestController sharedTestController] sendAction:@selector(resetLogin)];
}

#pragma mark - Tests

- (void)testLogInSucceedsWithUsernameAndPassword {
    NSString *username = @"Jeff", *password = @"foo";
    [UIAElement(_usernameField) setText:username];
    [UIAElement(_passwordField) setText:password];
    
    [UIAElement(_submitButton) tap];
    
    [UIAElement(_loginSpinner) waitUntilInvisibleOrInvalid:3.0];
    
    NSString *successMessage = [NSString stringWithFormat:@"Hello, %@!", username];
    SLAssertTrue([UIAElement([SLElement elementWithAccessibilityLabel:successMessage]) isValid], @"Log-in did not succeed.");

    // wait just so the user can see the welcome message,
    // before tear-down clears it
    [self wait:1.0];
}

- (void)testLogInFailsWithoutPassword {
    NSString *username = @"Jeff";
    [UIAElement(_usernameField) setText:username];

    [UIAElement(_submitButton) tap];

    // Check isValid first because isVisible is indeterminate if the element doesn't exist
    SLAssertFalse([_loginSpinner isValid] && [_loginSpinner isVisible],
                  @"The app should not try to login if the user doesn't provide a password.");

    SLElement *errorMessage = [SLElement elementWithAccessibilityLabel:@"Invalid username or password."];
    SLAssertTrue([UIAElement(errorMessage) isVisible],
                 @"Error message should be visible.");

    // wait just so the user can see the error message,
    // before tear-down clears it
    [self wait:1.0];
}

@end
