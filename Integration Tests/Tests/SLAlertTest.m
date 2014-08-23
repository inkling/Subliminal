//
//  SLAlertTest.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import "SLIntegrationTest.h"


@interface SLAlertTest : SLIntegrationTest

@end

@implementation SLAlertTest {
    BOOL _defaultAutomaticallyDismissAlerts;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLAlertTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(dismissActiveAlertAndClearTitleOfLastButtonClicked);

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

#pragma mark - Automatic dismissal

- (void)testThatUnhandledAlertsAreAutomaticallyDismissed {
    SLAskApp1(showAlertWithTitle:, @"Unhandled Alert");
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertFalse(SLAskAppYesNo(isAlertActive), @"The unhandled alert should have been automatically dismissed.");
}

- (void)testAutomaticDismissalTapsTheCancelButtonFirst {
    NSString *cancelButtonTitle = @"Cancel";
    SLAskApp1(showAlertWithInfo:, (@{   @"title": @"Foo",
                                        @"cancel": cancelButtonTitle,
                                        @"other": @"Ok" }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The alert should have been dismissed using the cancel button.");
}

- (void)testAutomaticDismissalTapsTheDefaultButtonAbsentACancelButton {
    NSString *defaultButtonTitle = @"Ok";
    SLAskApp1(showAlertWithInfo:, (@{   @"title": @"Foo",
                                        @"other": defaultButtonTitle }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The alert should have been dismissed using the default button.");
}

#pragma mark - Manual dismissal

- (void)testManuallyHandlingParticularAlerts {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";

    // we can manually handle particular alerts
    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:handler];

    // --some random alert will be automatically dismissed with the cancel butotn
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   @"Random Alert",
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertFalse([handler didHandleAlert], @"Handler should not yet have handled an alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The alert should have been automatically dismissed, using the cancel button.");

    // --but the handled alert will be dismissed with the default button
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled an alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The handler should have dismissed the alert using the default button.");
}

- (void)testManuallyHandlingParticularAlertsInTestCode {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";

    // We can mark particular alerts to be left onscreen to be interacted with manually
    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismissByTest];
    [SLAlertHandler addHandler:handler];

    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled an alert.");
    SLAssertNoThrow([[SLButton elementWithAccessibilityLabel:defaultButtonTitle] tap], @"The default button couldn't be found to tap!");
    // Wait for the alert dismiss callback to be received.
    SLAssertTrueWithTimeout(SLAskApp(titleOfLastButtonClicked) != nil, SLAlertHandlerDidHandleAlertDelay, @"The default button was not tapped.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The test should have dismissed the alert using the default button.");
}

// the other test cases in this file verify that we can handle alerts with particular _titles_
- (void)testManuallyHandlingAlertsWithParticularMessages {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";
    
    // we can manually handle particular alerts
    NSString *alertTitle = @"Alert";
    NSString *alertMessage = @"Test Message";
    SLAlert *alert = [SLAlert alertWithMessage:alertMessage];
    SLAlertHandler *handler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:handler];
    
    // --some random alert will be automatically dismissed with the cancel butotn
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"message": @"Random Message",
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertFalse([handler didHandleAlert], @"Handler should not yet have handled an alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The alert should have been automatically dismissed, using the cancel button.");
    
    // --but the handled alert will be dismissed with the default button
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"message": alertMessage,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled an alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The handler should have dismissed the alert using the default button.");
}

- (void)testManuallyHandlingAlertsWithJustMessages {  // i.e. without titles
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";
    
    NSString *alertMessage = @"Test Message";
    SLAlert *alert = [SLAlert alertWithMessage:alertMessage];
    SLAlertHandler *handler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:handler];
    
    SLAskApp1(showAlertWithInfo:, (@{   @"message": alertMessage,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay,
                            @"Handler should have handled an alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The handler should have dismissed the alert using the default button.");
}

- (void)testHandlerMustBeAddedBeforeAlertShows {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";

    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];

    // there is not yet a handler for the alert and so it will be dismissed with the cancel button
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The handler should have dismissed the alert using the cancel button.");

    SLAlertHandler *handler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:handler];
    SLAssertFalse([handler didHandleAlert], @"The handler should not have handled any alert.");

    // show a second alert just to remove the handler
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    // sanity check
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, nil);
}

- (void)testAHandlerMustNotBeAddedMultipleTimes {
    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];
    SLAssertThrowsNamed([SLAlertHandler addHandler:handler],
                        NSInternalInconsistencyException,
                        @"SLAlertHandler should have thrown an exception because the handler had already been added once.");

    // show an alert just to remove the handler
    SLAskApp1(showAlertWithTitle:, alertTitle);
    // sanity check
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, nil);
}

// This is a variant on the above test
- (void)testAHandlerMustNotBeReadded {
    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];

    // show an alert to remove the handler
    SLAskApp1(showAlertWithTitle:, alertTitle);
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, nil);
    
    SLAssertThrowsNamed([SLAlertHandler addHandler:handler],
                        NSInternalInconsistencyException,
                        @"SLAlertHandler should have thrown an exception because the handler had already been added once.");
}

- (void)testAHandlerIsRemovedAfterItHandlesAnAlert {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";

    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:handler];

    // the first alert will be handled and so will be dismissed with the default button
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"The handler should have handled the alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The handler should have dismissed the alert using the default button.");

    // the second alert will not be handled and so will be dismissed with the cancel button
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                  @"Without the handler active, the alert should have been dismissed using the cancel button.");
}

- (void)testAHandlerIsRemovedOnlyIfItSuccessfullyHandlesAnAlert {
    NSString *cancelButtonTitle = @"Cancel";
    NSString *defaultButtonTitle = @"Ok";

    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];

    SLAlertHandler *defaultButtonHandler = [alert dismissWithButtonTitled:defaultButtonTitle];
    [SLAlertHandler addHandler:defaultButtonHandler];

    SLAlertHandler *cancelButtonHandler = [alert dismissWithButtonTitled:cancelButtonTitle];
    [SLAlertHandler addHandler:cancelButtonHandler];

    // the defaultButtonHandler will not handle this alert, though it was the first to be added
    // because the alert doesn't have the button that the handler tries to tap
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle, }));
    SLAssertFalse([defaultButtonHandler didHandleAlert], @"The default button handler should not have handled the alert.");
    SLAssertTrueWithTimeout([cancelButtonHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"The cancel button handler should have handled the alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The alert should have been dismissed using the cancel button.");

    // the defaultButtonHandler will handle this alert, now
    SLAskApp1(showAlertWithInfo:, (@{   @"title":   alertTitle,
                                        @"cancel":  cancelButtonTitle,
                                        @"other":   defaultButtonTitle }));
    SLAssertTrueWithTimeout([defaultButtonHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"The default button handler should have handled the alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"Without the handler active, the alert should have been dismissed using the default button.");
}

- (void)testRemoveHandler {
    NSString *alertTitle = @"Foo";
    NSString *cancelButtonTitle = @"Cancel";
    NSString *otherButtonTitle = @"Ok";

    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *okButtonHandler = [alert dismissWithButtonTitled:otherButtonTitle];

    [SLAlertHandler addHandler:okButtonHandler];
    [SLAlertHandler removeHandler:okButtonHandler];

    SLAskApp1(showAlertWithInfo:, (@{   @"title": alertTitle,
                                   @"cancel": cancelButtonTitle,
                                   @"other": otherButtonTitle }));

    [self wait:SLAlertHandlerDidHandleAlertDelay];
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The alert should have been dismissed using the cancel button by default.");
}

- (void)testRemoveHandlerThrowsIfNotAlreadyAdded {
    SLAlert *alert = [SLAlert alertWithTitle:@"Foo"];
    SLAlertHandler *handler = [alert dismiss];
    SLAssertThrowsNamed([SLAlertHandler removeHandler:handler],
                        NSInternalInconsistencyException,
                        @"SLAlertHandler should have thrown an exception because the handler had not been added using +[SLAlertHandler addHandler:].");
}

- (void)testMultipleHandlersMayBeAddedSimultaneously {
    NSString *alert1Title = @"Alert 1";
    SLAlert *alert1 = [SLAlert alertWithTitle:alert1Title];
    SLAlertHandler *alert1Handler = [alert1 dismiss];
    [SLAlertHandler addHandler:alert1Handler];

    NSString *alert2Title = @"Alert 2";
    SLAlert *alert2 = [SLAlert alertWithTitle:alert2Title];
    SLAlertHandler *alert2Handler = [alert2 dismiss];
    [SLAlertHandler addHandler:alert2Handler];

    SLAskApp1(showAlertWithTitle:, alert1Title);
    SLAssertTrueWithTimeout([alert1Handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"First alert handler should have handled alert.");
    SLAssertFalse([alert2Handler didHandleAlert], @"Second alert handler should not have handled alert.");

    // showing the second alert may be slightly delayed by the first's dismissal
    SLAskApp1(showAlertWithTitle:, alert2Title);
    SLAssertTrueWithTimeout([alert2Handler didHandleAlert], 1.0, @"Second alert handler should have handled alert.");
}

- (void)testHandlersAreCheckedInOrderOfAddition {
    NSString *alertTitle = @"Alert";
    SLAlert *alert1 = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *firstHandler = [alert1 dismiss];
    SLAlertHandler *secondHandler = [alert1 dismiss];
    [SLAlertHandler addHandler:firstHandler];
    [SLAlertHandler addHandler:secondHandler];

    SLAskApp1(showAlertWithTitle:, alertTitle);
    SLAssertTrueWithTimeout([firstHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Oldest alert handler should have handled alert.");
    SLAssertFalse([secondHandler didHandleAlert], @"Newer alert handler should not have handled alert.");

    SLAskApp1(showAlertWithTitle:, alertTitle);
    SLAssertTrueWithTimeout([secondHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Oldest alert handler should have handled alert.");
}

- (void)testDidHandleAlertThrowsIfHandlerHasNotBeenAdded {
    SLAlert *alert = [SLAlert alertWithTitle:@"Foo"];
    SLAlertHandler *handler = [alert dismiss];
    SLAssertThrowsNamed([handler didHandleAlert],
                        NSInternalInconsistencyException,
                        @"Handler should have thrown an exception because it had not been added using +[SLAlertHandler addHandler:].");
}

- (void)testAndThenChainsTwoHandlers {
    NSString *alertTitle = @"Foo";
    NSString *defaultButtonTitle = @"Ok";
    NSString *textToEnter = @"foo";
    
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *setPlainText = [alert setText:textToEnter ofFieldOfType:SLAlertTextFieldTypePlainText];
    SLAlertHandler *dismiss = [alert dismissWithButtonTitled:defaultButtonTitle];
    SLAlertHandler *alertHandler = [setPlainText andThen:dismiss];
    [SLAlertHandler addHandler:alertHandler];

    SLAskApp1(showAlertWithInfo:, (@{  @"title": alertTitle,
                                       @"cancel": @"Cancel",
                                       @"other": defaultButtonTitle,
                                       @"style": @(UIAlertViewStylePlainTextInput) }));
 
    SLAssertTrueWithTimeout([alertHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"Alert should have been dismissed using default button.");
    SLAssertTrue([SLAskApp1(textEnteredIntoLastTextFieldAtIndex:, @0) isEqualToString:textToEnter],
                 @"Alert text field should have contained the specified value.");
}

- (void)testAddHandlerThrowsIfHandlerDoesNotDismissAlert {
    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *setPlainText = [alert setText:@"foo" ofFieldOfType:SLAlertTextFieldTypePlainText];

    // here, in contrast to the previous test,
    // the developer forgot to sequence the setText handler
    // with a dismiss handler of some kind
    SLAssertThrows([SLAlertHandler addHandler:setPlainText],
                   @"Should have thrown because handler would not have dismissed the alert.");
}

#pragma mark -dismiss

- (void)testDismissTapsTheCancelButtonFirst {
    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];

    NSString *cancelButtonTitle = @"Cancel";
    SLAskApp1(showAlertWithInfo:, (@{   @"title": alertTitle,
                                        @"cancel": cancelButtonTitle,
                                        @"other": @"Ok" }));

    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:cancelButtonTitle],
                 @"The handler should dismissed the alert using the cancel button.");
}

- (void)testDismissTapsTheDefaultButtonAbsentACancelButton {
    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismiss];
    [SLAlertHandler addHandler:handler];

    NSString *defaultButtonTitle = @"Ok";
    SLAskApp1(showAlertWithInfo:, (@{   @"title": @"Foo",
                                        @"other": defaultButtonTitle }));

    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:defaultButtonTitle],
                 @"The handler should dismissed the alert using the default button.");
}

#pragma mark -dismissWithButtonTitled:

- (void)testDismissWithButtonTitled {
    NSString *dismissButtonTitle = @"Ok";

    NSString *alertTitle = @"Foo";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *handler = [alert dismissWithButtonTitled:dismissButtonTitle];
    [SLAlertHandler addHandler:handler];

    SLAskApp1(showAlertWithInfo:, (@{  @"title": alertTitle,
                                       @"cancel": @"Cancel",
                                       @"other": dismissButtonTitle }));
    
    SLAssertTrueWithTimeout([handler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:dismissButtonTitle],
                 @"The handler should dismissed the alert using the button with the specified title.");
}

#pragma mark -setText:ofFieldOfType:

- (void)testSetTextOfSecureTextField {
    NSString *alertTitle = @"Foo";
    NSString *textToEnter = @"foo";

    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *setSecureText = [alert setText:textToEnter ofFieldOfType:SLAlertTextFieldTypeSecureText];
    SLAlertHandler *dismiss = [alert dismiss];
    SLAlertHandler *alertHandler = [setSecureText andThen:dismiss];
    [SLAlertHandler addHandler:alertHandler];

    SLAskApp1(showAlertWithInfo:, (@{  @"title": alertTitle,
                                       @"cancel": @"Cancel",
                                       @"style": @(UIAlertViewStyleSecureTextInput) }));

    SLAssertTrueWithTimeout([alertHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp1(textEnteredIntoLastTextFieldAtIndex:, @0) isEqualToString:textToEnter],
                 @"Alert text field should have contained the specified value.");
}

- (void)testSetTextOfPlainTextField {
    NSString *alertTitle = @"Foo";
    NSString *textToEnter = @"foo";
    
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *setPlainText = [alert setText:@"foo" ofFieldOfType:SLAlertTextFieldTypePlainText];
    SLAlertHandler *dismiss = [alert dismiss];
    SLAlertHandler *alertHandler = [setPlainText andThen:dismiss];
    [SLAlertHandler addHandler:alertHandler];

    SLAskApp1(showAlertWithInfo:, (@{  @"title": alertTitle,
                                       @"cancel": @"Cancel",
                                       @"style": @(UIAlertViewStylePlainTextInput) }));

    SLAssertTrueWithTimeout([alertHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp1(textEnteredIntoLastTextFieldAtIndex:, @0) isEqualToString:textToEnter],
                 @"Alert text field should have contained the specified value.");
}

- (void)testSetTextOfLoginAndPasswordFields {
    NSString *alertTitle = @"Foo";
    NSString *username = @"user";
    NSString *password = @"password";

    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAlertHandler *setUsername = [alert setText:username ofFieldOfType:SLAlertTextFieldTypeLogin];
    SLAlertHandler *setPassword = [alert setText:password ofFieldOfType:SLAlertTextFieldTypePassword];
    SLAlertHandler *dismiss = [alert dismiss];
    SLAlertHandler *alertHandler = [[setUsername andThen:setPassword] andThen:dismiss];
    [SLAlertHandler addHandler:alertHandler];

    SLAskApp1(showAlertWithInfo:, (@{  @"title": alertTitle,
                                       @"cancel": @"Cancel",
                                       @"style": @(UIAlertViewStyleLoginAndPasswordInput) }));
    SLAssertTrueWithTimeout([alertHandler didHandleAlert], SLAlertHandlerDidHandleAlertDelay, @"Handler should have handled alert.");
    SLAssertTrue([SLAskApp1(textEnteredIntoLastTextFieldAtIndex:, @0) isEqualToString:username],
                 @"Alert text field should have contained the specified value.");
    SLAssertTrue([SLAskApp1(textEnteredIntoLastTextFieldAtIndex:, @1) isEqualToString:password],
                 @"Alert text field should have contained the specified value.");
}

@end
