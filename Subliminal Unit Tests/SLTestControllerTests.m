//
//  SLTestControllerTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/20/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>
#import <OCMock/OCMock.h>

#import "TestUtilities.h"

@interface SLTestControllerTests : SenTestCase
@end

@implementation SLTestControllerTests {
    id _loggerMock, _terminalMock;
}

- (void)setUp {
    // SLTestController will not run without a logger being set
    _loggerMock = [OCMockObject niceMockForClass:[SLLogger class]];
    [SLLogger setSharedLogger:_loggerMock];

    // ensure that Subliminal doesn't get hung up trying to talk to UIAutomation
    _terminalMock = [OCMockObject partialMockForObject:[SLTerminal sharedTerminal]];
    [[_terminalMock stub] eval:OCMOCK_ANY];
}

- (void)tearDown {
    [_terminalMock stopMocking];
}

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

- (void)testOnlyTestsSupportingCurrentPlatformAreRun {
    NSSet *allTests = [SLTest allTests];

    NSMutableArray *testMocks = [NSMutableArray arrayWithCapacity:[allTests count]];
    for (Class testClass in allTests) {
        id testMock = [OCMockObject partialMockForClass:testClass];

        // expect test instances to be run only if they're supported on the current platform
        if ([testClass supportsCurrentPlatform]) {
            [[testMock expect] run:[OCMArg anyPointer]];
        } else {
            [[testMock reject] run:[OCMArg anyPointer]];
        }
        
        [testMocks addObject:testMock];
    }

    SLRunTestsAndWaitUntilFinished(allTests, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"Tests were not run as expected.");
}

@end
