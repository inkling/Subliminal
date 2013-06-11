//
//  SLDeviceTest.m
//  Subliminal
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

#import "SLIntegrationTest.h"
#import <OCMock/OCMock.h>

@interface SLDeviceTest : SLIntegrationTest

@end

@implementation SLDeviceTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLDeviceTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    if (testCaseSelector == @selector(testCanRotateDevice)) {
        [[SLDevice currentDevice] setOrientation:UIDeviceOrientationPortrait];
    }
    [super tearDownTestCaseWithSelector:testCaseSelector];
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

- (void)testCanRotateDevice
{
    const int orientationCount = 7;
    const UIDeviceOrientation orientations[orientationCount] =
    {
        UIDeviceOrientationUnknown,
        UIDeviceOrientationPortrait,
        UIDeviceOrientationPortraitUpsideDown,
        UIDeviceOrientationLandscapeLeft,
        UIDeviceOrientationLandscapeRight,
        UIDeviceOrientationFaceUp,
        UIDeviceOrientationFaceDown
    };
    
    for (int i=0; i<orientationCount; i++) {
        [self rotateToAndCheckOrientation:orientations[i]];
    }
}

- (void)rotateToAndCheckOrientation:(UIDeviceOrientation)orientation
{
    [[SLDevice currentDevice] setOrientation:orientation];
    SLAssertTrue([UIDevice currentDevice].orientation == orientation,
                 @"After rotating, device orientation should be %@",SLNSStringFromUIDeviceOrientation(orientation));
}

NSString * SLNSStringFromUIDeviceOrientation(UIDeviceOrientation orientation) {
	switch (orientation) {
		case UIDeviceOrientationFaceDown:           return @"UIDeviceOrientationFaceDown";              break;
		case UIDeviceOrientationFaceUp:             return @"UIDeviceOrientationFaceUp";                break;
		case UIDeviceOrientationLandscapeLeft:      return @"UIDeviceOrientationLandscapeLeft";         break;
		case UIDeviceOrientationLandscapeRight:     return @"UIDeviceOrientationLandscapeRight";        break;
		case UIDeviceOrientationPortrait:           return @"UIDeviceOrientationPortrait";              break;
		case UIDeviceOrientationPortraitUpsideDown: return @"UIDeviceOrientationPortraitUpsideDown";    break;
		case UIDeviceOrientationUnknown:            return @"UIDeviceOrientationUnknown";               break;
	}
}

@end
