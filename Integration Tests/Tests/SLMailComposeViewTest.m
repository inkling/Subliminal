//
//  SLMailComposeViewTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/24/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

#import <MessageUI/MessageUI.h>

@interface SLMailComposeViewTest : SLIntegrationTest

@end

@implementation SLMailComposeViewTest {
    SLMailComposeView *_composeView;
    NSDictionary *_messageInfo;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLMailComposeViewTestViewController";
}

- (void)setUpTest {
    [super setUpTest];

    _composeView = [SLMailComposeView currentComposeView];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    // The matching test must present the controller itself.
    if (testCaseSelector != @selector(testCanMatchComposeView)) {
        NSDictionary *messageInfo = nil;
        // all "can read" cases operate with all recipient fields populated,
        // to make sure that we can distinguish the fields (something of an implementation test
        if ((testCaseSelector == @selector(testCanReadToRecipients)) ||
            (testCaseSelector == @selector(testCanReadMultipleRecipients)) ||
            (testCaseSelector == @selector(testCanReadCcRecipients)) ||
            (testCaseSelector == @selector(testCanReadBccRecipients))) {
            NSArray *toRecipients;
            if (testCaseSelector == @selector(testCanReadMultipleRecipients)) {
                toRecipients = @[ @"foo@example.com", @"bar@example.com" ];
            } else {
                toRecipients = @[ @"foo@example.com" ];
            }
            messageInfo = @{
                @"toRecipients": toRecipients,
                @"ccRecipients": @[ @"baz@example.com" ],
                @"bccRecipients": @[ @"bee@example.com" ]
            };
        } else if (testCaseSelector == @selector(testCanReadSubject)) {
            messageInfo = @{ @"subject": @"This Is a Subliminal Message" };
        } else if (testCaseSelector == @selector(testCanReadBody)) {
            messageInfo = @{ @"body": @"That is, a message sent by Subliminal." };
        } else if ((testCaseSelector == @selector(testCanCancelAndDeleteDraft)) ||
                   (testCaseSelector == @selector(testCanCancelAndSaveDraft))) {
            messageInfo = @{ @"body": @"A Subliminal message." };
        } else if (testCaseSelector == @selector(testCanSendMessage)) {
            messageInfo = @{
                @"toRecipients": @[ @"foo@example.com" ],
                @"subject": @"This is a test message",
                @"body": @"test"
            };
        }
        _messageInfo = messageInfo;
        SLAskApp1(presentComposeViewControllerWithInfo:, _messageInfo);
        SLWaitUntilTrue(SLAskAppYesNo(composeViewControllerIsPresented), 2.0);
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(dismissComposeViewController);
    SLWaitUntilTrue(!SLAskAppYesNo(composeViewControllerIsPresented), 2.0);
    _messageInfo = nil;

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)testCanMatchComposeView {
    SLAssertFalse([_composeView isValid], @"The compose view should not exist.");

    SLAskApp1(presentComposeViewControllerWithInfo:, nil);
    SLAssertTrueWithTimeout([_composeView isValidAndVisible], 2.0,
                            @"The compose view should be visible.");
}

#pragma mark - Message Field Test Cases

- (void)testCanReadToRecipients {
    NSArray *actualRecipients, *expectedRecipients = _messageInfo[@"toRecipients"];
    SLAssertNoThrow(actualRecipients = _composeView.toRecipients,
                    @"The 'to' recipients should have been able to be read.");
    SLAssertTrue([actualRecipients isEqualToArray:expectedRecipients],
                 @"The 'to' recipients were not read as expected.");
}

- (void)testCanSetToRecipients {
    NSArray *expectedRecipients = @[ @"foo@example.com" ];

    SLAssertFalse([_composeView.toRecipients isEqualToArray:expectedRecipients],
                  @"The 'to' recipients must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.toRecipients = expectedRecipients,
                    @"The 'to' recipients should have been able to be set.");
    SLAssertTrue([_composeView.toRecipients isEqualToArray:expectedRecipients],
                 @"The 'to' recipients were not set as expected.");
}

// This is something of an implementation test--the mail compose view truncates
// the display of secondary recipients when a recipient field is not focused.
// This covers the "to", "cc", and "bcc" fields.
- (void)testCanReadMultipleRecipients {
    NSArray *actualRecipients, *expectedRecipients = _messageInfo[@"toRecipients"];
    SLAssertNoThrow(actualRecipients = _composeView.toRecipients,
                    @"The 'to' recipients should have been able to be read.");
    SLAssertTrue([actualRecipients isEqualToArray:expectedRecipients],
                 @"The 'to' recipients were not read as expected.");
}

// This covers the "to", "cc", and "bcc" fields.
- (void)testCanSetMultipleRecipients {
    NSArray *expectedRecipients = @[ @"foo@example.com", @"bar@example.com" ];

    SLAssertFalse([_composeView.toRecipients isEqualToArray:expectedRecipients],
                  @"The 'to' recipients must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.toRecipients = expectedRecipients,
                    @"The 'to' recipients should have been able to be set.");
    SLAssertTrue([_composeView.toRecipients isEqualToArray:expectedRecipients],
                 @"The 'to' recipients were not set as expected.");
}

- (void)testCanReadCcRecipients {
    NSArray *actualRecipients, *expectedRecipients = _messageInfo[@"ccRecipients"];
    SLAssertNoThrow(actualRecipients = _composeView.ccRecipients,
                    @"The 'cc' recipients should have been able to be read.");
    SLAssertTrue([actualRecipients isEqualToArray:expectedRecipients],
                 @"The 'cc' recipients were not read as expected.");
}

- (void)testCanSetCcRecipients {
    NSArray *expectedRecipients = @[ @"foo@example.com" ];

    SLAssertFalse([_composeView.ccRecipients isEqualToArray:expectedRecipients],
                  @"The 'cc' recipients must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.ccRecipients = expectedRecipients,
                    @"The 'cc' recipients should have been able to be set.");
    SLAssertTrue([_composeView.ccRecipients isEqualToArray:expectedRecipients],
                 @"The 'cc' recipients were not set as expected.");
}

- (void)testCanReadBccRecipients {
    NSArray *actualRecipients, *expectedRecipients = _messageInfo[@"bccRecipients"];
    SLAssertNoThrow(actualRecipients = _composeView.bccRecipients,
                    @"The 'bcc' recipients should have been able to be read.");
    SLAssertTrue([actualRecipients isEqualToArray:expectedRecipients],
                 @"The 'bcc' recipients were not read as expected.");
}

// This is tested because the "bcc" field is collapsed into the "cc" field if empty.
- (void)testCanReadEmptyBccRecipients {
    NSArray *bccRecipients;
    SLAssertNoThrow(bccRecipients = _composeView.bccRecipients,
                    @"The 'bcc' recipients should have been able to be read.");
    SLAssertFalse([bccRecipients count], @"There should be no 'bcc' recipients.");
}

- (void)testCanSetBccRecipients {
    NSArray *expectedRecipients = @[ @"foo@example.com" ];

    SLAssertFalse([_composeView.bccRecipients isEqualToArray:expectedRecipients],
                  @"The 'bcc' recipients must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.bccRecipients = expectedRecipients,
                    @"The 'bcc' recipients should have been able to be set.");
    SLAssertTrue([_composeView.bccRecipients isEqualToArray:expectedRecipients],
                 @"The 'bcc' recipients were not set as expected.");
}

- (void)testCanReadSubject {
    NSString *actualSubject, *expectedSubject = _messageInfo[@"subject"];

    SLAssertNoThrow(actualSubject = _composeView.subject,
                    @"The subject should have been able to be read.");
    SLAssertTrue([actualSubject isEqualToString:expectedSubject],
                 @"The subject was not read as expected: %@", actualSubject);
}

- (void)testCanSetSubject {
    NSString *expectedSubject = @"This Is a Subliminal Message";

    SLAssertFalse([_composeView.subject isEqualToString:expectedSubject],
                  @"The subject must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.subject = expectedSubject,
                    @"The subject should have been able to be set.");
    SLAssertTrue([_composeView.subject isEqualToString:expectedSubject],
                 @"The subject was not set as expected.");
}

- (void)testCanReadBody {
    NSString *actualBody, *expectedBody = _messageInfo[@"body"];

    SLAssertNoThrow(actualBody = _composeView.body,
                    @"The body should have been able to be read.");
    // on iOS 6.1, the body will be suffixed with the signature "Sent from my iPhone Simulator"
    SLAssertTrue([actualBody hasPrefix:expectedBody],
                 @"The body was not read as expected: %@", actualBody);
}

- (void)testCanSetBody {
    NSString *expectedBody = @"A message sent by Subliminal.";

    SLAssertFalse([_composeView.body isEqualToString:expectedBody],
                  @"The body must not be pre-populated to the expected value.");
    SLAssertNoThrow(_composeView.body = expectedBody,
                    @"The body should have been able to be set.");
    SLAssertTrue([_composeView.body isEqualToString:expectedBody],
                 @"The body was not set as expected.");
}

#pragma mark - Sending Mail Test Cases

- (void)testCanAbortEmptyMessage {
    BOOL didCancelDraft;
    SLAssertNoThrow(didCancelDraft = [_composeView cancelAndDeleteDraft:NO],
                    @"Should have been able to attempt to cancel and save draft.");
    SLAssertFalse(didCancelDraft,
                 @"For the purposes of this test case, there should not have been a draft in progress to cancel.");

    SLAssertTrueWithTimeout(!SLAskAppYesNo(composeViewControllerIsPresented), 2.0,
                            @"Compose view should have been dismissed.");
    MFMailComposeResult composeFinishResult;
    [SLAskApp(composeViewControllerFinishResult) getValue:&composeFinishResult];
    SLAssertTrue(composeFinishResult == MFMailComposeResultCancelled,
                 @"Compose view was not cancelled as expected.");
}

- (void)testCanCancelAndDeleteDraft {
    BOOL didCancelDraft;
    SLAssertNoThrow(didCancelDraft = [_composeView cancelAndDeleteDraft:YES],
                    @"Should have been able to cancel and save draft.");
    SLAssertTrue(didCancelDraft,
                 @"For the purposes of this test case, there should have been a draft in progress to cancel.");
    
    SLAssertTrueWithTimeout(!SLAskAppYesNo(composeViewControllerIsPresented), 2.0,
                            @"Compose view should have been dismissed.");
    MFMailComposeResult composeFinishResult;
    [SLAskApp(composeViewControllerFinishResult) getValue:&composeFinishResult];
    SLAssertTrue(composeFinishResult == MFMailComposeResultCancelled,
                 @"The draft was not cancelled as expected.");
}

- (void)testCanCancelAndSaveDraft {
    BOOL didCancelDraft;
    SLAssertNoThrow(didCancelDraft = [_composeView cancelAndDeleteDraft:NO],
                    @"Should have been able to cancel and save draft.");
    SLAssertTrue(didCancelDraft,
                 @"For the purposes of this test case, there should have been a draft in progress to cancel.");

    SLAssertTrueWithTimeout(!SLAskAppYesNo(composeViewControllerIsPresented), 2.0,
                            @"Compose view should have been dismissed.");
    MFMailComposeResult composeFinishResult;
    [SLAskApp(composeViewControllerFinishResult) getValue:&composeFinishResult];
    SLAssertTrue(composeFinishResult == MFMailComposeResultSaved,
                 @"The draft was not saved as expected.");
}

/**
 Note that this test case is about `SLMailComposeView` properly reporting that
 `MFMailComposeViewController` won't let the user send an empty message,
 not about Subliminal enforcing that requirement itself.
 */
- (void)testCannotSendEmptyMessage {
    SLAssertFalse([_composeView sendMessage],
                  @"Should not be able to send an empty message.");
}

- (void)testCanSendMessage {
    SLAssertTrue([_composeView sendMessage],
                 @"Should have been able to send the message.");

    SLAssertTrueWithTimeout(!SLAskAppYesNo(composeViewControllerIsPresented), 2.0,
                            @"Compose view should have been dismissed.");
    MFMailComposeResult composeFinishResult;
    [SLAskApp(composeViewControllerFinishResult) getValue:&composeFinishResult];
    SLAssertTrue(composeFinishResult == MFMailComposeResultSent,
                 @"The message was not sent as expected.");
}

@end
