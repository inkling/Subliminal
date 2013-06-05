//
//  STLoginTest.m
//  SubliminalTest
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
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
    _loginSpinner = [SLElement elementWithAccessibilityIdentifier:@"Logging in..."];
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

    // using -isInvalidOrInvisible allows the spinner not to exist when we start waiting
    SLAssertTrueWithTimeout([UIAElement(_loginSpinner) isInvalidOrInvisible], 3.0, @"Log-in was not successful.");
    
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

    // we don't care if the login spinner is valid, so long as it's not visible
    SLAssertFalse([_loginSpinner isValidAndVisible],
                  @"The app should not try to login if the user doesn't provide a password.");

    SLElement *errorMessage = [SLElement elementWithAccessibilityLabel:@"Invalid username or password."];
    SLAssertTrue([UIAElement(errorMessage) isVisible],
                 @"Error message should be visible.");

    // wait just so the user can see the error message,
    // before tear-down clears it
    [self wait:1.0];
}

@end
