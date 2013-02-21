//
//  SLDeviceTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import <OCMock/OCMock.h>

@interface SLDeviceTest : SLIntegrationTest

@end

@implementation SLDeviceTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLDeviceTestViewController";
}

- (void)testDeactivateAppForDuration {
    // notify whoever's watching the tests that we're about to deactivate the app,
    // so they can follow along
    static const NSTimeInterval kCountdownInterval = 3.0;
	SLAskApp1(beginCountdown:, @(kCountdownInterval));
    [self wait:kCountdownInterval];

    
    static const NSTimeInterval kDeactivationInterval = 3.0;
    NSDate *startDate = [NSDate date];
    UIApplication *app = [UIApplication sharedApplication];
    OCMockObject *mockDelegate = [OCMockObject partialMockForObject:[app delegate]];
    [mockDelegate setExpectationOrderMatters:YES];

    // Expect that the app will deactivate
    [[[mockDelegate expect] andForwardToRealObject] applicationWillResignActive:app];
    
    // Expect that the app will reactivate at least the specified number of seconds thereafter
    // (The time spent inactive will be a few seconds longer than the specified interval; see -deactivateAppForDuration:)
    [[[[mockDelegate expect] andDo:^(NSInvocation *invocation) {
        NSTimeInterval deactivationInterval = [[NSDate date] timeIntervalSinceDate:startDate];
        SLAssertTrue(deactivationInterval >= kDeactivationInterval,
                     @"Should have deactivated for at least %g seconds. Did deactivate for %g seconds", kDeactivationInterval, deactivationInterval);
    }] andForwardToRealObject] applicationDidBecomeActive:app];

    // note that this method will not return until the app has reactivated
    [[SLDevice currentDevice] deactivateAppForDuration:kDeactivationInterval];

    SLAssertNoThrow([mockDelegate verify], @"App did not deactivate and reactivate.");
}

@end
