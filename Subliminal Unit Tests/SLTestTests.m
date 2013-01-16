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
#import "SharedSLTests.h"

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
        [TestWithNoTestCases class],
        [TestNotSupportingCurrentPlatform class],
        [TestWhichSupportsAllPlatforms class],
        [TestWhichSupportsOnlyiPad_iPad class],
        [TestWhichSupportsOnlyiPhone_iPhone class],
        [TestWithPlatformSpecificTestCases class],
        [StartupTest class],
        [TestThatIsNotFocused class],
        [TestWithAFocusedTestCase class],
        [TestWithSomeFocusedTestCases class],
        [TestWithAFocusedPlatformSpecificTestCase class],
        [Focus_TestThatIsFocused class],
        [Focus_TestThatIsFocusedButDoesntSupportCurrentPlatform class],
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

#pragma mark -General

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

- (void)testOnlyTestCasesSupportingCurrentPlatformAreRun {
    Class testWithPlatformSpecificTestCasesTest = [TestWithPlatformSpecificTestCases class];
    id testMock = [OCMockObject partialMockForClass:testWithPlatformSpecificTestCasesTest];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL supportedTestCaseSelector = @selector(testFoo);
    STAssertTrue([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:supportedTestCaseSelector],
                  @"For the purposes of this test, this test case must support the current platform.");
    // note: this causes the mock to expect the invocation of the test case selector, not performSelector: itself
    [[testMock expect] performSelector:supportedTestCaseSelector];

    SEL unsupportedTestCaseSelector = @selector(testCaseNotSupportingCurrentPlatform);
    STAssertFalse([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:unsupportedTestCaseSelector],
                  @"For the purposes of this test, this test case must not support the current platform.");
    // note: this causes the mock to expect the invocation of the test case selector, not performSelector: itself
    [[testMock reject] performSelector:unsupportedTestCaseSelector];
#pragma clang diagnostic pop

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithPlatformSpecificTestCasesTest], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected.");
}

- (void)testIfTestDoesNotSupportCurrentPlatformTestCasesWillNotRunRegardlessOfSupport {
    Class testNotSupportingCurrentPlatformClass = [TestNotSupportingCurrentPlatform class];
    STAssertFalse([testNotSupportingCurrentPlatformClass supportsCurrentPlatform],
                  @"For the purposes of this test, this SLTest must not support the current platform.");

    SEL supportedTestCaseSelector = @selector(testFoo);
    STAssertTrue([testNotSupportingCurrentPlatformClass instancesRespondToSelector:supportedTestCaseSelector] &&
                 [testNotSupportingCurrentPlatformClass testCaseWithSelectorSupportsCurrentPlatform:supportedTestCaseSelector],
                 @"For the purposes of this test, this SLTest must have a test case which supports the current platform.");

    id testNotSupportingCurrentPlatformClassMock = [OCMockObject partialMockForClass:testNotSupportingCurrentPlatformClass];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // note: this causes the mock to expect the invocation of the test case selector, not performSelector: itself
    [[testNotSupportingCurrentPlatformClassMock reject] performSelector:supportedTestCaseSelector];
#pragma clang diagnostic pop

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testNotSupportingCurrentPlatformClass], nil);
    STAssertNoThrow([testNotSupportingCurrentPlatformClassMock verify],
                    @"Test case supporting current platform was run despite its test not supporting the current platform.");
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

// this test verifies the complete order in which testing normally executes,
// but is mostly for illustration--it makes too many assertions
// traditional "unit" tests follow
- (void)testCompleteTestExecutionSequence {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];
    OCMExpectationSequencer *testSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];
    
    // *** Begin expected test run
    
    [[_loggerMock expect] logTestingStart];

    [[[testMock expect] andForwardToRealObject] run:[OCMArg anyPointer]];
    
    [[testMock expect] setUpTest];

    [[_loggerMock expect] logTest:NSStringFromClass(testClass) caseStart:@"testOne"];
    [[testMock expect] setUpTestCaseWithSelector:@selector(testOne)];
    [[testMock expect] testOne];
    [[testMock expect] tearDownTestCaseWithSelector:@selector(testOne)];
    [[_loggerMock expect] logTest:NSStringFromClass(testClass) casePass:@"testOne"];

    // The test's other cases will of course be executed
    // (as verified by -testAllTestCasesRunByDefault, above)
    // but we don't replicate their sequence here,
    // because we can't guarantee the order in which the cases will execute.

    [[testMock expect] tearDownTest];

    // It's possible for us to get the latter values below dynamically but it would just clutter this test.
    // These values will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(testClass) withNumCasesExecuted:3 numCasesFailed:0];

    [[_loggerMock expect] logTestingFinish];

    // *** End expected test run
    
    // Run tests and verify
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testSequencer verify], @"Testing did not execute in the expected sequence.");
}

- (void)testSetUpAndTearDownTest {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];
    [testMock setExpectationOrderMatters:YES];

    // *** Begin expected test run

    [[testMock expect] setUpTest];
    // We now reject any further invocations of -setUp.
    [[testMock reject] setUpTest];

    [[testMock expect] testOne];

    [[testMock expect] tearDownTest];
    // We now reject any further invocations of -tearDown.
    [[testMock reject] tearDownTest];

    // *** End expected test run

    // Run tests and verify
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"-setUpTest and -tearDownTest did not execute once, at the start and end of the test.");
}

- (void)testSetUpAndTearDownTestCase {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = nil;
    // because we can only can't guarantee the order in which test cases execute,
    // we must execute the test once for each test case, each time verifying the sequence for that test case alone
    for (NSString *testCaseName in @[ @"testOne", @"testTwo", @"testThree" ]) {
        // recreate the test mock each time to clear the expectations (on previously-expected test cases)
        [testMock stopMocking];
        testMock = [OCMockObject partialMockForClass:testClass];
        [testMock setExpectationOrderMatters:YES];

        SEL testCaseSelector = NSSelectorFromString(testCaseName);

        // *** Begin expected test run
        [[testMock expect] setUpTestCaseWithSelector:testCaseSelector];
        // We now reject any further invocations of -setUpTestCaseWithSelector:.
        [[testMock reject] setUpTestCaseWithSelector:testCaseSelector];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // note: this causes the mock to expect the invocation of the testCaseSelector, not performSelector: itself
        [[testMock expect] performSelector:testCaseSelector];
#pragma clang diagnostic pop

        [[testMock expect] tearDownTestCaseWithSelector:testCaseSelector];
        // We now reject any further invocations of -tearDownTestCaseWithSelector:.
        [[testMock reject] tearDownTestCaseWithSelector:testCaseSelector];

        // *** End expected test run

        // Run tests and verify
        SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
        STAssertNoThrow([testMock verify], @"-setUpTestCaseWithSelector: and -tearDownTestCaseWithSelector: did not execute once before and after each test case.");
    }
}

#pragma mark -Test setup and teardown

- (void)runWithTestFailingInTestSetupOrTeardownToTestAnErrorAndTestAbortAreLogged:(BOOL)failInSetUp {
    Class failingTestClass = [TestWithSomeTestCases class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ failingTestMock, _loggerMock ]];

    // *** Begin expected test run

    // If either setup or teardown fails...
    NSException *exception;
    if (failInSetUp) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test setup failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] setUpTest];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDownTest];
    }

    // ...the test controller logs an error...
    [[_loggerMock expect] logError:[OCMArg any]];

    // ...and the test controller logs the test as aborted (rather than finishing).
    [[_loggerMock expect] logTestAbort:NSStringFromClass(failingTestClass)];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, nil], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not fail/messages were not logged in the expected sequence.");
}

- (void)testIfTestSetupFailsAnErrorAndTestAbortAreLogged {
    [self runWithTestFailingInTestSetupOrTeardownToTestAnErrorAndTestAbortAreLogged:YES];
}

- (void)testIfTestTeardownFailsAnErrorAndTestAbortAreLogged {
    [self runWithTestFailingInTestSetupOrTeardownToTestAnErrorAndTestAbortAreLogged:NO];
}

- (void)runWithTestFailingInTestSetupOrTeardownToTestOtherTestsStillRun:(BOOL)failInSetUp {
    Class failingTestClass = [TestWithSomeTestCases class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If either setup or teardown fails...
    NSException *exception;
    if (failInSetUp) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test setup failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] setUpTest];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDownTest];
    }

    // ...the other test(s) should still run.
    Class otherTestClass = [TestWithPlatformSpecificTestCases class];
    id otherTestMock = [OCMockObject partialMockForClass:otherTestClass];
    [[otherTestMock expect] run:[OCMArg anyPointer]];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, otherTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Failing test did not run.");
    STAssertNoThrow([otherTestMock verify], @"Other test did not run.");
}

- (void)testIfTestSetupFailsOtherTestsStillRun {
    [self runWithTestFailingInTestSetupOrTeardownToTestOtherTestsStillRun:YES];
}

- (void)testIfTestTeardownFailsOtherTestsStillRun {
    [self runWithTestFailingInTestSetupOrTeardownToTestOtherTestsStillRun:NO];
}

- (void)testIfTestSetupFailsTestTeardownStillExecutes {
    Class failingTestClass = [TestWithSomeTestCases class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // if setup throws an exception...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                        reason:@"Test setup failed."
                                      userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] setUpTest];

    // we expect teardown to still execute
    [[failingTestMock expect] tearDownTest];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)testIfTestSetupFailsNoTestCasesAreExecuted {
    Class failingTestClass = [TestWithSomeTestCases class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // if setup throws an exception...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test setup failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] setUpTest];

    // none of the test cases should have executed
    [[failingTestMock reject] setUpTestCaseWithSelector:[OCMArg anySelector]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)runWithStartUpTestFailingInTestSetupOrTeardownToTestTestingAborts:(BOOL)failInSetUp {
    Class failingTestClass = [StartupTest class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If either setup or teardown of the start-up test fails...
    NSException *exception;
    if (failInSetUp) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test setup failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] setUpTest];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDownTest];
    }

    // ...the other test(s) don't run--the assumption being that the app failed to start up.
    Class otherTestClass = [TestWithPlatformSpecificTestCases class];
    id otherTestMock = [OCMockObject partialMockForClass:otherTestClass];
    [[otherTestMock reject] run:[OCMArg anyPointer]];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, otherTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Start-up test did not run.");
    STAssertNoThrow([otherTestMock verify], @"Other test ran despite failure of start-up test.");
}

- (void)testTestingAbortsIfSetUpOfStartUpClassFails {
    [self runWithStartUpTestFailingInTestSetupOrTeardownToTestTestingAborts:YES];
}

- (void)testTestingAbortsIfTearDownOfStartUpClassFails {
    [self runWithStartUpTestFailingInTestSetupOrTeardownToTestTestingAborts:NO];
}

#pragma mark -Test case setup and teardown

- (void)runWithTestFailingInTestCaseSetupOrTeardownToTestAnErrorAndTestCaseFailAreLogged:(BOOL)failInSetUp {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ failingTestMock, _loggerMock ]];

    // *** Begin expected test run

    // If either test case setup or teardown fails...
    NSException *exception;
    if (failInSetUp) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test case setup failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] setUpTestCaseWithSelector:failingTestCase];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test case teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDownTestCaseWithSelector:failingTestCase];
    }

    // ...the test catches the exception and logs an error...
    [[_loggerMock expect] logError:[OCMArg any] test:NSStringFromClass(failingTestClass) testCase:NSStringFromSelector(failingTestCase)];

    // ...and logs the test case failing...
    [[_loggerMock expect] logTest:NSStringFromClass(failingTestClass) caseFail:NSStringFromSelector(failingTestCase)];

    // ...and the test controller reports the test finishing with one test case failing.
    // These values will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(failingTestClass) withNumCasesExecuted:3 numCasesFailed:1];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not run/messages were not logged in the expected sequence.");
}

- (void)testIfTestCaseSetupFailsAnErrorAndTestCaseAreLogged {
    [self runWithTestFailingInTestCaseSetupOrTeardownToTestAnErrorAndTestCaseFailAreLogged:YES];
}

- (void)testIfTestCaseTeardownFailsAnErrorAndTestCaseFailAreLogged {
    [self runWithTestFailingInTestCaseSetupOrTeardownToTestAnErrorAndTestCaseFailAreLogged:NO];
}

- (void)testIfTestCaseSetupFailsTestCaseTeardownStillExecutes {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If test case setup fails...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case setup failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] setUpTestCaseWithSelector:failingTestCase];

    // ...test case tear-down is still executed
    [[failingTestMock expect] tearDownTestCaseWithSelector:failingTestCase];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)testIfTestCaseSetupFailsTestCaseDoesNotExecute {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If test case setup fails...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case setup failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] setUpTestCaseWithSelector:failingTestCase];

    // ...the test case does not execute.
    [[failingTestMock reject] testOne];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)runWithTestFailingInTestCaseSetupOrTeardownToTestOtherTestCasesStillExecute:(BOOL)failInSetUp {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If either test case setup or teardown fails...
    NSException *exception;
    if (failInSetUp) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test case setup failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] setUpTestCaseWithSelector:failingTestCase];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test case teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDownTestCaseWithSelector:failingTestCase];
    }

    // ...the other test cases still execute.
    [[failingTestMock expect] testTwo];
    [[failingTestMock expect] testThree];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)testIfTestCaseSetupFailsOtherTestCasesStillExecute {
    [self runWithTestFailingInTestCaseSetupOrTeardownToTestOtherTestCasesStillExecute:YES];
}

- (void)testIfTestCaseTeardownFailsOtherTestCasesStillExecute {
    [self runWithTestFailingInTestCaseSetupOrTeardownToTestOtherTestCasesStillExecute:NO];
}

#pragma mark -Test cases

- (void)testIfTestCaseDoesNotThrowTestCasePassIsLogged {
    Class testClass = [TestWithSomeTestCases class];
    SEL testCase = @selector(testOne);
    id testMock = [OCMockObject partialMockForClass:testClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];

    // *** Begin expected test run

    // If the test case does not throw an exception...
    [[testMock expect] testOne];

    // ...the test logs the case as passing...
    [[_loggerMock expect] logTest:NSStringFromClass(testClass) casePass:NSStringFromSelector(testCase)];

    // ...and the test controller reports the test finishing with no cases failing.
    // These values will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(testClass) withNumCasesExecuted:3 numCasesFailed:0];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not run/messages were not logged in the expected sequence.");
}

- (void)testIfTestCaseThrowsAnErrorAndTestCaseFailAreLogged {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ failingTestMock, _loggerMock ]];

    // *** Begin expected test run

    // If the test case fails...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] testOne];

    // ...the test catches the exception and logs an error...
    [[_loggerMock expect] logError:[OCMArg any] test:NSStringFromClass(failingTestClass) testCase:NSStringFromSelector(failingTestCase)];

    // ...and logs the test case failing...
    [[_loggerMock expect] logTest:NSStringFromClass(failingTestClass) caseFail:NSStringFromSelector(failingTestCase)];

    // ...and the test controller reports the test finishing with one case failing.
    // These values will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(failingTestClass) withNumCasesExecuted:3 numCasesFailed:1];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not fail/messages were not logged in the expected sequence.");
}

- (void)testIfTestCaseFailsTestCaseTearDownStillExecutes {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If the test case fails...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] testOne];

    // ...tearDownTestCaseWithSelector: still executes.
    [[failingTestMock expect] tearDownTestCaseWithSelector:failingTestCase];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)testIfTestCaseFailsOtherTestCasesStillExecute {
    Class failingTestClass = [TestWithSomeTestCases class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // *** Begin expected test run

    // If the test case fails...
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case failed."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] testOne];

    // ...the other test cases still execute.
    [[failingTestMock expect] testTwo];
    [[failingTestMock expect] testThree];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

#pragma mark -Focusing

- (void)testWhenSomeTestCasesAreFocusedOnlyThoseTestCasesRun {
    Class testWithAFocusedTestCaseClass = [TestWithAFocusedTestCase class];

    // expect only the focused test case to run
    id testWithAFocusedTestCaseClassMock = [OCMockObject partialMockForClass:testWithAFocusedTestCaseClass];
    [[testWithAFocusedTestCaseClassMock reject] testOne];
    [[testWithAFocusedTestCaseClassMock expect] focus_testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithAFocusedTestCaseClass], nil);
    STAssertNoThrow([testWithAFocusedTestCaseClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testMultipleTestCasesCanBeFocused {
    Class testWithSomeFocusedTestCasesClass = [TestWithSomeFocusedTestCases class];

    // expect only the focused test cases to run
    id testWithSomeFocusedTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeFocusedTestCasesClass];
    [[testWithSomeFocusedTestCasesClassMock reject] testOne];
    [[testWithSomeFocusedTestCasesClassMock expect] focus_testTwo];
    [[testWithSomeFocusedTestCasesClassMock expect] focus_testThree];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithSomeFocusedTestCasesClass], nil);
    STAssertNoThrow([testWithSomeFocusedTestCasesClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testWhenATestItselfIsFocusedAllOfItsTestCasesRun {
    Class testThatIsFocusedClass = [Focus_TestThatIsFocused class];
    STAssertTrue([[NSStringFromClass(testThatIsFocusedClass) lowercaseString] hasPrefix:@"focus_"],
                 @"For the purposes of this test, this SLTest itself must be focused.");

    // note that testTwo itself is focused, while testOne, itself, is not
    // but because the test itself is focused, *all* test cases are run: they are implicitly focused
    id testThatIsFocusedClassMock = [OCMockObject partialMockForClass:testThatIsFocusedClass];
    [[testThatIsFocusedClassMock expect] testOne];
    [[testThatIsFocusedClassMock expect] focus_testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testThatIsFocusedClass], nil);
    STAssertNoThrow([testThatIsFocusedClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testFocusedTestCasesMustSupportTheCurrentPlatformInOrderToRun {
    Class testWithAFocusedPlatformSpecificTestCaseClass = [TestWithAFocusedPlatformSpecificTestCase class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    // While testBar_iPad is focused, it doesn't support the current platform, thus isn't going to run.
    // If it's not going to run, its focus is irrelevant, and so the other test case should run after all.
    id testWithAFocusedPlatformSpecificTestCaseClassMock = [OCMockObject partialMockForClass:testWithAFocusedPlatformSpecificTestCaseClass];
    [[testWithAFocusedPlatformSpecificTestCaseClassMock reject] focus_testBar_iPad];
    [[testWithAFocusedPlatformSpecificTestCaseClassMock expect] testFoo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithAFocusedPlatformSpecificTestCaseClass], nil);
    STAssertNoThrow([testWithAFocusedPlatformSpecificTestCaseClassMock verify], @"Test cases did not execute as expected.");
}

#pragma mark - Test assertions

- (void)testAssertionLoggingIncludesFilenameAndLineNumber {
    Class testClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id testMock = [OCMockObject partialMockForClass:testClass];

    // verify that the test case is executed, then an error is logged
    OCMExpectationSequencer *sequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];

    // when testOne is executed, cause it to fail
    // and record the filename and line number that the failing assertion should use
    __block NSString *filenameAndLineNumberPrefix = nil;
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSString *__autoreleasing filename = nil; int lineNumber = 0;
        @try {
            [test slAssertFailAtFilename:&filename lineNumber:&lineNumber];
        }
        @catch (NSException *exception) {
            filenameAndLineNumberPrefix = [NSString stringWithFormat:@"%@:%d: ", filename, lineNumber];
            @throw exception;
        }
    }] testOne];

    // check that the error logged includes the filename and line number as recorded above
    [[_loggerMock expect] logError:[OCMArg checkWithBlock:^BOOL(id errorMessage) {
        return [errorMessage hasPrefix:filenameAndLineNumberPrefix];
    }] test:NSStringFromClass(testClass) testCase:NSStringFromSelector(failingTestCase)];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([sequencer verify], @"Test did not run/message was not logged in expected sequence.");
}

#pragma mark -SLAssertTrue

- (void)testSLAssertTrueThrowsIffExpressionIsFalse {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" assert true and succeed
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertTrue:^BOOL{
            return YES;
        }], @"Assertion should not have failed.");
    }] testOne];

    // have "testOne" assert true and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertTrue:^BOOL{
            return NO;
        }], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

#pragma mark -SLAssertFalse

- (void)testSLAssertFalseThrowsIffExpressionIsTrue {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" assert false and succeed
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertFalse:^BOOL{
            return NO;
        }], @"Assertion should not have failed.");
    }] testOne];

    // have "testTwo" assert false and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertFalse:^BOOL{
            return YES;
        }], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

#pragma mark -SLWaitOnCondition

- (void)testSLWaitOnConditionDoesNotThrowAndReturnsImmediatelyWhenConditionIsTrueUponWait {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" wait on a condition that evaluates to true, thus immediately return
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        
        STAssertNoThrow([test slWaitOnCondition:^BOOL{
            return YES;
        } withTimeout:1.5], @"Assertion should not have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        STAssertEqualsWithAccuracy(endTimeInterval, startTimeInterval, .01, @"Test should not have waited for an appreciable interval.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLWaitOnConditionDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testThree" wait on a condition that evaluates to false initially,
    // then to true partway through the timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval waitTimeout = 1.5;
        NSTimeInterval truthTimeout = 1.0;
        STAssertNoThrow([test slWaitOnCondition:^BOOL{
            NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval waitInterval = endTimeInterval - startTimeInterval;
            return (waitInterval >= truthTimeout);
        } withTimeout:waitTimeout], @"Assertion should not have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // check that the test waited for about the amount of time for the condition to evaluate to true
        STAssertEqualsWithAccuracy(endTimeInterval - startTimeInterval, truthTimeout, .25,
                                   @"Test should have only waited for about the amount of time necessary for the condition to become true.");
    }] testThree];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLWaitOnConditionThrowsIfConditionIsStillFalseAtEndOfTimeout {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testTwo" wait on a condition that evaluates to false, thus for the full timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval timeout = 1.5;
        STAssertThrows([test slWaitOnCondition:^BOOL{
            return NO;
        } withTimeout:timeout], @"Assertion should have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        STAssertEqualsWithAccuracy(endTimeInterval - startTimeInterval, timeout, .01,
                                   @"Test should have waited for the specified timeout.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

#pragma mark - Miscellaneous

#pragma mark -Wait

- (void)testWaitDelaysForSpecifiedInterval {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have testOne wait
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval waitTimeInterval = 1.5;
        [test wait:waitTimeInterval];
        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        STAssertEqualsWithAccuracy(endTimeInterval - startTimeInterval, waitTimeInterval, .01,
                                   @"Test did not delay for expected interval.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case was not executed as expected.");
}

@end
