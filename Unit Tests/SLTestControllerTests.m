//
//  SLTestControllerTests.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>
#import <Subliminal/SLTerminal.h>
#import <OCMock/OCMock.h>

#import "SLTest+Internal.h"
#import "TestUtilities.h"
#import "SharedSLTests.h"

@interface SLTestControllerTests : SenTestCase
@end

@implementation SLTestControllerTests {
    id _loggerMock, _terminalMock;
    id _loggerClassMock;

    NSSet *_testsUsedToTestRandomizationWithinRunGroups;
}

- (void)setUp {
    // Prevent the framework from trying to talk to UIAutomation.
    _loggerMock = [OCMockObject niceMockForClass:[SLLogger class]];
    _loggerClassMock = [OCMockObject partialMockForClassObject:[SLLogger class]];
    [[[_loggerClassMock stub] andReturn:_loggerMock] sharedLogger];

    // ensure that Subliminal doesn't get hung up trying to talk to UIAutomation
    _terminalMock = [OCMockObject partialMockForObject:[SLTerminal sharedTerminal]];
    [[_terminalMock stub] eval:OCMOCK_ANY];
    [[_terminalMock stub] shutDown];
}

- (void)setUpTestWithSelector:(SEL)testMethod {
    if ((testMethod == @selector(testTestsRunInRandomOrderWithinRunGroupsWhen_SLTestControllerRandomSeed_IsSpecified)) ||
        (testMethod == @selector(testTestsRunInDeterminateOrderWithinRunGroupsWhenASeedIsSpecified)) ||
        (testMethod == @selector(testTheSeedUsedIsLoggedIfATestFails)) ||
        (testMethod == @selector(testTheUserIsWarnedWhenUsingAPredeterminedSeed))) {
        _testsUsedToTestRandomizationWithinRunGroups = [NSSet setWithObjects:
            [TestWithSomeTestCases class],
            [TestWhichSupportsAllPlatforms class],
            [TestWithPlatformSpecificTestCases class],
            nil
        ];
        STAssertTrue([[_testsUsedToTestRandomizationWithinRunGroups valueForKey:@"runGroup"] count] == 1,
                     @"All tests used to test randomization within run groups must be of the same run group.");
    }
}

- (void)tearDownTestWithSelector:(SEL)testMethod {
    if (testMethod == @selector(testTheUserIsNotifiedWhenRunningTaggedTests)) {
        unsetenv("SL_TAGS");
    }
}

- (void)tearDown {
    [_terminalMock stopMocking];
    [_loggerMock stopMocking];
    [_loggerClassMock stopMocking];
}

#pragma mark - Test execution

#pragma mark -Sorting by run group

- (void)testTestsRunInAscendingOrderOfGroup {
    NSSet *tests = [NSSet setWithObjects:
        [TestOneOfRunGroupOne class],
        [TestTwoOfRunGroupOne class],
        [TestOneOfRunGroupTwo class],
        [TestTwoOfRunGroupTwo class],
        [TestThreeOfRunGroupTwo class],
        [TestOneOfRunGroupThree class],
        nil
    ];

    NSArray *const expectedRunOrder = [[[tests allObjects] valueForKey:@"runGroup"] sortedArrayUsingSelector:@selector(compare:)];

    // Record the run group of each test in the order they execute
    NSMutableArray *runOrder = [[NSMutableArray alloc] initWithCapacity:[tests count]];
    NSMutableArray *testMocks = [[NSMutableArray alloc] initWithCapacity:[tests count]];
    for (Class test in tests) {
        id testMock = [OCMockObject partialMockForClass:test];
        [[[[testMock expect] andDo:^(NSInvocation *invocation) {
            [runOrder addObject:@([test runGroup])];
        }] andForwardToRealObject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                    failed:[OCMArg anyPointer]
                                        failedUnexpectedly:[OCMArg anyPointer]];
        [testMocks addObject:testMock];
    }

    SLRunTestsAndWaitUntilFinished(tests, nil);
    [testMocks makeObjectsPerformSelector:@selector(stopMocking)];

    STAssertEqualObjects(runOrder, expectedRunOrder, @"Tests were not run in ascending order of group.");
}

#pragma mark -Randomization within run groups

- (NSArray *)mocksToRecordRunOrderOfTests:(NSSet *)testClasses inArray:(NSMutableArray *)runOrder {
    NSMutableArray *testMocks = [[NSMutableArray alloc] initWithCapacity:[testClasses count]];
    for (Class testClass in testClasses) {
        id testMock = [OCMockObject partialMockForClass:testClass];
        [[[[testMock expect] andDo:^(NSInvocation *invocation) {
            // actually track the test *class* so that run orders can be compared using `-[NSArray isEqual:]`
            [runOrder addObject:testClass];
        }] andForwardToRealObject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                    failed:[OCMArg anyPointer]
                                        failedUnexpectedly:[OCMArg anyPointer]];
        [testMocks addObject:testMock];
    }
    return [testMocks copy];
}

static const NSUInteger kNumSeedTrials = 100;
- (NSCountedSet *)runOrderDistributionForNumTrials:(NSUInteger)numTrials usingTests:(NSSet *)tests seed:(unsigned int)seed {
    NSCountedSet *orderDistribution = [[NSCountedSet alloc] init];
    NSUInteger runCount = 0;
    for (NSUInteger trialIndex = 0; trialIndex < numTrials; trialIndex++) {
        NSMutableArray *runOrder = [[NSMutableArray alloc] initWithCapacity:[tests count]];
        NSArray *testMocks = [self mocksToRecordRunOrderOfTests:tests inArray:runOrder];

        SLRunTestsUsingSeedAndWaitUntilFinished(tests, seed, nil);
        STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"One or more tests were not run.");
        [testMocks makeObjectsPerformSelector:@selector(stopMocking)];
        [orderDistribution addObject:runOrder];
        runCount++;
    }

    return orderDistribution;
}

- (void)testTestsRunInRandomOrderWithinRunGroupsWhen_SLTestControllerRandomSeed_IsSpecified {
    NSSet *tests = _testsUsedToTestRandomizationWithinRunGroups;

    // We'd like to verify that the distribution is uniform.
    // The real way to do that would be by a chi-squared test, but that math is tricky.
    // So, we just assert that we've seen every possible order after a large number of runs.
    __block NSUInteger runCount = 0;
    NSCountedSet *orderDistribution = [self runOrderDistributionForNumTrials:kNumSeedTrials usingTests:tests seed:SLTestControllerRandomSeed];
    const NSUInteger kNumPossibleOrders = 6; // 3!
    [orderDistribution enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSUInteger countThisPermutation = [orderDistribution countForObject:obj];
        runCount += countThisPermutation;
    }];

    STAssertTrue([orderDistribution count] == kNumPossibleOrders, @"Tests did not run in a sufficiently uniformly-random order when `SLTestControllerRandomSeed` was specified.");
    STAssertTrue(runCount == kNumSeedTrials, @"The order distribution did not account for all trials.");
}

- (void)testTestsRunInDeterminateOrderWithinRunGroupsWhenASeedIsSpecified {
    NSSet *tests = _testsUsedToTestRandomizationWithinRunGroups;

    const unsigned int seed = 716839131;
    NSCountedSet *orderDistribution = [self runOrderDistributionForNumTrials:kNumSeedTrials usingTests:tests seed:seed];
    STAssertTrue([orderDistribution count] == 1, @"Tests should always execute in the same order when a seed is specified.");
    STAssertTrue([orderDistribution countForObject:[[orderDistribution allObjects] lastObject]] == kNumSeedTrials,
                 @"The order distribution did not account for all trials.");
}

- (void)testTheSeedUsedIsLoggedIfATestFails {
    NSSet *tests = _testsUsedToTestRandomizationWithinRunGroups;

    NSMutableArray *firstRunOrder = [[NSMutableArray alloc] initWithCapacity:[tests count]];
    NSArray *testMocks = [self mocksToRecordRunOrderOfTests:tests inArray:firstRunOrder];

    // Cause a test case to fail
    id failingTestMock;
    for (id testMock in testMocks) {
        // find the mock which implements the test case we want to fail
        if ([testMock respondsToSelector:@selector(testOne)]) {
            failingTestMock = testMock;
            break;
        }
    }
    STAssertNotNil(failingTestMock,
                   @"At least one test (i.e. `TestWithSomeTestCases`) should have a test case called `testOne`,\
                   and should be mocked to track its execution order.");
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:@"Test case failed due to assertion failing."
                                                   userInfo:nil];
    [[[failingTestMock expect] andThrow:exception] testOne];

    // Expect testing to finish with a failure
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:[tests count] numTestsFailed:1];

    // Expect the seed to be logged, and capture it
    __block unsigned int seed = 0;
    [[_loggerMock expect] logMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        NSRegularExpression *seedExpression = [NSRegularExpression regularExpressionWithPattern:@"^The run order may be reproduced using seed (\\d+)\\.$"
                                                                                        options:0 error:NULL];
        NSTextCheckingResult *match = [seedExpression firstMatchInString:message options:0 range:NSMakeRange(0, [message length])];
        if (match) {
            NSRange rangeOfSeed = [match rangeAtIndex:1];
            NSString *seedAsString = [message substringWithRange:rangeOfSeed];
            sscanf([seedAsString UTF8String], "%u", &seed);
        }
        return (match != nil);
    }]];

    // Run tests
    SLRunTestsAndWaitUntilFinished(tests, nil);

    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"One or more tests were not run.");
    STAssertNoThrow([_loggerMock verify], @"The seed was not logged.");
    [testMocks makeObjectsPerformSelector:@selector(stopMocking)];

    NSMutableArray *secondRunOrder = [[NSMutableArray alloc] initWithCapacity:[tests count]];
    testMocks = [self mocksToRecordRunOrderOfTests:tests inArray:secondRunOrder];

    // Run tests again using the seed that we captured
    SLRunTestsUsingSeedAndWaitUntilFinished(tests, seed, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"One or more tests were not run.");

    // And expect the test order to have been reproduced
    STAssertTrue([secondRunOrder isEqualToArray:firstRunOrder], @"Test order was not reproduced.");
}

- (void)testTheUserIsWarnedWhenUsingAPredeterminedSeed {
    NSSet *tests = _testsUsedToTestRandomizationWithinRunGroups;

    const unsigned int seed = 716839131;

    // warning at start
    [[_loggerMock expect] logMessage:[NSString stringWithFormat:@"Running tests in order as predetermined by seed %u.", seed]];
    [[_loggerMock expect] logTestingStart];

    // Here we're hardcoding the number of tests that `runTestsUsingSeed:testsRanInSameOrder:` uses
    // --this will just have to be updated if that method changes
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:3 numTestsFailed:0];

    // warning at end
    NSString *const seedWarning = @"Tests were run in a predetermined order.";
    [[_loggerMock expect] logWarning:seedWarning];

    // verify that the warning was emitted
    SLRunTestsUsingSeedAndWaitUntilFinished(tests, seed, nil);
    STAssertNoThrow([_loggerMock verify], @"The user was not warned that test order was predetermined.");

    // and we don't expect these messages to be logged if we're not using a predetermined seed
    [[_loggerMock reject] logMessage:[OCMArg checkWithBlock:^BOOL(NSString *message) {
        NSRegularExpression *seedExpression = [NSRegularExpression regularExpressionWithPattern:@"^Running tests in order as predetermined by seed (\\d+)\\.$"
                                                                                        options:0 error:NULL];
        NSTextCheckingResult *match = [seedExpression firstMatchInString:message options:0 range:NSMakeRange(0, [message length])];
        return (match != nil);
    }]];
    [[_loggerMock reject] logWarning:seedWarning];
    SLRunTestsUsingSeedAndWaitUntilFinished(tests, SLTestControllerRandomSeed, nil);
    STAssertNoThrow([_loggerMock verify], @"The user should not have been given a warning.");
}

#pragma mark -Abstract tests

- (void)testAbstractTestsAreNotRun {
    Class abstractTestClass = [AbstractTest class];
    STAssertTrue([abstractTestClass isAbstract],
                 @"For the purposes of this test, this SLTest must be abstract.");

    id testMock = [OCMockObject partialMockForClass:abstractTestClass];
    [[testMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                        failed:[OCMArg anyPointer]
                            failedUnexpectedly:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:abstractTestClass], nil);
    STAssertNoThrow([testMock verify], @"Test was run despite not having any test cases.");
}

#pragma mark -Platform support

- (void)testOnlyTestsSupportingCurrentPlatformAreRun {
    Class testSupportingCurrentPlatformClass = [TestWithSomeTestCases class];
    STAssertTrue([testSupportingCurrentPlatformClass supportsCurrentPlatform],
                 @"For the purposes of this test, this SLTest must support the current platform.");
    id testSupportingCurrentPlatformMock = [OCMockObject partialMockForClass:testSupportingCurrentPlatformClass];
    [[testSupportingCurrentPlatformMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                 failed:[OCMArg anyPointer]
                                                     failedUnexpectedly:[OCMArg anyPointer]];

    Class testNotSupportingCurrentPlatformClass = [TestNotSupportingCurrentPlatform class];
    STAssertFalse([testNotSupportingCurrentPlatformClass supportsCurrentPlatform],
                  @"For the purposes of this test, this SLTest must not support the current platform.");
    id testNotSupportingCurrentPlatformMock = [OCMockObject partialMockForClass:testNotSupportingCurrentPlatformClass];
    [[testNotSupportingCurrentPlatformMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                    failed:[OCMArg anyPointer]
                                                        failedUnexpectedly:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:testSupportingCurrentPlatformClass, testNotSupportingCurrentPlatformClass, nil], nil);
    STAssertNoThrow([testSupportingCurrentPlatformMock verify], @"Test supporting current platform was not run as expected.");
    STAssertNoThrow([testNotSupportingCurrentPlatformMock verify], @"Test not supporting current platform was unexpectedly run.");
}

#pragma mark -Environment support

- (void)testOnlyTestsSupportingCurrentEnvironmentAreRun {
    Class testSupportingCurrentEnvironmentClass = [TestWithSomeTestCases class];
    STAssertTrue([testSupportingCurrentEnvironmentClass supportsCurrentEnvironment],
                 @"For the purposes of this test, this SLTest must support the current environment.");
    id testSupportingCurrentEnvironmentMock = [OCMockObject partialMockForClass:testSupportingCurrentEnvironmentClass];
    [[testSupportingCurrentEnvironmentMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                    failed:[OCMArg anyPointer]
                                                        failedUnexpectedly:[OCMArg anyPointer]];
    
    Class testNotSupportingCurrentEnvironmentClass = [TestNotSupportingCurrentEnvironment class];
    STAssertFalse([testNotSupportingCurrentEnvironmentClass supportsCurrentEnvironment],
                  @"For the purposes of this test, this SLTest must not support the current environment.");
    id testNotSupportingCurrentEnvironmentMock = [OCMockObject partialMockForClass:testNotSupportingCurrentEnvironmentClass];
    [[testNotSupportingCurrentEnvironmentMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                       failed:[OCMArg anyPointer]
                                                           failedUnexpectedly:[OCMArg anyPointer]];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObjects:testSupportingCurrentEnvironmentClass, testNotSupportingCurrentEnvironmentClass, nil], nil);
    STAssertNoThrow([testSupportingCurrentEnvironmentMock verify], @"Test supporting current environment was not run as expected.");
    STAssertNoThrow([testNotSupportingCurrentEnvironmentMock verify], @"Test not supporting current environment was unexpectedly run.");
}

- (void)testTheUserIsNotifiedWhenRunningTaggedTests {
    // use two classes so we can verify how multiple tags are concatenated
    NSSet *testClasses = [NSSet setWithObjects:[TestWithSomeTestCases class], [TestWithTagAAAandCCC class], nil];

    NSString *tagString = [[[testClasses allObjects] valueForKey:@"description"] componentsJoinedByString:@","];
    setenv("SL_TAGS", [tagString UTF8String], 1);
    
    // message
    NSString *tagDescriptionString = [[tagString componentsSeparatedByString:@","] componentsJoinedByString:@", "];
    [[_loggerMock expect] logMessage:[NSString stringWithFormat:@"Running test cases described by tags: %@.", tagDescriptionString]];
    [[_loggerMock expect] logTestingStart];
    
    SLRunTestsAndWaitUntilFinished([SLTest allTests], nil);
    STAssertNoThrow([_loggerMock verify], @"Test was not run/messages were not logged as expected.");
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
    [[testThatIsNotFocusedClassMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                             failed:[OCMArg anyPointer]
                                                 failedUnexpectedly:[OCMArg anyPointer]];

    id testWithSomeFocusedTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeFocusedTestCasesClass];
    [[testWithSomeFocusedTestCasesClassMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                     failed:[OCMArg anyPointer]
                                                         failedUnexpectedly:[OCMArg anyPointer]];

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
        // All SLTests used here must support the current platform and environment lest this test
        // overlap with `-testAFocusedTestMustSupportTheCurrentPlatformInOrderToBeRun`
        // and/or `-testAFocusedTestMustSupportTheCurrentEnvironmentInOrderToBeRun`
        STAssertTrue([testClass supportsCurrentPlatform],
                     @"All SLTests used by this test must support the current platform.");
        STAssertTrue([testClass supportsCurrentEnvironment],
                     @"All SLTests used by this test must support the current environment.");

        if ([testClass isFocused]) numberOfFocusedTests++;
    }
    STAssertTrue(numberOfFocusedTests > 0, @"For the purposes of this test, multiple tests must be focused.");

    NSMutableArray *testMocks = [NSMutableArray arrayWithCapacity:[tests count]];
    for (Class testClass in tests) {
        id testMock = [OCMockObject partialMockForClass:testClass];

        // expect test instances to be run only if they're focused
        if ([testClass isFocused]) {
            [[testMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                failed:[OCMArg anyPointer]
                                    failedUnexpectedly:[OCMArg anyPointer]];
        } else {
            [[testMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                failed:[OCMArg anyPointer]
                                    failedUnexpectedly:[OCMArg anyPointer]];
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
                  @"For the purposes of this test, this SLTest must not support the current platform.");

    NSSet *tests = [NSSet setWithObjects:
        testThatIsNotFocusedClass,
        testThatIsFocusedButDoesntSupportCurrentPlatformClass,
        nil
    ];

     // While TestThatIsFocusedButDoesntSupportCurrentPlatform is focused,
    // it doesn't support the current platform, thus isn't going to run.
    // If it's not going to run, its focus is irrelevant, and so the other test should run after all.
    id testThatIsFocusedButDoesntSupportCurrentPlatformClassMock = [OCMockObject partialMockForClass:testThatIsFocusedButDoesntSupportCurrentPlatformClass];
    [[testThatIsFocusedButDoesntSupportCurrentPlatformClassMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                                         failed:[OCMArg anyPointer]
                                                                             failedUnexpectedly:[OCMArg anyPointer]];

    id testThatIsNotFocusedClassMock = [OCMockObject partialMockForClass:testThatIsNotFocusedClass];
    [[testThatIsNotFocusedClassMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                             failed:[OCMArg anyPointer]
                                                 failedUnexpectedly:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testThatIsFocusedButDoesntSupportCurrentPlatformClassMock verify], @"Test doesn't support the current platform but was still run.");
    STAssertNoThrow([testThatIsNotFocusedClassMock verify], @"Other test was not run as expected.");
}

- (void)testAFocusedTestMustSupportTheCurrentEnvironmentInOrderToBeRun {
    Class testThatIsNotFocusedClass = [TestThatIsNotFocused class];
    STAssertFalse([testThatIsNotFocusedClass isFocused],
                  @"For the purposes of this test, this SLTest must not be focused.");
    Class testThatIsFocusedButDoesntSupportCurrentEnvironmentClass = [Focus_TestThatIsFocusedButDoesntSupportCurrentEnvironment class];
    STAssertTrue([testThatIsFocusedButDoesntSupportCurrentEnvironmentClass isFocused],
                 @"For the purposes of this test, this SLTest must be focused.");
    STAssertFalse([testThatIsFocusedButDoesntSupportCurrentEnvironmentClass supportsCurrentEnvironment],
                  @"For the purposes of this test, this SLTest must not support current environment.");
    
    NSSet *tests = [NSSet setWithObjects:
        testThatIsNotFocusedClass,
        testThatIsFocusedButDoesntSupportCurrentEnvironmentClass,
        nil
    ];
    
    // While `TestThatIsFocusedButDoesntSupportCurrentEnvironment` is focused,
    // it doesn't support the current environment, thus isn't going to run.
    // If it's not going to run, its focus is irrelevant, and so the other test should run after all.
    id testThatIsFocusedButDoesntSupportCurrentEnvironmentClassMock = [OCMockObject partialMockForClass:testThatIsFocusedButDoesntSupportCurrentEnvironmentClass];
    [[testThatIsFocusedButDoesntSupportCurrentEnvironmentClassMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                                            failed:[OCMArg anyPointer]
                                                                                failedUnexpectedly:[OCMArg anyPointer]];
    
    id testThatIsNotFocusedClassMock = [OCMockObject partialMockForClass:testThatIsNotFocusedClass];
    [[testThatIsNotFocusedClassMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                             failed:[OCMArg anyPointer]
                                                 failedUnexpectedly:[OCMArg anyPointer]];
    
    SLRunTestsAndWaitUntilFinished(tests, nil);
    STAssertNoThrow([testThatIsFocusedButDoesntSupportCurrentEnvironmentClassMock verify], @"Test doesn't support the current environment but was still run.");
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
    [[testWithSomeFocusedTestCasesClassMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                     failed:[OCMArg anyPointer]
                                                         failedUnexpectedly:[OCMArg anyPointer]];

    // ...and if it won't run, its focus is irrelevant, and so the other test should run after all.
    id testWithSomeTestCasesClassMock = [OCMockObject partialMockForClass:testWithSomeTestCasesClass];
    [[testWithSomeTestCasesClassMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                                              failed:[OCMArg anyPointer]
                                                  failedUnexpectedly:[OCMArg anyPointer]];

    SLRunTestsAndWaitUntilFinished(testsToRun, nil);
    STAssertNoThrow([testWithSomeFocusedTestCasesClassMock verify],
                    @"Focused test was run even though the SLTestController wasn't told to run it.");
    STAssertNoThrow([testWithSomeTestCasesClassMock verify], @"Other test was not run.");
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

    [[[testMock expect] andForwardToRealObject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                 failed:[OCMArg anyPointer]
                                                     failedUnexpectedly:[OCMArg anyPointer]];

    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:0];
    
    // warning at end
    [[_loggerMock expect] logWarning:@"This was a focused run. Fewer test cases may have run than normal."];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([sequencer verify], @"Test was not run/messages were not logged as expected.");
}

- (void)testTestsExecuteInSameRelativeOrderRegardlessOfFocusWhenUsingASeed {
    NSSet *testsToBeFocused = [NSSet setWithObjects:
       [TestWithSomeTestCases class],
       [TestWhichSupportsAllPlatforms class],
       [TestWithPlatformSpecificTestCases class],
       nil
    ];
    Class testToNotBeFocused = [TestThatIsNotFocused class];
    NSSet *allTests = [testsToBeFocused setByAddingObject:testToNotBeFocused];

    NSMutableArray *completeRunOrder = [[NSMutableArray alloc] initWithCapacity:[allTests count]];
    NSArray *testMocks = [self mocksToRecordRunOrderOfTests:allTests inArray:completeRunOrder];

    // Run all tests once with a seed so we can reproduce the order
    const unsigned int seed = 716839131;
    SLRunTestsUsingSeedAndWaitUntilFinished(allTests, seed, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"One or more tests were not run.");
    [testMocks makeObjectsPerformSelector:@selector(stopMocking)];

    // Determine the relative order in which the tests-to-be-focused ran
    NSMutableArray *unfocusedRunOrder = [[NSMutableArray alloc] initWithCapacity:[testsToBeFocused count]];
    for (Class testClass in completeRunOrder) {
        if ([testsToBeFocused member:testClass]) {
            [unfocusedRunOrder addObject:testClass];
        }
    }
    // sanity check
    STAssertTrue([unfocusedRunOrder count] == [testsToBeFocused count],
                 @"We should have just collected only that subset of tests that will be run with focus.");

    // force the tests-to-be-focused to become focused
    NSMutableArray *testClassMocks = [[NSMutableArray alloc] initWithCapacity:[testsToBeFocused count]];
    for (Class testClass in testsToBeFocused) {
        id testClassMock = [OCMockObject partialMockForClassObject:testClass];
        BOOL isFocused = YES;
        [[[testClassMock stub] andReturnValue:OCMOCK_VALUE(isFocused)] isFocused];
        // Ensure that regardless of how the test controller reads the focused state,
        // we'll return the new value ( https://github.com/inkling/ocmock/issues/15 )
        [[[testClassMock stub] andReturn:@(isFocused)] valueForKey:@"isFocused"];
        [testClassMocks addObject:testClassMock];
    }

    // Run all tests (but really just the focused ones) again
    NSMutableArray *focusedRunOrder = [[NSMutableArray alloc] initWithCapacity:[testsToBeFocused count]];
    testMocks = [self mocksToRecordRunOrderOfTests:testsToBeFocused inArray:focusedRunOrder];

    id testToNotBeFocusedMock = [OCMockObject partialMockForClass:testToNotBeFocused];
    [[testToNotBeFocusedMock reject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                      failed:[OCMArg anyPointer]
                                          failedUnexpectedly:[OCMArg anyPointer]];

    SLRunTestsUsingSeedAndWaitUntilFinished(allTests, seed, nil);
    STAssertNoThrow([testMocks makeObjectsPerformSelector:@selector(verify)], @"One or more focused tests were not run.");
    STAssertNoThrow([testToNotBeFocusedMock verify], @"Unfocused test was run despite other tests being focused.");

    // Expect the relative order of the focused tests to have been preserved
    STAssertTrue([focusedRunOrder isEqualToArray:unfocusedRunOrder],
                 @"The tests that were focused should have executed in the same relative order when focused\
                 as they had when unfocused.");
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
