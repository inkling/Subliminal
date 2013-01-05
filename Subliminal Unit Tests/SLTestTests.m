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
    
    [[testMock expect] setUp];

    [[_loggerMock expect] logTest:NSStringFromClass(testClass) caseStart:@"testOne"];
    [[testMock expect] setUpTestCaseWithSelector:@selector(testOne)];
    [[testMock expect] testOne];
    [[testMock expect] tearDownTestCaseWithSelector:@selector(testOne)];
    [[_loggerMock expect] logTest:NSStringFromClass(testClass) casePass:@"testOne"];

    // The test's other cases will of course be executed
    // (as verified by -testAllTestCasesRunByDefault, above)
    // but we don't replicate their sequence here,
    // because we can't guarantee the order in which the cases will execute.

    [[testMock expect] tearDown];

    // It's possible for us to get the latter values below dynamically but it would just clutter this test.
    // These values will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(testClass) withNumCasesExecuted:3 numCasesFailed:0];

    [[_loggerMock expect] logTestingFinish];

    // *** End expected test run
    
    // Run tests and verify
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testSequencer verify], @"Testing did not execute in the expected sequence.");
}

- (void)testSetUpAndTearDownExecuteOnceAtTheStartAndEndOfEachTest {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];
    [testMock setExpectationOrderMatters:YES];

    // *** Begin expected test run

    [[testMock expect] setUp];
    // We now reject any further invocations of -setUp.
    [[testMock reject] setUp];

    [[testMock expect] testOne];

    [[testMock expect] tearDown];
    // We now reject any further invocations of -tearDown.
    [[testMock reject] tearDown];

    // *** End expected test run

    // Run tests and verify
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"-setUp and -tearDown did not execute once, at the start and end of the test.");
}

- (void)testSetUpTestCaseWithSelectorAndTearDownTestCaseWithSelectorExecuteOnceBeforeAndAfterEachTestCase {
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
        [[[failingTestMock expect] andThrow:exception] setUp];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDown];
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
        [[[failingTestMock expect] andThrow:exception] setUp];
    } else {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test teardown failed."
                                          userInfo:nil];
        [[[failingTestMock expect] andThrow:exception] tearDown];
    }

    // ...the other test(s) should still run.
    Class otherTestClass = [TestWithPlatformSpecificTestCases class];
    id otherTestMock = [OCMockObject partialMockForClass:otherTestClass];
    [[otherTestMock expect] run:[OCMArg anyPointer]];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, otherTestClass, nil], nil);
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
    [[[failingTestMock expect] andThrow:exception] setUp];

    // we expect teardown to still execute
    [[failingTestMock expect] tearDown];

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
    [[[failingTestMock expect] andThrow:exception] setUp];

    // none of the test cases should have executed
    [[failingTestMock reject] setUpTestCaseWithSelector:[OCMArg anySelector]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Test did not run as expected.");
}

- (void)testTestingAbortsIfSetUpOfStartUpClassFails {
    Class failingTestClass = [StartupTest class];
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];

    // If the startup test fails...
    NSException *setUpException = [NSException exceptionWithName:SLTestAssertionFailedException
                                                          reason:@"Test setup failed."
                                                        userInfo:nil];
    [[[failingTestMock expect] andThrow:setUpException] setUp];

    // ...the other tests don't run--the assumption being that the app failed to start up.
    Class otherTestClass = [TestWithPlatformSpecificTestCases class];
    id otherTestMock = [OCMockObject partialMockForClass:otherTestClass];
    [[otherTestMock reject] run:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:failingTestClass, otherTestClass, nil], nil);
    STAssertNoThrow([failingTestMock verify], @"Failing test did not run.");
    STAssertNoThrow([otherTestMock verify], @"Other test should not have executed.");
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
