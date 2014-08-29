//
//  SLTestTests.m
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
#import <objc/runtime.h>

#import "TestUtilities.h"
#import "SharedSLTests.h"
#import "SLTest+Internal.h"

@interface SLTestTests : SenTestCase

@end

@implementation SLTestTests {
    id _loggerMock, _terminalMock;
    NSSet *_tags;
}

- (void)setUp {
    _loggerMock = [OCMockObject partialMockForObject:[SLLogger sharedLogger]];

    // ensure that Subliminal doesn't get hung up trying to talk to UIAutomation
    _terminalMock = [OCMockObject partialMockForObject:[SLTerminal sharedTerminal]];
    [[_terminalMock stub] eval:OCMOCK_ANY];
    [[_terminalMock stub] shutDown];
}

- (void)setUpTestWithSelector:(SEL)testMethod {
    _tags = nil;
}

- (void)tearDownTestWithSelector:(SEL)testMethod {
    // only unset `SL_TAGS` if we did set it, for performance
    if (_tags) unsetenv("SL_TAGS");
}

- (void)tearDown {
    [_terminalMock stopMocking];
    [_loggerMock stopMocking];
}

#pragma mark - Test lookup

- (void)testAllTestsReturnsExpected {
    NSSet *allTests = [SLTest allTests];
    NSSet *expectedTests = [NSSet setWithObjects:
        [SLTest class],
        [TestWithSomeTestCases class],
        [AbstractTest class],
        [TestNotSupportingCurrentPlatform class],
        [TestWhichSupportsAllPlatforms class],
        [TestWhichSupportsOnlyiPad_iPad class],
        [TestWhichSupportsOnlyiPhone_iPhone class],
        [TestWithPlatformSpecificTestCases class],
        [TestNotSupportingCurrentEnvironment class],
        [TestWithEnvironmentSpecificTestCases class],
        [AbstractTestWhichSupportsOnly_iPad class],
        [ConcreteTestWhichSupportsOnlyiPad class],
        [TestThatIsNotFocused class],
        [TestWithAFocusedTestCase class],
        [TestWithSomeFocusedTestCases class],
        [TestWithAFocusedPlatformSpecificTestCase class],
        [TestWithAFocusedEnvironmentSpecificTestCase class],
        [Focus_TestThatIsFocused class],
        [Focus_TestWhereNarrowestFocusApplies class],
        [Focus_TestThatIsFocusedButDoesntSupportCurrentPlatform class],
        [Focus_TestThatIsFocusedButDoesntSupportCurrentEnvironment class],
        [Focus_AbstractTestThatIsFocused class],
        [ConcreteTestThatIsFocused class],
        [AbstractRunGroupOneTest class],
        [TestOneOfRunGroupOne class],
        [TestTwoOfRunGroupOne class],
        [AbstractRunGroupTwoTest class],
        [TestOneOfRunGroupTwo class],
        [TestTwoOfRunGroupTwo class],
        [TestThreeOfRunGroupTwo class],
        [TestOneOfRunGroupThree class],
        [TestWithTagAAAandCCC class],
        [TestWithTagBBBandCCC class],
        [TestWithSomeTaggedTestCases class],
        nil
    ];
    STAssertEqualObjects(allTests, expectedTests, @"Unexpected tests returned.");
}

- (void)testTestsWithTagsIncludesTestsWithAtLeastOneSpecifiedTag {
    NSSet *tags = [NSSet setWithObject:@"CCC"];
    NSSet *expectedTests = [NSSet setWithObjects:[TestWithTagAAAandCCC class], [TestWithTagBBBandCCC class], nil];
    NSSet *actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should return all tests that have at least one of the specified tags.");
    
    tags = [NSSet setWithObjects:@"AAA", @"BBB", nil];
    actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should not require tests to have _all_ the specified tags.");
}

- (void)testTestsWithTagsExcludesTestsWithAnyMinusPrefixedTagsSpecified {
    NSSet *tags = [NSSet setWithObjects:@"CCC", nil];
    NSSet *expectedTests = [NSSet setWithObjects:[TestWithTagAAAandCCC class], [TestWithTagBBBandCCC class], nil];
    NSSet *actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should return all tests that have at least one of the specified tags.");
    
    tags = [NSSet setWithObjects:@"CCC", @"-BBB", nil];
    expectedTests = [NSSet setWithObject:[TestWithTagAAAandCCC class]];
    actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should have excluded those tests tagged with the '-'-prefixed tags.");

    tags = [NSSet setWithObjects:@"CCC", @"-CCC", nil];
    actualTests = [SLTest testsWithTags:tags];
    STAssertFalse([actualTests count], @"`+testsWithTags:` should have returned no tests.");
    
    tags = [NSSet setWithObjects:@"CCC", @"-AAA", @"-BBB", nil];
    actualTests = [SLTest testsWithTags:tags];
    STAssertFalse([actualTests count], @"`+testsWithTags:` should have returned no tests.");
}

- (void)testTestsWithTagsIncludesAllTestsExceptThoseTaggedIfOnlyMinusPrefixedTagsAreSpecified {
    NSSet *tags = [NSSet setWithObjects:@"CCC", @"-BBB", nil];
    NSSet *expectedTests = [NSSet setWithObject:[TestWithTagAAAandCCC class]];
    NSSet *actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should have included only those tests that did have the regular tags, which tests did not also have the '-'-prefixed tags.");
    
    tags = [NSSet setWithObjects:@"-BBB", nil];
    expectedTests = [[SLTest allTests] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"NONE SELF.tags CONTAINS 'BBB'"]];
    actualTests = [SLTest testsWithTags:tags];
    STAssertEqualObjects(expectedTests, actualTests,
                         @"`+testsWithTags:` should have included all tests except for those that had the '-'-prefixed tags.");
}

- (void)testTagsDefaultToUnfocusedTestNamePlusSuperclassNamesAndRunGroup {
    STAssertEqualObjects([TestWithSomeTestCases tags], [NSSet setWithArray:(@[ @"TestWithSomeTestCases", @"1" ])], @"");
    STAssertEqualObjects([Focus_TestThatIsFocused tags], [NSSet setWithArray:(@[ @"TestThatIsFocused", @"1" ])], @"");
    
    // test superclasses that are and are not focused
    STAssertEqualObjects([ConcreteTestWhichSupportsOnlyiPad tags],
                         [NSSet setWithArray:(@[ @"AbstractTestWhichSupportsOnly_iPad", @"ConcreteTestWhichSupportsOnlyiPad", @"1" ])], @"");
    STAssertEqualObjects([ConcreteTestThatIsFocused tags],
                         [NSSet setWithArray:(@[ @"AbstractTestThatIsFocused", @"ConcreteTestThatIsFocused", @"1" ])], @"");
}

- (void)testTagsForTestCaseWithSelectorDefaultsToTestTagsAndUnfocusedTestCaseName {
    Class testClass = [TestWithAFocusedTestCase class];
    NSSet *testTags = [testClass tags];
    
    STAssertEqualObjects([testClass tagsForTestCaseWithSelector:@selector(testOne)], [testTags setByAddingObject:@"testOne"], @"");
    STAssertEqualObjects([testClass tagsForTestCaseWithSelector:@selector(focus_testTwo)], [testTags setByAddingObject:@"testTwo"], @"");
    // we should be able to retrieve the tags using the unfocused selector too
    STAssertEqualObjects([testClass tagsForTestCaseWithSelector:@selector(testTwo)], [testTags setByAddingObject:@"testTwo"], @"");
}

- (void)testTestNamedReturnsExpected {
    Class validTestClass = [TestWithSomeTestCases class];
    Class resultTestClass = [SLTest testNamed:NSStringFromClass(validTestClass)];
    STAssertEqualObjects(resultTestClass, validTestClass, @"+testNamed: should have found the test.");

    Class undefinedTestClass = [SLTest testNamed:NSStringFromSelector(_cmd)];
    STAssertNil(undefinedTestClass, @"+testNamed: should not have found a test.");
}

- (void)testTestNamedReturnsFocusedTests {   // with or without the prefix
    Class validTestClass = [Focus_TestThatIsFocused class];
    
    Class resultTestClass = [SLTest testNamed:NSStringFromClass(validTestClass)];
    STAssertEqualObjects(resultTestClass, validTestClass, @"+testNamed: should have found the test.");

    NSString *unprefixedTestClassName = [NSStringFromClass(validTestClass) substringFromIndex:[SLTestFocusPrefix length]];
    resultTestClass = [SLTest testNamed:unprefixedTestClassName];
    STAssertEqualObjects(resultTestClass, validTestClass, @"+testNamed: should have found the test even without the prefix.");
}

#pragma mark - Abstract tests

- (void)testATestIsAbstractIfItDefinesNoTestCases {
    Class abstractTestClass = [AbstractTest class];
    STAssertFalse([[abstractTestClass testCases] count],
                  @"For the purposes of this test, this SLTest class must not define any test cases.");
    STAssertTrue([abstractTestClass isAbstract], @"This SLTest class should be abstract.");

    Class concreteTestClass = [TestWithSomeTestCases class];
    STAssertTrue([[concreteTestClass testCases] count],
                 @"For the purposes of this test, this SLTest class must define test cases.");
    STAssertFalse([concreteTestClass isAbstract], @"This SLTest class should not be abstract.");
}

#pragma mark - Platform support

- (void)testTestsSupportCurrentPlatformByDefault {
    // `SLTest` itself does not support the current platform because it does not
    // define test cases, but a test which _does_ define test cases...
    Class testClass = [TestWithSomeTestCases class];
    
    // ...and does not override `+supportsCurrentPlatform`...
    SEL supportsCurrentPlatformSelector = @selector(supportsCurrentPlatform);
    Method defaultSupportsCurrentPlatform = class_getClassMethod([SLTest class], supportsCurrentPlatformSelector);
    Method testSupportsCurrentPlatform = class_getClassMethod(testClass, supportsCurrentPlatformSelector);
    STAssertTrue(testSupportsCurrentPlatform == defaultSupportsCurrentPlatform,
                 @"For the purposes of this test, the test class must not override `+supportsCurrentPlatform`.");
    
    // ...should support the current platform.
    STAssertTrue([testClass supportsCurrentPlatform], @"Tests should support the current platform by default.");
}

- (void)testTestsWithoutTestCasesSupportingTheCurrentPlatformDontSupportCurrentPlatform {
    // It's trivially true that none of `SLTest`'s test cases support the current platform,
    // because it doesn't have any.
    STAssertFalse([SLTest supportsCurrentPlatform],
                  @"A test without test cases supporting the current platform should not support the current platform.");
}

- (void)testTestsWithiPhoneSuffixOnlySupportiPhone {
    Class testWhichSupportsOnlyiPhoneClass = [TestWhichSupportsOnlyiPhone_iPhone class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    __block UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentUserInterfaceIdiom];
    }] userInterfaceIdiom];

    STAssertTrue([testWhichSupportsOnlyiPhoneClass supportsCurrentPlatform],
                 @"Test with '_iPhone' suffix should support the iPhone.");

    currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    STAssertFalse([testWhichSupportsOnlyiPhoneClass supportsCurrentPlatform],
                  @"Test with '_iPhone' suffix should not support the iPad.");
}

- (void)testTestsWithiPadSuffixOnlySupportiPad {
    Class testWhichSupportsOnlyiPadClass = [TestWhichSupportsOnlyiPad_iPad class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    __block UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    [[[deviceMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentUserInterfaceIdiom];
    }] userInterfaceIdiom];

    STAssertTrue([testWhichSupportsOnlyiPadClass supportsCurrentPlatform],
                 @"Test with '_iPad' suffix should support the iPad.");

    currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    STAssertFalse([testWhichSupportsOnlyiPadClass supportsCurrentPlatform],
                  @"Test with '_iPad' suffix should not support the iPhone.");
}

- (void)testPlatformSupportAnnotationsAffectSubclasses {
    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    __block UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentUserInterfaceIdiom];
    }] userInterfaceIdiom];

    Class baseClass = [AbstractTestWhichSupportsOnly_iPad class];
    
    // `AbstractTestWhichSupportsOnly_iPad` itself does not support any platform
    // because it does not define test cases, but a test which _does_ define test cases...
    Class subclass = [ConcreteTestWhichSupportsOnlyiPad class];
    
    // ...and does not override `+supportsCurrentPlatform`...
    SEL supportsCurrentPlatformSelector = @selector(supportsCurrentPlatform);
    Method defaultSupportsCurrentPlatform = class_getClassMethod(baseClass, supportsCurrentPlatformSelector);
    Method testSupportsCurrentPlatform = class_getClassMethod(subclass, supportsCurrentPlatformSelector);
    STAssertTrue(testSupportsCurrentPlatform == defaultSupportsCurrentPlatform,
                 @"For the purposes of this test, the subclass must not override `+supportsCurrentPlatform`.");
    
    // ...should behave as expected, given the base class' annotation.
    STAssertFalse([subclass supportsCurrentPlatform],
                  @"The subclass should not support the iPhone.");
    currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    STAssertTrue([ConcreteTestWhichSupportsOnlyiPad supportsCurrentPlatform],
                 @"The subclass should support the iPad.");
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
    // note: this causes the mock to reject the invocation of the test case selector, not performSelector: itself
    [[testNotSupportingCurrentPlatformClassMock reject] performSelector:supportedTestCaseSelector];
#pragma clang diagnostic pop

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testNotSupportingCurrentPlatformClass], nil);
    STAssertNoThrow([testNotSupportingCurrentPlatformClassMock verify],
                    @"Test case supporting current platform was run despite its test not supporting the current platform.");
}

- (void)testTestCasesWithiPhoneSuffixOnlySupportiPhone {
    Class testWithPlatformSpecificTestCasesTest = [TestWithPlatformSpecificTestCases class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    __block UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentUserInterfaceIdiom];
    }] userInterfaceIdiom];

    STAssertTrue([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:@selector(testBaz_iPhone)],
                 @"Test case with '_iPhone' suffix should support the iPhone.");

    currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    STAssertFalse([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:@selector(testBaz_iPhone)],
                  @"Test case with '_iPhone' suffix should not support the iPad.");
}

- (void)testTestCasesWithiPadSuffixOnlySupportiPad {
    Class testWithPlatformSpecificTestCasesTest = [TestWithPlatformSpecificTestCases class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    __block UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPad;
    [[[deviceMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentUserInterfaceIdiom];
    }] userInterfaceIdiom];

    STAssertTrue([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:@selector(testBar_iPad)],
                 @"Test case with '_iPad' suffix should support the iPad.");

    currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    STAssertFalse([testWithPlatformSpecificTestCasesTest testCaseWithSelectorSupportsCurrentPlatform:@selector(testBar_iPad)],
                  @"Test case with '_iPhone' suffix should not support the iPhone.");
}

#pragma mark - Environment support

- (void)testTestsSupportCurrentEnvironmentByDefault {
    // `SLTest` itself does not support the current environment because it does not
    // define test cases, but a test which _does_ define test cases...
    Class testClass = [TestWithSomeTestCases class];
    
    // ...and does not override `+supportsCurrentEnvironment`...
    SEL supportsCurrentEnvironmentSelector = @selector(supportsCurrentEnvironment);
    Method defaultSupportsCurrentEnvironment = class_getClassMethod([SLTest class], supportsCurrentEnvironmentSelector);
    Method testSupportsCurrentEnvironment = class_getClassMethod(testClass, supportsCurrentEnvironmentSelector);
    STAssertTrue(testSupportsCurrentEnvironment == defaultSupportsCurrentEnvironment,
                 @"For the purposes of this test, the test class must not override `+supportsCurrentEnvironment`.");
    
    // ...should support the current environment.
    STAssertTrue([testClass supportsCurrentEnvironment], @"Tests should support the current environment by default.");
}

- (void)testTestsWithoutTestCasesSupportingTheCurrentEnvironmentDontSupportCurrentEnvironment {
    // It's trivially true that none of `SLTest`'s test cases support the current environment,
    // because it doesn't have any.
    STAssertFalse([SLTest supportsCurrentEnvironment],
                  @"A test without test cases supporting the current environment should not support the current environment.");
}

- (void)testOnlyTestCasesSupportingCurrentEnvironmentAreRun {
    Class testWithEnvironmentSpecificTestCasesTest = [TestWithEnvironmentSpecificTestCases class];
    id testMock = [OCMockObject partialMockForClass:testWithEnvironmentSpecificTestCasesTest];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL supportedTestCaseSelector = @selector(testFoo);
    STAssertTrue([testWithEnvironmentSpecificTestCasesTest testCaseWithSelectorSupportsCurrentEnvironment:supportedTestCaseSelector],
                 @"For the purposes of this test, this test case must support the current environment.");
    // note: this causes the mock to expect the invocation of the test case selector, not performSelector: itself
    [[testMock expect] performSelector:supportedTestCaseSelector];
    
    SEL unsupportedTestCaseSelector = @selector(testCaseNotSupportingCurrentEnvironment);
    STAssertFalse([testWithEnvironmentSpecificTestCasesTest testCaseWithSelectorSupportsCurrentEnvironment:unsupportedTestCaseSelector],
                  @"For the purposes of this test, this test case must not support the current environment.");
    // note: this causes the mock to expect the invocation of the test case selector, not performSelector: itself
    [[testMock reject] performSelector:unsupportedTestCaseSelector];
#pragma clang diagnostic pop
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithEnvironmentSpecificTestCasesTest], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected.");
}

- (NSSet *)testCasesSupportingTheCurrentEnvironmentOfTest:(Class)testClass {
    return [[testClass testCases] filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *testCaseName, NSDictionary *bindings) {
        return [testClass testCaseWithSelectorSupportsCurrentEnvironment:NSSelectorFromString(testCaseName)];
    }]];
}

- (void)setSLTAGS:(NSSet *)tags {
    _tags = tags;
    setenv("SL_TAGS", [[[tags allObjects] componentsJoinedByString:@","] UTF8String], 1);
}

- (void)testAllTestCasesSupportTheCurrentEnvironmentIfNoTagsAreSpecified {
    STAssertFalse(getenv("SL_TAGS"), @"For the purposes of this test case, `SL_TAGS` must not be set.");
    
    Class testClass = [TestWithSomeTaggedTestCases class];

    for (NSString *testCaseName in [testClass testCases]) {
        STAssertTrue([testClass testCaseWithSelectorSupportsCurrentEnvironment:NSSelectorFromString(testCaseName)],
                     @"Test case did not support the current environment as expected.");
    }
}

// this is an emergent property of test cases inheriting their tests' tags,
// but is sufficiently-important a use case to test separately
- (void)testAllTestCasesSupportTheCurrentEnvironmentIfTheirTestsNameIsSpecifiedAsATag {
    Class testClass = [TestWithSomeTaggedTestCases class];
    [self setSLTAGS:[NSSet setWithObject:NSStringFromClass(testClass)]];
    
    for (NSString *testCaseName in [testClass testCases]) {
        STAssertTrue([testClass testCaseWithSelectorSupportsCurrentEnvironment:NSSelectorFromString(testCaseName)],
                     @"Test case did not support the current environment as expected.");
    }
}

- (void)testTestCasesSupportTheCurrentEnvironmentIfTheyAreTaggedWithAtLeastOneSpecifiedTag {
    Class testClass = [TestWithSomeTaggedTestCases class];
    
    [self setSLTAGS:[NSSet setWithObject:@"CCC"]];
    NSSet *expectedTestCases = [NSSet setWithObjects:@"testCaseWithTagAAAandCCC", @"testCaseWithTagBBBandCCC", nil];
    NSSet *actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"All test cases that have at least one of the specified tags should support the current environment.");
    
    [self setSLTAGS:[NSSet setWithObjects:@"AAA", @"BBB", nil]];
    actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"Test cases should not be required to have _all_ the specified tags in order to support the current environment.");
}

- (void)testTestCasesDoNotSupportTheCurrentEnvironmentIfTheyAreTaggedWithAMinusPrefixedTag {
    Class testClass = [TestWithSomeTaggedTestCases class];

    [self setSLTAGS:[NSSet setWithObject:@"CCC"]];
    NSSet *expectedTestCases = [NSSet setWithObjects:@"testCaseWithTagAAAandCCC", @"testCaseWithTagBBBandCCC", nil];
    NSSet *actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"All test cases that have at least one of the specified tags should support the current environment");
    
    [self setSLTAGS:[NSSet setWithObjects:@"CCC", @"-BBB", nil]];
    expectedTestCases = [NSSet setWithObjects:@"testCaseWithTagAAAandCCC", nil];
    actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"Test cases tagged with the '-'-prefixed tags should not support the current environment.");
    
    [self setSLTAGS:[NSSet setWithObjects:@"CCC", @"-CCC", nil]];
    actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertFalse([actualTestCases count], @"No test cases should support the current environment.");
    
    [self setSLTAGS:[NSSet setWithObjects:@"CCC", @"-AAA", @"-BBB", nil]];
    actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertFalse([actualTestCases count], @"No test cases should support the current environment.");
}

- (void)testAllTestCasesExceptThoseTaggedSupportTheCurrentEnvironmentIfOnlyMinusPrefixedTagsAreSpecified {
    Class testClass = [TestWithSomeTaggedTestCases class];

    [self setSLTAGS:[NSSet setWithObjects:@"CCC", @"-BBB", nil]];
    NSSet *expectedTestCases = [NSSet setWithObjects:@"testCaseWithTagAAAandCCC", nil];
    NSSet *actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"`The only test cases to support the current environment should be those test cases that do not have the regular tags, which test cases do not also have the '-'-prefixed tags.");
    
    [self setSLTAGS:[NSSet setWithObjects:@"-BBB", nil]];
    expectedTestCases = [[testClass testCases] filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *testCaseName, NSDictionary *bindings) {
        return ![[testClass tagsForTestCaseWithSelector:NSSelectorFromString(testCaseName)] containsObject:@"BBB"];
    }]];
    actualTestCases = [self testCasesSupportingTheCurrentEnvironmentOfTest:testClass];
    STAssertEqualObjects(expectedTestCases, actualTestCases,
                         @"All test cases should support the current environment except for those that have the '-'-prefixed tags.");
}

- (void)testIfTestDoesNotSupportCurrentEnvironmentTestCasesWillNotRunRegardlessOfSupport {
    Class testNotSupportingCurrentEnvironmentClass = [TestNotSupportingCurrentEnvironment class];
    STAssertFalse([testNotSupportingCurrentEnvironmentClass supportsCurrentEnvironment],
                  @"For the purposes of this test, this SLTest must not support the current environment.");
    
    SEL supportedTestCaseSelector = @selector(testFoo);
    STAssertTrue([testNotSupportingCurrentEnvironmentClass instancesRespondToSelector:supportedTestCaseSelector] &&
                 [testNotSupportingCurrentEnvironmentClass testCaseWithSelectorSupportsCurrentEnvironment:supportedTestCaseSelector],
                 @"For the purposes of this test, this SLTest must have a test case which supports the current environment.");
    
    id testNotSupportingCurrentEnvironmentClassMock = [OCMockObject partialMockForClass:testNotSupportingCurrentEnvironmentClass];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // note: this causes the mock to reject the invocation of the test case selector, not performSelector: itself
    [[testNotSupportingCurrentEnvironmentClassMock reject] performSelector:supportedTestCaseSelector];
#pragma clang diagnostic pop
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testNotSupportingCurrentEnvironmentClass], nil);
    STAssertNoThrow([testNotSupportingCurrentEnvironmentClassMock verify],
                    @"Test case supporting current environment was run despite its test not supporting the current environment.");
}

#pragma mark - Focusing

- (void)testTestsAreNotFocusedByDefault {
    STAssertFalse([SLTest isFocused], @"Tests should not be focused by default.");
}

- (void)testATestIsFocusedWhenItsNameIsPrefixed {   // a "focus annotation"
    Class testThatIsFocusedClass = [Focus_TestThatIsFocused class];
    STAssertTrue([[NSStringFromClass(testThatIsFocusedClass) lowercaseString] hasPrefix:SLTestFocusPrefix],
                 @"For the purposes of this test, this SLTest class' name must be prefixed.");
    STAssertTrue([testThatIsFocusedClass isFocused], @"This SLTest class should be focused.");
}

- (void)testATestIsFocusedWhenATestCaseIsFocused {  // that is, when that test case's name is prefixed
    Class testThatIsFocusedClass = [TestWithAFocusedTestCase class];
    SEL focusedTestCaseSelector = @selector(focus_testTwo);
    STAssertTrue([testThatIsFocusedClass instancesRespondToSelector:focusedTestCaseSelector],
                 @"For the purposes of this test, this SLTest class must have a focused test case.");
    STAssertTrue([testThatIsFocusedClass isFocused], @"This SLTest class should be focused.");
}

- (void)testFocusAnnotationsAffectSubclasses {
    Class concreteTestClass = [ConcreteTestThatIsFocused class];
    STAssertFalse([[NSStringFromClass(concreteTestClass) lowercaseString] hasPrefix:SLTestFocusPrefix],
                  @"For the purposes of this test, this SLTest class should not have a focus annotation.");

    Class abstractTestClass = [Focus_AbstractTestThatIsFocused class];
    STAssertTrue([[NSStringFromClass(abstractTestClass) lowercaseString] hasPrefix:SLTestFocusPrefix],
                 @"For the purposes of this test, this SLTest class should have a focus annotation.");

    STAssertTrue([concreteTestClass isSubclassOfClass:abstractTestClass],
                 @"For the purposes of this test, this SLTest class should be a subclass of a class with a focus annotation.");

    STAssertTrue([concreteTestClass isFocused],
                 @"This SLTest class should be focused despite not having a focus annotation,\
                 because its superclass has a focus annotation.");
}

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
    STAssertTrue([[NSStringFromClass(testThatIsFocusedClass) lowercaseString] hasPrefix:SLTestFocusPrefix],
                 @"For the purposes of this test, this SLTest itself must be focused.");

    // note that testFoo itself is not focused
    // but because the test itself is focused, testFoo will still run
    id testThatIsFocusedClassMock = [OCMockObject partialMockForClass:testThatIsFocusedClass];
    [[testThatIsFocusedClassMock expect] testFoo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testThatIsFocusedClass], nil);
    STAssertNoThrow([testThatIsFocusedClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testNarrowestFocusApplies {
    Class testWhereNarrowestFocusAppliesClass = [Focus_TestWhereNarrowestFocusApplies class];
    STAssertTrue([[NSStringFromClass(testWhereNarrowestFocusAppliesClass) lowercaseString] hasPrefix:SLTestFocusPrefix],
                 @"For the purposes of this test, this SLTest itself must be focused.");

    // note that testTwo itself is focused, while testOne, itself, is not
    // because the narrowest focus applies, only testTwo is run, even though the test is focused
    id testWhereNarrowestFocusAppliesClassMock = [OCMockObject partialMockForClass:testWhereNarrowestFocusAppliesClass];
    [[testWhereNarrowestFocusAppliesClassMock reject] testOne];
    [[testWhereNarrowestFocusAppliesClassMock expect] focus_testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWhereNarrowestFocusAppliesClass], nil);
    STAssertNoThrow([testWhereNarrowestFocusAppliesClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testMethodsThatTakeTestCaseSelectorsAsArgumentsAreInvokedWithUnfocusedSelectors {
    Class testWithAFocusedTestCaseClass = [TestWithAFocusedTestCase class];

    id testWithAFocusedTestCaseClassObjectMock = [OCMockObject partialMockForClassObject:testWithAFocusedTestCaseClass];
    id testWithAFocusedTestCaseClassMock = [OCMockObject partialMockForClass:testWithAFocusedTestCaseClass];

    // expect the focused test case to run
    [[testWithAFocusedTestCaseClassMock expect] focus_testTwo];

    // but expect the test infrastructure to use the unfocused selector
    // this allows test writers to avoid modifying the rest of their test when they focus a test case
    // make sure we invoke the real implementations of `-testCaseWithSelectorSupportsCurrentPlatform:`
    // and `-testCaseWithSelectorSupportsCurrentEnvironment:` or else the case won't run!
    [[[testWithAFocusedTestCaseClassObjectMock expect] andForwardToRealObject] testCaseWithSelectorSupportsCurrentPlatform:@selector(testTwo)];
    [[[testWithAFocusedTestCaseClassObjectMock expect] andForwardToRealObject] testCaseWithSelectorSupportsCurrentEnvironment:@selector(testTwo)];
    [[testWithAFocusedTestCaseClassMock expect] setUpTestCaseWithSelector:@selector(testTwo)];
    [[testWithAFocusedTestCaseClassMock expect] tearDownTestCaseWithSelector:@selector(testTwo)];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithAFocusedTestCaseClass], nil);
    STAssertNoThrow([testWithAFocusedTestCaseClassObjectMock verify], @"Test cases did not execute as expected.");
    STAssertNoThrow([testWithAFocusedTestCaseClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testFocusedTestCasesMustSupportTheCurrentPlatformInOrderToRun {
    Class testWithAFocusedPlatformSpecificTestCaseClass = [TestWithAFocusedPlatformSpecificTestCase class];

    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];

    // While `testBar_iPad` is focused, it doesn't support the current platform, thus isn't going to run.
    // However, its being focused should exclude the other test case from running too.
    id testWithAFocusedPlatformSpecificTestCaseClassMock = [OCMockObject partialMockForClass:testWithAFocusedPlatformSpecificTestCaseClass];
    [[testWithAFocusedPlatformSpecificTestCaseClassMock reject] focus_testBar_iPad];
    [[testWithAFocusedPlatformSpecificTestCaseClassMock reject] testFoo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithAFocusedPlatformSpecificTestCaseClass], nil);
    STAssertNoThrow([testWithAFocusedPlatformSpecificTestCaseClassMock verify], @"Test cases did not execute as expected.");
}

- (void)testFocusedTestCasesMustSupportTheCurrentEnvironmentInOrderToRun {
    Class testWithAFocusedEnvironmentSpecificTestCaseClass = [TestWithAFocusedEnvironmentSpecificTestCase class];
    
    // we mock the current device to dynamically configure the current user interface idiom
    id deviceMock = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    UIUserInterfaceIdiom currentUserInterfaceIdiom = UIUserInterfaceIdiomPhone;
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(currentUserInterfaceIdiom)] userInterfaceIdiom];
    
    // While `testBar` is focused, it doesn't support the current environment, thus isn't going to run.
    // However, its being focused should exclude the other test from running too.
    id testWithAFocusedEnvironmentSpecificTestCaseClassMock = [OCMockObject partialMockForClass:testWithAFocusedEnvironmentSpecificTestCaseClass];
    [[testWithAFocusedEnvironmentSpecificTestCaseClassMock reject] focus_testBar];
    [[testWithAFocusedEnvironmentSpecificTestCaseClassMock reject] testFoo];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithAFocusedEnvironmentSpecificTestCaseClass], nil);
    STAssertNoThrow([testWithAFocusedEnvironmentSpecificTestCaseClassMock verify], @"Test cases did not execute as expected.");
}

#pragma mark - Test case execution

#pragma mark -General

- (void)testAllTestCasesRunByDefault {
    Class testWithSomeTestCasesTest = [TestWithSomeTestCases class];

    id testMock = [OCMockObject partialMockForClass:testWithSomeTestCasesTest];
    [[testMock expect] testOne];
    [[testMock expect] testTwo];
    [[testMock expect] testThree];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithSomeTestCasesTest], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not run as expected.");
}

- (void)testInvalidTestCasesAreNotRun {
    Class testWithSomeTestCasesTest = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testWithSomeTestCasesTest];

    [[testMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                        failed:[OCMArg anyPointer]
                            failedUnexpectedly:[OCMArg anyPointer]];

    [[testMock reject] testThatIsntATestBecauseItsReturnTypeIsNonVoid];
    [[testMock reject] testThatIsntATestBecauseItTakesAnArgument:OCMOCK_ANY];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testWithSomeTestCasesTest], nil);
    STAssertNoThrow([testMock verify], @"Invalid test cases were unexpectedly run.");
}

// this test verifies the complete order in which testing normally executes,
// but is mostly for illustration--it makes too many assertions
// traditional "unit" tests follow
- (void)testCompleteTestRunSequence {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];
    OCMExpectationSequencer *testSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];
    
    // *** Begin expected test run
    
    [[_loggerMock expect] logTestingStart];

    [[[testMock expect] andForwardToRealObject] runAndReportNumExecuted:[OCMArg anyPointer]
                                                                 failed:[OCMArg anyPointer]
                                                     failedUnexpectedly:[OCMArg anyPointer]];

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
    [[_loggerMock expect] logTestFinish:NSStringFromClass(testClass)
                           withNumCasesExecuted:3 numCasesFailed:0 numCasesFailedUnexpectedly:0];

    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:0];

    // *** End expected test run
    
    // Run tests and verify
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testSequencer verify], @"Testing did not execute in the expected sequence.");
}

#pragma mark -Test setup and teardown

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

    // ...and the test controller logs the test as aborted (rather than finishing)...
    [[_loggerMock expect] logTestAbort:NSStringFromClass(failingTestClass)];

    // ...and the test controller logs testing as finishing with one test executed, one test failing.
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:1];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
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
    [[otherTestMock expect] runAndReportNumExecuted:[OCMArg anyPointer]
                                             failed:[OCMArg anyPointer]
                                 failedUnexpectedly:[OCMArg anyPointer]];

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
    [[_loggerMock expect] logError:[OCMArg any]];

    // ...and the test controller reports the test finishing with one test case having failed...
    // (and that failure was "expected" because it was due to an assertion failing)
    // (these values will need to be updated if the test class' definition changes)
    [[_loggerMock expect] logTestFinish:NSStringFromClass(failingTestClass)
                          withNumCasesExecuted:3 numCasesFailed:1 numCasesFailedUnexpectedly:0];

    // ...and the test controller logs testing as finishing with one test executed, one test failing.
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:1];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not run/messages were not logged in the expected sequence.");
}

- (void)testIfTestCaseSetupFailsAnErrorAndTestCaseFailAreLogged {
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

- (void)runWithTestFailingInTestCaseSetupWithExpectedFailure:(BOOL)expectedFailureInSetup
             andFailingInTestCaseTeardownWithExpectedFailure:(BOOL)expectedFailureInTeardown {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ failingTestMock, _loggerMock ]];

    NSException *(^exceptionWithReason)(BOOL, NSString *) = ^(BOOL expected, NSString *reason) {
        NSString *name = expected ? SLTestAssertionFailedException : NSInternalInconsistencyException;
        return [NSException exceptionWithName:name reason:reason userInfo:nil];
    };

    // *** Begin expected test run

    // If test case setup fails...
    NSException *setUpException = exceptionWithReason(expectedFailureInSetup, @"Test case setup failed.");
    [[[failingTestMock expect] andThrow:setUpException] setUpTestCaseWithSelector:failingTestCase];

    // ...the test catches and logs the exception...
    [[_loggerMock expect] logError:[OCMArg any]];

    // ...and then if test case teardown fails...
    NSException *tearDownException = exceptionWithReason(expectedFailureInTeardown, @"Test case teardown failed.");
    [[[failingTestMock expect] andThrow:tearDownException] tearDownTestCaseWithSelector:failingTestCase];

    // ...the test again catches and logs the exception...
    [[_loggerMock expect] logError:[OCMArg any]];

    // ...but when the test logs the test case as failing,
    // that failure is reported as "expected" or not depending on the first exception (setup) thrown...
    [[_loggerMock expect] logTest:NSStringFromClass(failingTestClass)
                         caseFail:NSStringFromSelector(failingTestCase)
                         expected:expectedFailureInSetup];

    // ...and when the test controller reports the test finishing,
    // that failure is reported as "expected" or not depending on the setup exception.
    // The values for cases executed, etc. will need to be updated if the test class' definition changes.
    [[_loggerMock expect] logTestFinish:NSStringFromClass(failingTestClass)
                   withNumCasesExecuted:3 numCasesFailed:1 numCasesFailedUnexpectedly:(expectedFailureInSetup ? 0 : 1)];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not run/messages were not logged in the expected sequence.");

    // necessary so that subsequent invocations of this method,
    // within the same turn of the event loop, can create new mocks
    [failingTestSequencer stopSequencing];
    [failingTestMock stopMocking];
}

- (void)testIfBothTestCaseSetupAndTeardownFailSetupFailureDeterminesExpectedStatus {
    [self runWithTestFailingInTestCaseSetupWithExpectedFailure:YES andFailingInTestCaseTeardownWithExpectedFailure:YES];
    [self runWithTestFailingInTestCaseSetupWithExpectedFailure:YES andFailingInTestCaseTeardownWithExpectedFailure:NO];
    [self runWithTestFailingInTestCaseSetupWithExpectedFailure:NO andFailingInTestCaseTeardownWithExpectedFailure:YES];
    [self runWithTestFailingInTestCaseSetupWithExpectedFailure:NO andFailingInTestCaseTeardownWithExpectedFailure:NO];
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

    // ...and the test controller reports the test finishing with no cases failing...
    // (these values will need to be updated if the test class' definition changes)
    [[_loggerMock expect] logTestFinish:NSStringFromClass(testClass)
                          withNumCasesExecuted:3 numCasesFailed:0 numCasesFailedUnexpectedly:0];

    // ...and the test controller logs testing as finishing with one test executed, no tests failing.
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:0];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not run/messages were not logged in the expected sequence.");
}

- (void)runWithFailureInTestCaseDueToAssertionException:(BOOL)failWithAssertionException {
    Class failingTestClass = [TestWithSomeTestCases class];
    SEL failingTestCase = @selector(testOne);
    id failingTestMock = [OCMockObject partialMockForClass:failingTestClass];
    OCMExpectationSequencer *failingTestSequencer = [OCMExpectationSequencer sequencerWithMocks:@[ failingTestMock, _loggerMock ]];

    // *** Begin expected test run

    // A failure is "unexpected" unless it was caused by an assertion failing.
    NSException *exception;
    if (failWithAssertionException) {
        exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                            reason:@"Test case failed due to assertion failing."
                                          userInfo:nil];
    } else {
        exception = [NSException exceptionWithName:SLUIAElementNotTappableException
                                            reason:@"Test case failed because element was not tappable."
                                          userInfo:nil];
    }
    [[[failingTestMock expect] andThrow:exception] testOne];

    // ...the test catches the exception and logs an error...
    [[_loggerMock expect] logError:[OCMArg any]];

    // ...and logs the test case failing...
    [[_loggerMock expect] logTest:NSStringFromClass(failingTestClass)
                         caseFail:NSStringFromSelector(failingTestCase)
                         expected:failWithAssertionException];

    // ...and the test controller reports the test finishing with one case failing...
    // (these values will need to be updated if the test class' definition changes)
    [[_loggerMock expect] logTestFinish:NSStringFromClass(failingTestClass)
                          withNumCasesExecuted:3
                         numCasesFailed:1
             numCasesFailedUnexpectedly:(failWithAssertionException ? 0 : 1)];

    // ...and the test controller logs testing as finishing with one test executed, one test failing.
    [[_loggerMock expect] logTestingFinishWithNumTestsExecuted:1 numTestsFailed:1];

    // *** End expected test run

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:failingTestClass], nil);
    STAssertNoThrow([failingTestSequencer verify], @"Test did not fail/messages were not logged in the expected sequence.");
}

- (void)testIfTestCaseThrowsAssertionExceptionAnErrorAndExpectedFailureAreLogged {
    [self runWithFailureInTestCaseDueToAssertionException:YES];
}

- (void)testIfTestCaseThrowsAnotherExceptionAnErrorAndUnexpectedFailureAreLogged {
    [self runWithFailureInTestCaseDueToAssertionException:NO];
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

// Note: throughout the below tests, we provide implementations of SLTest test cases
// that mimic how test writers would use SLTest assertions in those cases,
// and verify that the assertions succeed or fail as expected.
// But, we can't use the assertion macros directly, because they make reference
// to SLTest members when expanded, hence the methods in SLTest (SLTestTestsMacroHelpers).

- (void)testAssertionLoggingIncludesFilenameAndLineNumber {
    Class testClass = [TestWithSomeTestCases class];
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
    }]];

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

// this test confirms that you can assert the "truth" of a non-nil object (that is, that it is not nil)
// http://www.mikeash.com/pyblog/friday-qa-2012-12-14-objective-c-pitfalls.html, 
// "Casting to BOOL" describes the problem that SLAssertTrue must avoid
- (void)testSLAssertTrueDoesNotThrowOnExpressionWithZeroFirstByte {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertTrueWithUnsignedInteger:^NSUInteger{
            return 0xFF00;
        }], @"Assertion should not have failed.");
    }] testOne];

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

#pragma mark -SLAssertTrueWithTimeout

- (void)testSLAssertTrueWithTimeoutDoesNotThrowAndReturnsImmediatelyWhenConditionIsTrueUponWait {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" wait on a condition that evaluates to true, thus immediately return
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        
        STAssertNoThrow([test SLAssertTrueWithTimeout:^BOOL{
            return YES;
        } withTimeout:1.5], @"Assertion should not have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // note that `SLAssertTrueWithTimeout` should not wait at all here, thus the variability
        // is not `SLIsTrueRetryDelay` like the cases below
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval < .01, @"Test should not have waited for an appreciable interval.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLAssertTrueWithTimeoutDoesNotThrowAndReturnsImmediatelyAfterConditionBecomesTrue {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testThree" wait on a condition that evaluates to false initially,
    // then to true partway through the timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval waitTimeout = 1.5;
        NSTimeInterval truthTimeout = 1.0;
        STAssertNoThrow([test SLAssertTrueWithTimeout:^BOOL{
            NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval waitInterval = endTimeInterval - startTimeInterval;
            return (waitInterval >= truthTimeout);
        } withTimeout:waitTimeout], @"Assertion should not have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // check that the test waited for about the amount of time for the condition to evaluate to true
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval - truthTimeout < SLIsTrueRetryDelay,
                     @"Test should have only waited for about the amount of time necessary for the condition to become true.");
    }] testThree];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLAssertTrueWithTimeoutThrowsIfConditionIsStillFalseAtEndOfTimeout {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testTwo" wait on a condition that evaluates to false, thus for the full timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval timeout = 1.5;
        STAssertThrows([test SLAssertTrueWithTimeout:^BOOL{
            return NO;
        } withTimeout:timeout], @"Assertion should have failed.");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval - timeout < SLIsTrueRetryDelay,
                     @"Test should have waited for the specified timeout.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

#pragma mark -SLIsTrueWithTimeout

- (void)testSLIsTrueWithTimeoutDoesNotThrowAndReturnsYESImmediatelyWhenConditionIsTrueUponWait {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" wait on a condition that evaluates to true, thus immediately return
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        BOOL slIsTrueWithTimeoutReturnValue;
        STAssertNoThrow(slIsTrueWithTimeoutReturnValue = [test SLIsTrue:^BOOL{
            return YES;
        } withTimeout:1.5], @"Assertion should not have failed.");

        STAssertTrue(slIsTrueWithTimeoutReturnValue, @"`SLIsTrueWithTimeout` should have returned YES");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // note that `SLIsTrueWithTimeout` should not wait at all here, thus the variability
        // is not `SLIsTrueRetryDelay` like the cases below
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval < .01, @"Test should not have waited for an appreciable interval.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLIsTrueWithTimeoutDoesNotThrowAndReturnsYESImmediatelyAfterConditionBecomesTrue {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testThree" wait on a condition that evaluates to false initially,
    // then to true partway through the timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval waitTimeout = 1.5;
        NSTimeInterval truthTimeout = 1.0;
        BOOL slIsTrueWithTimeoutReturnValue;
        STAssertNoThrow(slIsTrueWithTimeoutReturnValue = [test SLIsTrue:^BOOL{
            NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval waitInterval = endTimeInterval - startTimeInterval;
            return (waitInterval >= truthTimeout);
        } withTimeout:waitTimeout], @"Assertion should not have failed.");

        STAssertTrue(slIsTrueWithTimeoutReturnValue, @"`SLIsTrueWithTimeout` should have returned YES");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // check that the test waited for about the amount of time for the condition to evaluate to true
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval - truthTimeout < SLIsTrueRetryDelay,
                     @"Test should have only waited for about the amount of time necessary for the condition to become true.");
    }] testThree];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLIsTrueWithTimeoutDoesNotThrowIfConditionIsStillFalseAtEndOfTimeout {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testTwo" wait on a condition that evaluates to false, thus for the full timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval timeout = 1.5;
        BOOL slIsTrueWithTimeoutReturnValue;
        STAssertNoThrow(slIsTrueWithTimeoutReturnValue = [test SLIsTrue:^BOOL{
            return NO;
        } withTimeout:timeout], @"Assertion should have failed.");

        STAssertFalse(slIsTrueWithTimeoutReturnValue, @"`SLIsTrueWithTimeout` should have returned YES");

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval - timeout < SLIsTrueRetryDelay,
                     @"Test should have waited for the specified timeout.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

- (void)testSLWaitUntilTrueIsDeprecated {
    [[_loggerMock expect] logWarning:@"As of v1.2, `SLWaitUntilTrue` is deprecated: use `SLIsTrueWithTimeout` instead. `SLWaitUntilTrue` will be removed for v2.0."];
    
    // To test that `SLWaitUntilTrue` works until it's removed, replicate one of the
    // `SLIsTrueWithTimeout` test cases from above (`testSLIsTrueWithTimeoutDoesNotThrowAndReturnsYESImmediatelyAfterConditionBecomesTrue`).
    // This should be sufficient considering that `SLWaitUntilTrue` is now a wrapper
    // around `SLIsTrueWithTimeout` anyway.
    
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];
    
    // have "testThree" wait on a condition that evaluates to false initially,
    // then to true partway through the timeout
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        
        NSTimeInterval waitTimeout = 1.5;
        NSTimeInterval truthTimeout = 1.0;
        BOOL slWaitUntilTrueReturnValue;
        STAssertNoThrow(slWaitUntilTrueReturnValue = [test SLWaitUntilTrue:^BOOL{
            NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval waitInterval = endTimeInterval - startTimeInterval;
            return (waitInterval >= truthTimeout);
        } withTimeout:waitTimeout], @"Assertion should not have failed.");
        
        STAssertTrue(slWaitUntilTrueReturnValue, @"`SLWaitUntilTrue` should have returned YES");
        
        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        // check that the test waited for about the amount of time for the condition to evaluate to true
        NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(waitTimeInterval - truthTimeout < SLIsTrueRetryDelay,
                     @"Test should have only waited for about the amount of time necessary for the condition to become true.");
    }] testThree];
    
    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
    
    STAssertNoThrow([_loggerMock verify], @"Use of `SLWaitUntilTrue` should have caused a warning to be logged.");
}

- (void)testSLWaitUntilTrueRetryDelayIsDeprecated {
    [[_loggerMock expect] logWarning:@"As of v1.2, `SLWaitUntilTrueRetryDelay` is deprecated: use `SLIsTrueRetryDelay` instead. `SLWaitUntilTrueRetryDelay` will be removed for v2.0."];
    
    NSTimeInterval retryDelay = SLWaitUntilTrueRetryDelay;
    // spin the run loop to allow the warning to be logged asynchronously
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    STAssertNoThrow([_loggerMock verify], @"Use of `SLWaitUntilTrueRetryDelay` should have caused a warning to be logged.");
    STAssertTrue(retryDelay == SLIsTrueRetryDelay, @"`SLWaitUntilTrueRetryDelay` should work until it is removed.");
}

#pragma mark -SLAssertThrows

- (void)testSLAssertThrowsThrowsIffDoesNotThrowException {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" throw and succeed
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertThrows:^{
            [NSException raise:NSInternalInconsistencyException format:nil];
        }], @"Assertion should not have failed.");
    }] testOne];

    // have "testTwo" not throw and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertThrows:^{}], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not execute as expected.");
}

#pragma mark -SLAssertThrowsNamed

// SLAssertThrowsNamed is useful when you want to check
// not just that an expression throws an exception...
- (void)testSLAssertThrowsNamedThrowsIfDoesNotThrowException {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testTwo" not throw and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertThrows:^{} named:@"TestException"], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

// ...but that an expression throws an exception with a specific name.
- (void)testSLAssertThrowsNamedThrowsIfDoesNotThrowNamedException {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" throw named exception and succeed
    NSString *exceptionName = @"TestException";
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertThrows:^{
            [NSException raise:exceptionName format:nil];
        } named:exceptionName], @"Assertion should not have failed.");
    }] testOne];

    // have "testTwo" throw a different exception and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertThrows:^{
            [NSException raise:NSInternalInconsistencyException format:nil];
        } named:exceptionName], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test cases did not execute as expected.");
}

#pragma mark -SLAssertNoThrow

- (void)testSLAssertNoThrowThrowsIffExceptionThrows {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have "testOne" not throw and succeed
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertNoThrow([test slAssertNoThrow:^{}], @"Assertion should not have failed.");
    }] testOne];

    // have "testTwo" not throw and fail
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        STAssertThrows([test slAssertNoThrow:^{
            [NSException raise:NSInternalInconsistencyException format:nil];
        }], @"Assertion should have failed.");
    }] testTwo];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case did not execute as expected.");
}

#pragma mark - Miscellaneous

#pragma mark -UIAElement macro

- (void)runWithTestFailingWithExceptionRecordedByUIAElementMacro:(NSException *)exception
                                         isSLUIAElementException:(BOOL)isSLUIAElementException {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // verify that the test case is executed, then an error is logged
    OCMExpectationSequencer *sequencer = [OCMExpectationSequencer sequencerWithMocks:@[ testMock, _loggerMock ]];

    // when testOne is executed, cause it to fail with an `SLUIAElement` exception
    // and record the filename and line number that the failing assertion should use
    __block NSString *filenameAndLineNumberPrefix = nil;
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSString *__autoreleasing filename = nil; int lineNumber = 0;
        @try {
            [test slFailWithExceptionRecordedByUIAElementMacro:exception
                                          thrownBySLUIAElement:isSLUIAElementException
                                                    atFilename:&filename lineNumber:&lineNumber];
        }
        @catch (NSException *exception) {
            filenameAndLineNumberPrefix = [NSString stringWithFormat:@"%@:%d: ", filename, lineNumber];
            @throw exception;
        }
    }] testOne];

    // if this exception was a `SLUIAElement` exception,
    // check that the error logged includes the filename and line number as recorded above
    // otherwise, check that the error reads "Unknown location: …"
    [[_loggerMock expect] logError:[OCMArg checkWithBlock:^BOOL(id errorMessage) {
        NSString *expectedPrefix = isSLUIAElementException ? filenameAndLineNumberPrefix : SLLoggerUnknownCallSite;
        return [errorMessage hasPrefix:expectedPrefix];
    }]];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([sequencer verify], @"Test did not run/message was not logged in expected sequence.");
}

- (void)testSLUIAElementExceptionsIncludeFilenameAndLineNumberRecordedByUIAElementMacro {
    // that the exception name is made-up shouldn't matter, so long as it has the appropriate prefix
    // we'll have an `SLUIAElement` throw the exception (in `-[TestUtilities slFailWithException:thrownBySLUIAElement:precededByUIAElementUse:atFilename:lineNumber:])
    // but only so that we can use the `UIAElement` macro before throwing the exception
    NSString *exceptionName = [NSString stringWithFormat:@"%@%@", SLUIAElementExceptionNamePrefix, NSStringFromSelector(_cmd)];
    NSException *exception = [NSException exceptionWithName:exceptionName reason:nil userInfo:nil];

    [self runWithTestFailingWithExceptionRecordedByUIAElementMacro:exception isSLUIAElementException:YES];
}

- (void)testOtherExceptionsDoNotIncludeFilenameAndLineNumberRecordedByUIAElementMacro {
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:nil userInfo:nil];

    [self runWithTestFailingWithExceptionRecordedByUIAElementMacro:exception isSLUIAElementException:NO];
}

#pragma mark -Wait

- (void)testWaitDelaysForSpecifiedInterval {
    Class testClass = [TestWithSomeTestCases class];
    id testMock = [OCMockObject partialMockForClass:testClass];

    // have testOne wait
    [[[testMock expect] andDo:^(NSInvocation *invocation) {
        SLTest *test = [invocation target];
        NSTimeInterval startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval expectedWaitTimeInterval = 1.5;

        [test wait:expectedWaitTimeInterval];

        NSTimeInterval endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
        STAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < .01,
                     @"Test did not delay for expected interval.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:testClass], nil);
    STAssertNoThrow([testMock verify], @"Test case was not executed as expected.");
}

#pragma mark - Internal

- (void)testTestCasesAreDiscoveredAsExpected {
    NSSet *testCases = [NSSet setWithObjects:@"testOne", @"testTwo", @"testThree", nil];
    STAssertEqualObjects(testCases, [TestWithSomeTestCases testCases],
                         @"Test cases were not discovered as expected.");
}

@end
