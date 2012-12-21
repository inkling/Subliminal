//
//  SLTestControllerTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/20/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>

@interface SLTestControllerTests : SenTestCase
@end

@implementation SLTestControllerTests

- (void)testMustUseSharedController {
    NSLog(@"*** The two assertion failures seen in the test output immediately below are an expected part of the tests.");

    // ignore the unused results below
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

    // test attempted manual allocation before retrieving shared controller
    STAssertThrows([[SLTestController alloc] init], @"Should not have been able to manually initialize an SLTestController.");

    STAssertNotNil([SLTestController sharedTestController], @"Should have been able to retrieve shared controller.");

    // test attempted manual allocation after retrieving shared controller
    STAssertThrows([[SLTestController alloc] init], @"Should not have been able to manually initialize an SLTestController.");

#pragma clang diagnostic pop
}

@end
