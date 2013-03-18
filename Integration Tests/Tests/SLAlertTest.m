//
//  SLAlertTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"


// delay for the UIAutomation to dismiss alerts (if appropriate)
static const NSTimeInterval kUIAAlertHandlerDelay = 2.0;
// delay for alert to disappear once dismissed by the tests
static const NSTimeInterval kAlertDisappearDelay = 0.2;


@interface SLAlertTest : SLIntegrationTest

@end

@implementation SLAlertTest {
    BOOL _defaultAutomaticallyDismissAlerts;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLAlertTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    
    _defaultAutomaticallyDismissAlerts = [[SLTestController sharedTestController] automaticallyDismissAlerts];
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];
    
    if ((testSelector != @selector(testAutomaticDismissalOfAlerts)) &&
        (testSelector != @selector(testManuallyHandlingParticularAlerts))) {
        [[SLTestController sharedTestController] setAutomaticallyDismissAlerts:NO];
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    SLAskApp(dismissActiveAlert);
    [[SLTestController sharedTestController] setAutomaticallyDismissAlerts:_defaultAutomaticallyDismissAlerts];

    [super tearDownTestCaseWithSelector:testSelector];
}

- (void)testAutomaticDismissalOfAlerts {
    SLAssertTrue(_defaultAutomaticallyDismissAlerts &&
                 [[SLTestController sharedTestController] automaticallyDismissAlerts],
                  @"By default/for the purposes of this test, UIAutomation should automatically dismiss alerts.");

    SLAskApp1(showAlertWithTitle:, @"Auto-dismiss on");
    [self wait:kUIAAlertHandlerDelay];
    SLAssertFalse([UIAElement([SLAlert anyElement]) isValid],
                 @"The alert should have been dismissed.");

    [[SLTestController sharedTestController] setAutomaticallyDismissAlerts:NO];
    SLAskApp1(showAlertWithTitle:, @"Auto-dismiss off");
    [self wait:kUIAAlertHandlerDelay];
    SLAssertTrue([UIAElement([SLAlert anyElement]) isValid],
                  @"The alert should still be valid.");
    SLAskApp(dismissActiveAlert);
}

- (void)testManuallyHandlingParticularAlerts {
    // we can manually handle particular alerts
    NSString *alertTitle = @"Test Alert";
    SLAlert *alert = [SLAlert alertWithTitle:alertTitle];
    [[SLTestController sharedTestController] pushHandlerForAlert:alert];

    // --some random alert will still be automatically dismissed (the default)
    SLAssertTrue(_defaultAutomaticallyDismissAlerts &&
                 [[SLTestController sharedTestController] automaticallyDismissAlerts],
                 @"By default/for the purposes of this test, UIAutomation should automatically dismiss alerts.");
    SLAskApp1(showAlertWithTitle:, @"Random Alert");
    [self wait:kUIAAlertHandlerDelay];
    SLAssertFalse([UIAElement([SLAlert anyElement]) isValid],
                  @"The alert should have been dismissed.");

    // --but the handled alert will not
    SLAskApp1(showAlertWithTitle:, alertTitle);
    [self wait:kUIAAlertHandlerDelay];
    SLAssertTrue([UIAElement(alert) isValid],
                 @"The alert should still be valid.");
    [alert dismiss];

    // each handler is only good for one alert
    SLAskApp1(showAlertWithTitle:, alertTitle);
    [self wait:kUIAAlertHandlerDelay];
    SLAssertFalse([UIAElement(alert) isValid],
                  @"The alert should have been dismissed.");
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
    [self wait:kAlertDisappearDelay];
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
    [self wait:kAlertDisappearDelay];
    SLAssertFalse([UIAElement(alert) isValid],
                  @"The alert should have been dismissed.");
    SLAssertTrue([SLAskApp(titleOfLastButtonClicked) isEqualToString:dismissButtonTitle],
                 @"The alert should have been dismissed using the button titled \"%@\".", dismissButtonTitle);
}

@end
