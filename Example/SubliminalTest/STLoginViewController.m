//
//  STLoginViewController.m
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


#import "STLoginViewController.h"

#if INTEGRATION_TESTING
#import <Subliminal/Subliminal.h>
#endif


@interface STLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginSpinner;
@end


@implementation STLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameField.accessibilityLabel = @"username field";
    self.passwordField.accessibilityLabel = @"password field";
    
    self.loginSpinner.accessibilityIdentifier = @"Logging in...";

    [self.submitButton setTitle:@"" forState:UIControlStateDisabled];

#if INTEGRATION_TESTING
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(resetLogin)];
#endif
}

- (void)dealloc {
#if INTEGRATION_TESTING
    [[SLTestController sharedTestController] deregisterTarget:self];
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)login:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    self.usernameField.enabled = NO;
    self.usernameField.backgroundColor = [UIColor lightGrayColor];
    self.passwordField.enabled = NO;
    self.passwordField.backgroundColor = [UIColor lightGrayColor];

    self.submitButton.enabled = NO;

    if ([username length] && [password length]) {
        [self.loginSpinner startAnimating];

        // wait to simulate network delay/so that the spinner will show
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.loginSpinner stopAnimating];
            self.submitButton.hidden = YES;
            self.messageLabel.text = [NSString stringWithFormat:@"Hello, %@!", username];
        });
    } else {
        self.usernameField.enabled = YES;
        self.usernameField.backgroundColor = [UIColor clearColor];
        self.passwordField.enabled = YES;
        self.passwordField.backgroundColor = [UIColor clearColor];
        self.submitButton.enabled = YES;

        self.messageLabel.text = @"Invalid username or password.";
    }
}

- (void)resetLogin {
    self.usernameField.text = @"";
    self.usernameField.enabled = YES;
    self.usernameField.backgroundColor = [UIColor clearColor];

    self.passwordField.text = @"";
    self.passwordField.enabled = YES;
    self.passwordField.backgroundColor = [UIColor clearColor];

    self.submitButton.hidden = NO;
    self.submitButton.enabled = YES;
    self.messageLabel.text = @"";
}

@end
