//
//  STLoginTest.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "STLoginTest.h"

#import "STLoginManager.h"

#import <OCMock/OCMock.h>

@implementation STLoginTest {
    SLElement *_messageField;
    SLTextField *_usernameField, *_passwordField;
    SLElement *_submitButton;
    SLElement *_loginSpinner;
    
    id _loginManagerMock;
}

#pragma mark - Setup and Teardown

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    // set up elements
    _usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
    _passwordField = [SLTextField elementWithAccessibilityLabel:@"password field" isSecure:YES];
    _submitButton = [SLElement elementWithAccessibilityLabel:@"Submit"];
    _loginSpinner = [SLElement elementWithAccessibilityLabel:@"Logging in..."];

    // mock desired response to login
    _loginManagerMock = [OCMockObject partialMockForObject:[STLoginManager sharedLoginManager]];

    BOOL loginShouldSucceed = YES;
    NSError *loginError = nil;
    
    if (testSelector == @selector(testLogInUnsuccessfullyWithNetworkError)) {
        loginShouldSucceed = NO;
        loginError = [NSError errorWithDomain:LoginFailureError code:NetworkErrorCode userInfo:nil];
    }
    
    [[[_loginManagerMock stub] andDo:^(NSInvocation *invocation) {
        void(^completionBlock)(BOOL, NSError*) = nil;
        [invocation getArgument:&completionBlock atIndex:4];
        NSAssert(completionBlock, @"The login view controller didn't register a callback for login.");

        // simulate network delay
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completionBlock(loginShouldSucceed, loginError);
        });
    }] loginWithUsername:OCMOCK_ANY password:OCMOCK_ANY completionBlock:OCMOCK_ANY];
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    if (testSelector == @selector(testLogInUnsuccessfullyWithNetworkError)) {
        SLAlert *failureAlert = [SLAlert elementWithAccessibilityLabel:@"Network Error"];
        [UIAElement(failureAlert) dismiss];
    }

    [_loginManagerMock stopMocking];
    _loginManagerMock = nil;

    [self.testController sendAction:@selector(resetLogin)];
}

#pragma mark - Tests

- (void)testLogInSuccessfully {
    NSString *username = @"Jeff", *password = @"foo";
    [UIAElement(_usernameField) setText:username];
    [UIAElement(_passwordField) setText:password];
    
    [UIAElement(_submitButton) tap];
    
    [UIAElement(_loginSpinner) waitUntilInvisible:3.0];
    
    NSString *successMessage = [NSString stringWithFormat:@"Hello, %@!", username];
    SLAssertTrue([UIAElement([SLElement elementWithAccessibilityLabel:successMessage]) isValid], @"Log-in did not succeed.");
}

- (void)testLogInUnsuccessfullyWithNetworkError {
    NSString *username = @"Jeff", *password = @"foo";
    [UIAElement(_usernameField) setText:username];
    [UIAElement(_passwordField) setText:password];
    
    [UIAElement(_submitButton) tap];
    
    [UIAElement(_loginSpinner) waitUntilInvisible:3.0];
    
    SLAlert *failureAlert = [SLAlert elementWithAccessibilityLabel:@"Network Error"];
    SLAssertTrue([UIAElement(failureAlert) isValid], @"Log-in did not fail and/or display failure alert as expected.");
}

@end
