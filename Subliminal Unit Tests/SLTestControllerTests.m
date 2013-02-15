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
#import "SharedSLTests.h"

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

#pragma mark - Test execution

#pragma mark -Abstract tests

- (void)testAbstractTestsAreNotRun {
    Class abstractTestClass = [AbstractTest class];
    STAssertTrue([abstractTestClass isAbstract],
                 @"For the purposes of this test, this SLTest must be abstract.");

    id testMock = [OCMockObject partialMockForClass:abstractTestClass];
    [[testMock reject] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:abstractTestClass], nil);
    STAssertNoThrow([testMock verify], @"Test was run despite not having any test cases.");
}

#pragma mark -Platform support

- (void)testOnlyTestsSupportingCurrentPlatformAreRun {
    NSSet *tests = [NSSet setWithObjects:
        [TestWithSomeTestCases class],
        [TestNotSupportingCurrentPlatform class],
        nil
    ];

    NSMutableArray *testMocks = [NSMutableArray arrayWithCapacity:[tests count]];
    for (Class testClass in tests) {
        id testMock = [OCMockObject partialMockForClass:testClass];

        // expect test instances to be run only if they're supported on the current platform
        if ([testClass supportsCurrentPlatform]) {
            [[testMock expect] run:[OCMArg anyPointer]];
        } else {
            [[testMock reject] run:[OCMArg anyPointer]];
        }
        
        [testMocks addObject:testMock];
    }

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"Tests were not run as expected.");
}

- (void)testiPhoneSpecificTestsOnlyRunOnTheiPhone {
    Class testWhichSupportsAllPlatformsClass = [TestWhichSupportsAllPlatforms class];
    Class testWhichSupportsOnlyiPadClass = [TestWhichSupportsOnlyiPad_iPad class];
    Class testWhichSupportsOnlyiPhoneClass = [TestWhichSupportsOnlyiPhone_iPhone class];
    NSSet *testSet = [NSSet setWithObjects:
        testWhichSupportsAllPlatformsClass,
        testWhichSupportsOnlyiPadClass,
        testWhichSupportsOnlyiPhoneClass,
        nil
    ];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    id testWhichSupportsAllPlatformsClassMock = [OCMockObject partialMockForClass:testWhichSupportsAllPlatformsClass];
    [[testWhichSupportsAllPlatformsClassMock expect] run:[OCMArg anyPointer]];

    id testWhichSupportsOnlyiPhoneClassMock = [OCMockObject partialMockForClass:testWhichSupportsOnlyiPhoneClass];
    [[testWhichSupportsOnlyiPhoneClassMock expect] run:[OCMArg anyPointer]];

    id testWhichSupportsOnlyiPadClassMock = [OCMockObject partialMockForClass:testWhichSupportsOnlyiPadClass];
    [[testWhichSupportsOnlyiPadClassMock reject] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(testSet, nil);
    STAssertNoThrow([testWhichSupportsOnlyiPadClassMock verify], @"Tests did not run as expected on the iPhone.");
}

- (void)testiPadSpecificTestsOnlyRunOnTheiPad {
    Class testWhichSupportsAllPlatformsClass = [TestWhichSupportsAllPlatforms class];
    Class testWhichSupportsOnlyiPadClass = [TestWhichSupportsOnlyiPad_iPad class];
    Class testWhichSupportsOnlyiPhoneClass = [TestWhichSupportsOnlyiPhone_iPhone class];
    NSSet *testSet = [NSSet setWithObjects:
                      testWhichSupportsAllPlatformsClass,
                      testWhichSupportsOnlyiPadClass,
                      testWhichSupportsOnlyiPhoneClass,
                      nil
                      ];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    id testWhichSupportsAllPlatformsClassMock = [OCMockObject partialMockForClass:testWhichSupportsAllPlatformsClass];
    [[testWhichSupportsAllPlatformsClassMock expect] run:[OCMArg anyPointer]];

    id testWhichSupportsOnlyiPadClassMock = [OCMockObject partialMockForClass:testWhichSupportsOnlyiPadClass];
    [[testWhichSupportsOnlyiPadClassMock expect] run:[OCMArg anyPointer]];

    id testWhichSupportsOnlyiPhoneClassMock = [OCMockObject partialMockForClass:testWhichSupportsOnlyiPhoneClass];
    [[testWhichSupportsOnlyiPhoneClassMock reject] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(testSet, nil);
    STAssertNoThrow([testWhichSupportsOnlyiPadClassMock verify], @"Tests did not run as expected on the iPad.");
}

#pragma mark -Startup test

- (void)testStartupTestIsRunFirst {
    Class startupTestClass = [StartupTest class];
    NSSet *tests = [NSSet setWithObjects:
        [TestWithSomeTestCases class],
        [TestWithPlatformSpecificTestCases class],
        startupTestClass,
        nil
    ];
    STAssertTrue([startupTestClass isStartUpTest], @"For the purposes of this test, this SLTest must be the start-up test.");

    NSMutableArray *orderedTests = [NSMutableArray arrayWithCapacity:[tests count]];
    NSMutableArray *testMocks = [NSMutableArray arrayWithCapacity:[tests count]];
    for (Class testClass in tests) {
        id testMock = [OCMockObject partialMockForClass:testClass];

        // cause tests to be recorded in order of execution
        [[[testMock stub] andDo:^(NSInvocation *invocation) {
            [orderedTests addObject:testClass];
        }] run:[OCMArg anyPointer]];

        [testMocks addObject:testMock];
    }

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertEqualObjects([orderedTests objectAtIndex:0], [StartupTest class],
                         @"The startup test was not run first.");
}

- (void)testStartupTestIsNotAutomaticallyAddedToTheSetOfTestsToRun {
    Class testWithSomeTestCasesClass = [TestWithSomeTestCases class];
    Class startupTestClass = [StartupTest class];
    STAssertTrue([startupTestClass isStartUpTest], @"For the purposes of this test, this SLTest must be the start-up test.");

    id testWithSomeTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeTestCasesClass];
    [[testWithSomeTestCasesClassMock expect] run:[OCMArg anyPointer]];

    id startupTestClassMock = [OCMockObject partialMockForClass:startupTestClass];
    [[startupTestClassMock reject] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithSomeTestCasesClass], nil);
    STAssertNoThrow([testWithSomeTestCasesClassMock verify], @"Test was not run as expected.");
    STAssertNoThrow([startupTestClassMock verify],
                    @"Start-up test was run even though the SLTestController wasn't told to run it.");
}

#pragma mark -Focusing

- (void)testWhenSomeTestsAreFocusedOnlyThoseTestsAreRun {
    Class testThatIsNotFocusedClass = [TestThatIsNotFocused class];
    STAssertFalse([testThatIsNotFocusedClass isFocused],
                  @"For the purposes of this test, this SLTest must not be focused.");
    Class testWithSomeFocusedTestCasesClass = [TestWithSomeFocusedTestCases class];
    STAssertTrue([testWithSomeFocusedTestCasesClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");
    NSSet *tests = [NSSet setWithObjects:
        testThatIsNotFocusedClass,
        testWithSomeFocusedTestCasesClass,
        nil
    ];

    // only the focused test should run
    id testThatIsNotFocusedClassMock = [OCMockObject partialMockForClass:testThatIsNotFocusedClass];
    [[testThatIsNotFocusedClassMock reject] run:[OCMArg anyPointer]];

    id testWithSomeFocusedTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeFocusedTestCasesClass];
    [[testWithSomeFocusedTestCasesClassMock expect] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testThatIsNotFocusedClassMock verify], @"Un-focused tests was still run.");
    STAssertNoThrow([testWithSomeFocusedTestCasesClassMock verify], @"Focused test was not run.");
}

- (void)testThatMultipleTestsCanBeFocusedAndRun {
    NSSet *tests = [NSSet setWithObjects:
        [TestThatIsNotFocused class],
        [TestWithSomeFocusedTestCases class],
        [Focus_TestThatIsFocused class],
        nil
    ];
    NSUInteger numberOfFocusedTests = 0;
    for (Class testClass in tests) {
        // All SLTests used here must support the current platform lest this test
        // overlap with -testTestsMustSupportCurrentPlatformInOrderToRunDespiteFocus.
        STAssertTrue([testClass supportsCurrentPlatform],
                     @"All SLTests used by this test must support the current platform.");

        if ([testClass isFocused]) numberOfFocusedTests++;
    }
    STAssertTrue(numberOfFocusedTests > 0, @"For the purposes of this test, multiple tests must be focused.");

    NSMutableArray *testMocks = [NSMutableArray arrayWithCapacity:[tests count]];
    for (Class testClass in tests) {
        id testMock = [OCMockObject partialMockForClass:testClass];

        // expect test instances to be run only if they're focused
        if ([testClass isFocused]) {
            [[testMock expect] run:[OCMArg anyPointer]];
        } else {
            [[testMock reject] run:[OCMArg anyPointer]];
        }

        [testMocks addObject:testMock];
    }

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"Tests were not run as expected.");
}

- (void)testAFocusedTestMustSupportTheCurrentPlatformInOrderToBeRun {
    Class testThatIsNotFocusedClass = [TestThatIsNotFocused class];
    STAssertFalse([testThatIsNotFocusedClass isFocused],
                  @"For the purposes of this test, this SLTest must not be focused.");
    Class testThatIsFocusedButDoesntSupportCurrentPlatformClass = [Focus_TestThatIsFocusedButDoesntSupportCurrentPlatform class];
    STAssertTrue([testThatIsFocusedButDoesntSupportCurrentPlatformClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");
    STAssertFalse([testThatIsFocusedButDoesntSupportCurrentPlatformClass supportsCurrentPlatform],
                  @"For the purposes of this test, this SLTest must not support current platform.");

    NSSet *tests = [NSSet setWithObjects:
        testThatIsNotFocusedClass,
        testThatIsFocusedButDoesntSupportCurrentPlatformClass,
        nil
    ];

     // While TestThatIsFocusedButDoesntSupportCurrentPlatform is focused,
    // it doesn't support the current platform, thus isn't going to run.
    // If it's not going to run, its focus is irrelevant, and so the other test should run after all.
    id testThatIsFocusedButDoesntSupportCurrentPlatformClassMock = [OCMockObject partialMockForClass:testThatIsFocusedButDoesntSupportCurrentPlatformClass];
    [[testThatIsFocusedButDoesntSupportCurrentPlatformClassMock reject] run:[OCMArg anyPointer]];

    id testThatIsNotFocusedClassMock = [OCMockObject partialMockForClass:testThatIsNotFocusedClass];
    [[testThatIsNotFocusedClassMock expect] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testThatIsFocusedButDoesntSupportCurrentPlatformClassMock verify], @"Test doesn't support the current platform but was still run.");
    STAssertNoThrow([testThatIsNotFocusedClassMock verify], @"Other test was not run as expected.");
}

- (void)testFocusedTestsAreNotAutomaticallyAddedToTheSetOfTestsToRun {
    Class testWithSomeTestCasesClass = [TestWithSomeTestCases class];
    STAssertFalse([testWithSomeTestCasesClass isFocused],
                  @"For the purposes of this test, this SLTest must not be focused.");
    Class testWithSomeFocusedTestCasesClass = [TestWithSomeFocusedTestCases class];
    STAssertTrue([testWithSomeFocusedTestCasesClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");

    // The test controller won't be told to run the focused test, thus it won't be run...
    NSSet *testsToRun = [NSSet setWithObject:testWithSomeTestCasesClass];

    id testWithSomeFocusedTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeFocusedTestCasesClass];
    [[testWithSomeFocusedTestCasesClassMock reject] run:[OCMArg anyPointer]];

    // ...and if it won't run, its focus is irrelevant, and so the other test should run after all.
    id testWithSomeTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeTestCasesClass];
    [[testWithSomeTestCasesClassMock expect] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(testsToRun, nil);
    STAssertNoThrow([testWithSomeFocusedTestCasesClassMock verify],
                    @"Focused test was run even though the SLTestController wasn't told to run it.");
    STAssertNoThrow([testWithSomeTestCasesClassMock verify], @"Other test was not run.");
}

- (void)testStartupTestIsNotRunIfItIsNotFocused {
    Class startupTestClass = [StartupTest class];
    STAssertTrue([startupTestClass isStartUpTest],
                 @"For the purposes of this test, this SLTest must be start-up test.");
    STAssertFalse([startupTestClass isFocused],
                  @"For the purposes of this test, this SLTest must not be focused.");
    Class testWithSomeFocusedTestCasesClass = [TestWithSomeFocusedTestCases class];
    STAssertTrue([testWithSomeFocusedTestCasesClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");

    NSSet *tests = [NSSet setWithObjects:
        startupTestClass,
        testWithSomeFocusedTestCasesClass,
        nil
    ];

    // only the focused test should run
    id startupTestClassMock = [OCMockObject partialMockForClass:startupTestClass];
    [[startupTestClassMock reject] run:[OCMArg anyPointer]];

    id testWithSomeFocusedTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeFocusedTestCasesClass];
    [[testWithSomeFocusedTestCasesClassMock expect] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([startupTestClassMock verify], @"Un-focused tests was still run.");
    STAssertNoThrow([testWithSomeFocusedTestCasesClassMock verify], @"Focused test was not run.");
}

- (void)testTheUserIsWarnedWhenRunningFocusedTests {
    Class testClass = [TestWithSomeFocusedTestCases class];
    STAssertTrue([testClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");
    id testMock = [OCMockObject partialMockForClass:testClass];
    OCMExpectationSequencer *sequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];

    // warning at start
    [[_loggerMock expect] logMessage:[NSString stringWithFormat:@"Focusing on test cases in specific tests: %@.", testClass]];
    [[_loggerMock expect] logTestingStart];

    [[testMock expect] run:[OCMArg anyPointer]];

    [[_loggerMock expect] logTestingFinish];
    // warning at end
    [[_loggerMock expect] logMessage:@"Warning: this was a focused run. Fewer test cases may have run than normal."];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([sequencer verify], @"Test was not run/messages were not logged as expected.");
}

#pragma mark - Miscellaneous

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
