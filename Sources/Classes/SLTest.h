//
//  SLTest.h
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

#import <Foundation/Foundation.h>

#import "SLTestController+AppHooks.h"
#import "SLStringUtilities.h"

/**
 `SLTest` is the abstract superclass of Subliminal integration tests.
 
 To write a test, developers create a new subclass of `SLTest`. They then add 
 test case methods and implement set-up and tear-down methods as necessary.
 */
@interface SLTest : NSObject

#pragma mark - Retrieving Tests to Run
/// ----------------------------------------
/// @name Retrieving Tests to Run
/// ----------------------------------------

/**
 Returns all tests linked against the current target.
 
 The recommended way to run Subliminal tests is to invoke `-[SLTestController runTests:withCompletionBlock:]`
 with the set returned by this method. That way, new tests will automatically 
 be discovered and run. 
 
 Without modifying the argument to `-[SLTestController runTests:withCompletionBlock:]`, 
 tests may be conditionalized to run only in certain circumstances using APIs
 like `+isAbstract`, `+supportsCurrentPlatform`, and `+isFocused`.

 @return All tests (`SLTest` subclasses) linked against the current target.
 */
+ (NSSet *)allTests;

/**
 Returns the `SLTest` subclass with the specified name.
 
 This method may be used to retrieve a single `SLTest`, e.g. to pass to 
 `-[SLTestController runTests:withCompletionBlock:]`, without having to import
 that test's interface.
 
 Note that it may be easier to run a single test by [focusing](+isFocused) that test
 than by modifying the arguments to `-[SLTestController runTests:withCompletionBlock:]`.

 @param name The name of the test (`SLTest` subclass) to return.

 @return The `SLTest` subclass with the specified name, or `nil` if no `SLTest`
 subclass with that name is linked against the current target.
 */
+ (Class)testNamed:(NSString *)name;

#pragma mark - Conditionalizing Test Runs
/// ----------------------------------------
/// @name Conditionalizing Test Runs
/// ----------------------------------------

/**
 Returns `YES` if this class does not define test cases.
 
 An abstract test will not itself be run. Subclasses which do define test cases
 will be run, however, allowing a single base class to define set-up and tear-down 
 work shared among related subclasses. Abstract classes can also be used to
 define the [run group](+runGroup) shared by subclasses.

 @return `YES` if the class is without test cases, otherwise `NO`.
 */
+ (BOOL)isAbstract;

/**
 Returns YES if this test has at least one test case which can be run
 given the current device, screen, etc.
 
 Subclasses of `SLTest` should override this method if some run-time condition
 should determine whether or not all test cases should run. 
 Typical checks might include checking the user interface idiom (phone or pad) 
 of the current device, or checking the scale of the main screen.

 As a convenience, test writers may specify the device type(s) on which a
 test can run by suffixing tests' names in the following fashion:

 *  A test whose name has the suffix "`_iPhone`," like "`TestFoo_iPhone`",
    will be executed only when `([[UIDevice currentDevice] userInterfaceIdiom] ==
    UIUserInterfaceIdiomPhone)` is true.
 *  A test whose name has the suffix "`_iPad`" will be executed only
    when the current device user interface idiom is `UIUserInterfaceIdiomPad`.
 *  A test whose name has neither the "`_iPhone`" nor the "`_iPad`"
    suffix will be executed on all devices regardless of the user interface idiom.

 The default implementation of this method checks that the class is suffixed 
 appropriately and that there is at least one test case for which
 `+testCaseWithSelectorSupportsCurrentPlatform:` returns `YES`.

 If this method returns `NO`, none of this test's cases will run.

 @return `YES` if this class has test cases that can currently run, `NO` otherwise.
 
 @see +testCaseWithSelectorSupportsCurrentPlatform:
 */
+ (BOOL)supportsCurrentPlatform;

/**
 Returns YES if the test has at least one test case which is focused
 and which can run on the current platform.

 When a test is run, if any of its test cases are focused, only those test cases will run.
 This may be useful when writing or debugging tests.

 A test case is focused by prefixing its name with "`focus_`", like so:

    - (void)focus_testFoo;

 It is also possible to implicitly focus all test cases by prefixing
 their test's name with "`Focus_`". But if some test cases are explicitly focused
 (as above), only those test cases will run--the narrowest focus applies.

 If a test is focused, that focus will apply to any tests which descend from it.

 @warning Methods that take test case selectors as arguments (like
 `-setUpTestCaseWithSelector:`) are invoked with the unfocused form of the selectors
 --they need not (and should not) be modified when a test case is focused.

 @warning Focused test cases will not be run if their test is not run (e.g. if
 it is not included in the set of tests to be run, or if it does not support
 the current platform).

 @return `YES` if any test cases are focused and can be run on the current platform, 
 `NO` otherwise.

 @see -[SLTestController runTests:usingSeed:withCompletionBlock:]
 */
+ (BOOL)isFocused;

/**
 Returns YES if the test has at least one test case which is focused
 using an environment variable named `FOCUS` on the tested application's Integration
 Tests scheme and which can run on the current platform.

 When a test is run, if any of its test cases are focused, only those test cases will run.
 This may be useful when writing or debugging tests.

 In Xcode, test cases are focused by listing the desired tests, separated
 by commas, as the Integration Tests scheme's `FOCUS` environment variable's value.

 Using the subliminal-test script to run Subliminal from the command line for continuous
 integration, test cases are focused like so:

 subliminal-test [...] -e FOCUS testFoo,testBar

 It is also possible to implicitly focus all test cases by listing their test's name
 in the `FOCUS` environment variable. But if some test cases are explicitly focused
 (as above), only those test cases will run--the narrowest focus applies.

 If a test is focused, that focus will apply to any tests which descend from it.

 @warning Methods that take test case selectors as arguments (like
 `-setUpTestCaseWithSelector:`) are invoked with the unfocused form of the selectors
 --they need not (and should not) be modified when a test case is focused.

 @warning Focused test cases will not be run if their test is not run (e.g. if
 it is not included in the set of tests to be run, or if it does not support
 the current platform).

 @return `YES` if any test cases are focused and can be run on the current platform,
 `NO` otherwise.

 @see -[SLTestController runTests:usingSeed:withCompletionBlock:]
 */
+ (BOOL)isFocusedWithEnvVar;

#pragma mark - Ordering Test Runs
/// ------------------------------------------
/// @name Ordering Test Runs
/// ------------------------------------------

/**
 Returns a value identifying the group of tests to which the receiver belongs.
 
 `SLTestController` will run tests in ascending order of group, and then within
 each group, in a randomized order. This allows test writers to provide a rough
 order to tests, where necessary, while minimizing the test pollution that can
 result from an absolute ordering.
 
 A common use for run groups is to divide tests into two groups, those that
 need to occur before some "startup" event (an onboarding flow, an import process, etc.)
 (of run group `1`) and those that need to occur afterward (of run group `2`).
 In this scenario, the "post-startup" tests subclass an [abstract test](+isAbstract)
 that, in its implementation of `+setUpTest`, causes the startup event to happen.
 Altogether, this ensures that _all_ of the "pre-startup" tests run before
 _any_ of the "post-startup" tests run--and that startup happens before any of the
 "post-startup" tests happen--while allowing the tests within each group to run
 in any order.

 @return A value identifying the group of tests to which the receiver belongs.
 The default implementation returns `1`: all tests will be part of a single run group.
 
 @see -[SLTestController runTests:usingSeed:withCompletionBlock:]
 */
+ (NSUInteger)runGroup;

#pragma mark - Running a Test
/// ----------------------------------------
/// @name Running a Test
/// ----------------------------------------

/**
 Runs all test cases defined on the receiver's class, 
 and reports statistics about their execution.
 
 See `SLTest (SLTestCase)` for a discussion of test case execution.
 
 @param numCasesExecuted If this is non-`NULL`, on return, this will be set to
 the number of test cases that were executed--which will be the number of test
 cases defined by the receiver's class.
 @param numCasesFailed If this is non-`NULL`, on return, this will be set to the
 number of test cases that failed (the number of test cases that threw exceptions).
 @param numCasesFailedUnexpectedly If this is non-`NULL`, on return, this will
 be set to the number of test cases that failed unexpectedly (those test cases
 that threw exceptions for other reasons than test assertion failures).
 
 @return `YES` if the test successfully finished (all test cases were executed, regardless of their individual 
 success or failure), `NO` otherwise (an exception occurred in test case [set-up](-setUpTest) or [tear-down](-tearDownTest) ).
 
 @warning If an exception occurs in test case set-up, the test's cases will be skipped.
 Thus, the caller should use the values returned in `numCasesExecuted`, `numCasesFailed`, 
 and `numCasesFailedUnexpectedly` if and only if this method returns `YES`.
 */
- (BOOL)runAndReportNumExecuted:(NSUInteger *)numCasesExecuted
                         failed:(NSUInteger *)numCasesFailed
             failedUnexpectedly:(NSUInteger *)numCasesFailedUnexpectedly;

@end


/**
 The methods in the `SLTest (SLTestCase)` category are used to set up before 
 and clean up after individual test case methods. Test case methods are methods, 
 defined on a subclass of SLTest:
 
 * whose names have the prefix "test",
 * with `void` return types, and
 * which take no arguments.

 When a test is [run](-runAndReportNumExecuted:failed:failedUnexpectedly:),
 it discovers, sets up, runs, and tears down all its test cases.
 The method descriptions below specify when each method will be called,
 and `-[SLTestTests testCompleteTestRunSequence]` gives an example.

 A test case "passes" if it throws no exceptions in its set-up, tear-down, or 
 the body of the test case itself; otherwise, it "fails". That failure is 
 "expected" if it was caused by a test assertion failing. Any other exception
 causes an "unexpected" failure.
 */
@interface SLTest (SLTestCase)

#pragma mark - Running Test Cases
/// ----------------------------------------
/// @name Running Test Cases
/// ----------------------------------------

/**
 Returns YES if this test case can be run given the current device, screen, etc.

 Subclasses of SLTest should override this method if they need to do any run-time 
 checks to determine whether or not specific test cases can run. Typical checks 
 might include checking the user interface idiom (phone or pad) of the current 
 device, or checking the scale of the main screen.

 As a convenience, test writers may specify the device type(s) on which a 
 test case can run by suffixing test cases' names in the following fashion:

 *  A test case whose name has the suffix "`_iPhone`," like "`testFoo_iPhone`",
    will be executed only when `([[UIDevice currentDevice] userInterfaceIdiom] ==
    UIUserInterfaceIdiomPhone)` is true.
 *  A test case whose name has the suffix "`_iPad`" will be executed only
    when the current device user interface idiom is `UIUserInterfaceIdiomPad`.
 *  A test case whose name has neither the "`_iPhone`" nor the "`_iPad`"
    suffix will be executed on all devices regardless of the user interface idiom.

 The default implementation of this method checks that the selector is suffixed 
 appropriately.
 
 @warning If the test does not support the current platform, that test's cases
 will not be run regardless of this method's return value.

 @param testCaseSelector A selector identifying a test case.
 @return `YES` if the test case can be run, `NO` otherwise.
 
 @see +supportsCurrentPlatform
 */
+ (BOOL)testCaseWithSelectorSupportsCurrentPlatform:(SEL)testCaseSelector;

/**
 Called before any test cases are run.
 
 In this method, tests should establish any state shared by all test cases, 
 including navigating to the part of the app being exercised by the test cases.
 
 In this method, tests can (and should) use test assertions to ensure
 that set-up was successful.
 
 @warning If set-up fails, this test will be aborted and its cases skipped. 
 However, `-tearDownTest` will still be executed.

 @warning Unlike the `-setUp` method found in OCUnit and other JUnit-inspired 
 frameworks, `-setUpTest` is called only once per test.

 @see -tearDownTest
 */
- (void)setUpTest;

/**
 Called after all test cases are run.

 In this method, tests should clean up any state shared by all test cases, 
 such as that which was established in setUpTest.

 In this method, tests can (and should) use test assertions to ensure that
 tear-down was successful.
 
 @warning If tear-down fails, the test will be logged as having terminated 
 abnormally rather than finished, but its test cases' logs will be preserved.

 @warning Unlike the `-setUp` method found in OCUnit and other JUnit-inspired 
 frameworks, `-setUpTest` is called only once per test.

 @see setUpTest
 */
- (void)tearDownTest;

/**
 Called before each test case is run.
 
 In this method, tests should establish any state particular to the specified test case.
 
 In this method, tests can (and should) use test assertions to ensure that
 set-up was successful.
 
 @warning If set-up fails, the test case will be logged as having failed, 
 and the test case itself will be skipped. However, -tearDownTestCaseWithSelector: 
 will still be executed.

 @param testCaseSelector The selector identifying the test case about to be run.

 @see -tearDownTestCaseWithSelector:
 */
- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector;

/**
 Called after each test case is run.
 
 In this method, tests should clean up state particular to the specified test case,
 such as that which was established in setUpTestCaseWithSelector:.

 In this method, tests can (and should) use test assertions to ensure that 
 tear-down was successful.

 @warning If tear-down fails, this test case will be logged as having failed 
 even if the test case itself succeeded. However, the test case's logs 
 will be preserved.
 
 @param testCaseSelector The selector identifying the test case that was run.

 @see -setUpTestCaseWithSelector:
 */
- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector;


#pragma mark - Utilities

/**
 Suspends test execution for the specified time interval.
 
 Only use this method to wait (for the UI to update, or for the application
 to complete some operation) if a delay is found to be necessary, and
 it is not possible to describe a specific condition on which to wait.
 
 It should not be necessary to wait before attempting to access interface elements 
 when the delay would be less than the [default timeout](-[SLTestController defaultTimeout]): 
 elements automatically [wait to become valid and/or tappable](-[SLUIAElement defaultTimeout])
 if access requires waiting.

 Where the delay would be more than the default timeout, or where the condition 
 on which to wait involves application state not made apparent by the UI,
 using the `SLAssertTrueWithTimeout` macro will result in a clearer, more
 efficient test than using `-wait:`. See the definition of `SLAssertTrueWithTimeout` 
 for examples.
 
 @param interval The time interval for which to wait.
 */
- (void)wait:(NSTimeInterval)interval;


#pragma mark - SLElement Use

/**
 Records a filename and line number to attach to an exception thrown at that 
 source line.
 
 Used by the `UIAElement` and test assertion macros so that exceptions thrown 
 by `SLUIAElement` methods and/or test assertions may be traced to their origins.
 
 @param filename A filename, i.e. the last component of the `__FILE__` macro's expansion.
 @param lineNumber A line number, i.e. the `__LINE__` macro's expansion.
 */
+ (void)recordLastKnownFile:(const char *)filename line:(int)lineNumber;

@end
