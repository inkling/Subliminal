//
//  SLTestTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>
#import <OCMock/OCMock.h>

#import "TestUtilities.h"
#import "SharedTests.h"

@interface SLTestTests : SenTestCase

@end

@implementation SLTestTests {
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

#pragma mark - Test lookup

- (void)testAllTestsReturnsExpected {
    NSSet *allTests = [SLTest allTests];
    NSSet *expectedTests = [NSSet setWithObjects:
        [TestWithSomeTestCases class],
        [TestNotSupportingCurrentPlatform class],
        [TestWithPlatformSpecificTestCases class],
        [StartupTest class],
        nil
    ];
    STAssertEqualObjects(allTests, expectedTests, @"Unexpected tests returned.");
}

- (void)testTestNamedReturnsExpected {
    Class validTestClass = [TestWithSomeTestCases class];
    Class resultTestClass = [SLTest testNamed:NSStringFromClass(validTestClass)];
    STAssertEqualObjects(resultTestClass, validTestClass, @"+testNamed: should have found the test.");

    Class undefinedTestClass = [SLTest testNamed:NSStringFromSelector(_cmd)];
    STAssertNil(undefinedTestClass, @"+testNamed: should not have found a test.");
}

#pragma mark - Test case execution

- (void)testAllTestCasesRunByDefault {
    Class testWithSomeTestCasesTest = [TestWithSomeTestCases class];

    id testMock = [OCMockObject partialMockForClass:testWithSomeTestCasesTest];
    [[testMock expect] testOne];
    [[testMock expect] testTwo];
    [[testMock expect] testThree];
    [[testMock reject] testThatIsntATestBecauseItsReturnTypeIsNonVoid];
    [[testMock reject] testThatIsntATestBecauseItTakesAnArgument:OCMOCK_ANY];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithSomeTestCasesTest], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected.");
}

- (void)testiPhoneSpecificTestCasesOnlyRunOnTheiPhone {
    Class testWithPlatformSpecificTestCasesTest = [TestWithPlatformSpecificTestCases class];
    NSSet *testSet = [NSSet setWithObject:testWithPlatformSpecificTestCasesTest];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    id testMock = [OCMockObject partialMockForClass:testWithPlatformSpecificTestCasesTest];
    [[testMock expect] testFoo];
    [[testMock expect] testBaz_iPhone];
    [[testMock reject] testBar_iPad];

    SLRunTestsAndWaitUntilFinished(testSet, nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected on the iPhone.");
}

- (void)testiPadSpecificTestCasesOnlyRunOnTheiPad {
    Class testWithPlatformSpecificTestCasesTest = [TestWithPlatformSpecificTestCases class];
    NSSet *testSet = [NSSet setWithObject:testWithPlatformSpecificTestCasesTest];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    id testMock = [OCMockObject partialMockForClass:testWithPlatformSpecificTestCasesTest];
    [[testMock expect] testFoo];
    [[testMock expect] testBar_iPad];
    [[testMock reject] testBaz_iPhone];

    SLRunTestsAndWaitUntilFinished(testSet, nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected on the iPad.");
}

@end
