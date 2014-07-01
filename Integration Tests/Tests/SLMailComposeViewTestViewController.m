//
//  SLMailComposeViewTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/24/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>
#import <MessageUI/MessageUI.h>

@interface SLMailComposeViewTestViewController : SLTestCaseViewController <MFMailComposeViewControllerDelegate>
@end

@implementation SLMailComposeViewTestViewController {
    MFMailComposeViewController *_composeViewController;
    NSValue *_composeViewControllerFinishResultValue;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing the mail compose view,
    // we don't need any particular view.
    [self loadGenericView];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(composeViewControllerIsPresented)];
        [testController registerTarget:self forAction:@selector(presentComposeViewControllerWithInfo:)];
        [testController registerTarget:self forAction:@selector(composeViewControllerFinishResult)];
        [testController registerTarget:self forAction:@selector(dismissComposeViewController)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSNumber *)composeViewControllerIsPresented {
    return @(_composeViewController != nil);
}

- (void)presentComposeViewControllerWithInfo:(NSDictionary *)info {
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    composeViewController.mailComposeDelegate = self;
    composeViewController.modalPresentationStyle = (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) ? UIModalPresentationFormSheet : UIModalPresentationFullScreen;

    if (info[@"toRecipients"])  [composeViewController setToRecipients:info[@"toRecipients"]];
    if (info[@"ccRecipients"])  [composeViewController setCcRecipients:info[@"ccRecipients"]];
    if (info[@"bccRecipients"]) [composeViewController setBccRecipients:info[@"bccRecipients"]];
    if (info[@"subject"])       [composeViewController setSubject:info[@"subject"]];
    if (info[@"body"])          [composeViewController setMessageBody:info[@"body"] isHTML:NO];

    // Present the controller without animation just for parity with dismissal.
    [self presentViewController:composeViewController animated:NO completion:^{
        // make sure that the modal view controller's fully presented
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        _composeViewController = composeViewController;
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSValue *resultValue = [NSValue valueWithBytes:&result objCType:@encode(__typeof(result))];
    [self dismissComposeViewControllerWithResultValue:resultValue];
}

- (NSValue *)composeViewControllerFinishResult {
    return _composeViewControllerFinishResultValue;
}

- (void)dismissComposeViewController {
    [self dismissComposeViewControllerWithResultValue:nil];
}

- (void)dismissComposeViewControllerWithResultValue:(NSValue *)resultValue {
    // check the second condition because this method may be called after the
    // mail compose controller has finished but before it's fully dismissed
    if (!_composeViewController || _composeViewControllerFinishResultValue) return;
    _composeViewControllerFinishResultValue = resultValue;

    // Dismiss the controller without animation because sometimes it fails with animation
    // --the controller just doesn't dismiss.
    [self dismissViewControllerAnimated:NO completion:^{
        // make sure that the modal view controller's fully torn down before popping this controller
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        _composeViewController = nil;
        _composeViewControllerFinishResultValue = nil;
    }];
}

@end
