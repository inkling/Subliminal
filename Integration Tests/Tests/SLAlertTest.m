//
//  SLAlertTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLAlertTest : SLIntegrationTest

@end

@implementation SLAlertTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLAlertTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    SLAskApp(dismissActiveAlert);

    [super tearDownTestCaseWithSelector:testSelector];
}

- (void)testAutomaticDismissalOfAlerts {
    SLAssertFalse([[SLTestController sharedTestController] automaticallyDismissAlerts],
                  @"By default/for the purposes of this test, UIAutomation should not automatically dismiss alerts.");

    SLAskApp1(showAlertWithTitle:, @"Auto-dismiss off");
    [self wait:2.0];
    SLAssertTrue([UIAElement([SLAlert anyElement]) isValid],
                 @"The alert should still be valid.");
    SLAskApp(dismissActiveAlert);

    [[SLTestController sharedTestController] setAutomaticallyDismissAlerts:YES];
    SLAskApp1(showAlertWithTitle:, @"Auto-dismiss on");
    [self wait:2.0];
    SLAssertFalse([UIAElement([SLAlert anyElement]) isValid],
                  @"The alert should have been dismissed.");
    [[SLTestController sharedTestController] setAutomaticallyDismissAlerts:NO];
}

- (void)testCanMatchAlertWithTitle {
    NSString *validAlertTitle = @"Foo", *invalidAlertTitle = @"Bar";

	SLAskApp1(showAlertWithTitle:, validAlertTitle);
    SLAssertTrue([UIAElement([SLAlert alertWithTitle:validAlertTitle]) isValid],
                 @"An alert with title \"%@\" should be valid.", validAlertTitle);
    SLAssertFalse([UIAElement([SLAlert alertWithTitle:invalidAlertTitle]) isValid],
                  @"No other alert should be valid.");
}

- (void)testDismiss {
    NSString *alertTitle = @"Foo";
	SLAskApp1(showAlertWithTitle:, alertTitle);
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAssertTrue([UIAElement(alert) isValid],
                 @"The alert should be valid.");

    [alert dismiss];
    [self wait:0.2];    // for the alert to be dismissed
    SLAssertFalse([UIAElement(alert) isValid],
                 @"The alert should have been dismissed.");
}

- (void)testDismissWithButtonTitled {
    NSString *alertTitle = @"Foo";
	SLAskApp1(showAlertWithTitle:, alertTitle);
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    SLAssertTrue([UIAElement(alert) isValid],
                 @"The alert should be valid.");

    NSString *dismissButtonTitle = @"Ok";
    [alert dismissWithButtonTitled:dismissButtonTitle];
    [self wait:0.2];    // for the alert to be dismissed
    SLAssertFalse([UIAElement(alert) isValid],
                  @"The alert should have been dismissed.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:dismissButtonTitle],
                 @"The alert should have been dismissed using the button titled \"%@\".", dismissButtonTitle);
}

@end
