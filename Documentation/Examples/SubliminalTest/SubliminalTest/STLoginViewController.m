//
//  STLoginViewController.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//


#import "STLoginViewController.h"

#import "STLoginManager.h"

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
    
    // ???: Make this dynamic? Post accessibility announcement? Check for explicit failure/success?
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
    [self.loginSpinner startAnimating];
    
    [[STLoginManager sharedLoginManager] loginWithUsername:username 
                                                  password:password 
                                           completionBlock:^(BOOL didLogIn, NSError *error) {
                                               [self.loginSpinner stopAnimating];
                                               if (didLogIn) {
                                                   self.submitButton.hidden = YES;
                                                   
                                                   self.messageLabel.text = [NSString stringWithFormat:@"Hello, %@!", username];
                                               } else {
                                                   self.usernameField.enabled = YES;
                                                   self.usernameField.backgroundColor = [UIColor clearColor];
                                                   self.passwordField.enabled = YES;
                                                   self.passwordField.backgroundColor = [UIColor clearColor];
                                                   self.submitButton.enabled = YES;
                                                   
                                                   switch ([error code]) {
                                                       case InvalidLoginErrorCode:
                                                           self.messageLabel.text = @"Invalid username or password. Please try again.";
                                                           break;
                                                        case NetworkErrorCode:
                                                       {
                                                           [[[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Something seems to be up with the network. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                                                       }
                                                           break;
                                                   }
                                               }
    }];
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
