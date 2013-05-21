//
//  SLTest.h
//  Subliminal
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLTestController+AppContext.h"
#import "SLStringUtilities.h"


// all exceptions thrown by SLTest will have names beginning with this prefix
extern NSString *const SLTestExceptionNamePrefix;

extern NSString *const SLTestAssertionFailedException;

extern NSString *const SLTestExceptionFilenameKey;
extern NSString *const SLTestExceptionLineNumberKey;


@interface SLTest : NSObject

@property (nonatomic, weak, readonly) SLTestController *testController;

+ (NSSet *)allTests;
+ (Class)testNamed:(NSString *)test;

/**
 Returns YES if this class does not define test cases.
 
 An abstract test will not itself be run. Subclasses which do define test cases
 will be run, however, allowing a single base class to define set-up and tear-down 
 work shared among related subclasses.

 @return YES if the class is without test cases, otherwise NO.
 */
+ (BOOL)isAbstract;

/**
 Returns YES if this test has at least one test case which can be run
 given the current device, screen, etc.
 
 Subclasses of SLTest should override this method if some run-time condition 
 should determine whether or not all test cases should run. 
 Typical checks might include checking the user interface idiom (phone or pad) 
 of the current device, or checking the scale of the main screen.

 As a convenience, test writers may specify the device type(s) on which a
 test can run by suffixing tests' names in the following fashion:

     * A test whose name has the suffix "_iPhone," like "TestFoo_iPhone",
     will be executed only when [[UIDevice currentDevice] userInterfaceIdiom] ==
     UIUserInterfaceIdiomPhone.
     * A test whose name has the suffix "_iPad" will be executed only
     when the current device user interface idiom is UIUserInterfaceIdiomPad.
     * A test whose name has neither the "_iPhone" nor the "_iPad"
     suffix will be executed on all devices regardless of the user interface idiom.

 The default implementation of this method checks that the class is suffixed 
 appropriately and that there is at least one test case for which
 testCaseWithSelectorSupportsCurrentPlatform: returns YES.

 If this method returns NO, none of this test's cases will run.

 @return YES if this class has test cases that can currently run, NO otherwise.
 
 @see -testCaseWithSelectorSupportsCurrentPlatform:
 */
+ (BOOL)supportsCurrentPlatform;

- (id)initWithTestController:(SLTestController *)testController;

/**
 Runs all test cases defined on the receiver's class, 
 and reports statistics about their execution.
 
 See SLTest (SLTestCase) for a discussion of test case execution.
 
 @param numCasesExecuted If this is non-null, on return, this will be set to 
 the number of test cases that were executed--which will be the number of test
 cases defined by this SLTest.
 @param numCasesFailed If this is non-null, on return, this will be set to the 
 number of test cases that failed (the number of test cases that threw exceptions).
 @param numCasesFailedUnexpectedly If this is non-null, on return, this will 
 be set to the number of test cases that failed unexpectedly (those test cases 
 that threw non-assertion exceptions).
 */
- (void)runAndReportNumExecuted:(NSUInteger *)numCasesExecuted
                         failed:(NSUInteger *)numCasesFailed
             failedUnexpectedly:(NSUInteger *)numCasesFailedUnexpectedly;

@end


/**
 The following methods are used to set up before and clean up after individual 
 test case methods. Test case methods are methods, defined on a subclass of SLTest:
 
    * whose names have the prefix "test",
    * with void return types, and
    * which take no arguments.
 
 When a test is [run](-runAndReportNumExecuted:failed:failedUnexpectedly:),
 it discovers, sets up, executes, and tears down all its test cases.
 The method descriptions below specify when each method will be called,
 and -[SLTestTests testCompleteTestExecutionSequence] gives an example.

 A test case "passes" if it throws no exceptions in its set-up, tear-down, or 
 the body of the test case itself; otherwise, it "fails". That failure is 
 "expected" if it was caused by a test assertion failing. Any other exception
 causes an "unexpected" failure.
 */
@interface SLTest (SLTestCase)

/**
 Returns YES if this test case can be run given the current device, screen, etc.

 Subclasses of SLTest should override if they need to do any run time checks
 to determine whether or not specific test cases can run.  Typical checks might include
 checking the user interface idiom (phone or pad) of the current device, or
 checking the scale of the main screen.

 As a convenience, test writers may specify the device type(s) on which a 
 test case can run by suffixing test cases' names in the following fashion:

     * A test case whose name has the suffix "_iPhone," like "testFoo_iPhone",
     will be executed only when [[UIDevice currentDevice] userInterfaceIdiom] ==
     UIUserInterfaceIdiomPhone.
     * A test case whose name has the suffix "_iPad" will be executed only
     when the current device user interface idiom is UIUserInterfaceIdiomPad.
     * A test case whose name has neither the "_iPhone" nor the "_iPad"
     suffix will be executed on all devices regardless of the user interface idiom.

 The default implementation of this method checks that the selector is suffixed 
 appropriately.
 
 @warning If the test does not support the current platform, test cases
 will not be run regardless of what this method returns.

 @param testCaseSelector A selector identifying a test case.
 @return YES if the test case can be run.
 
 @see -supportsCurrentPlatform
 */
+ (BOOL)testCaseWithSelectorSupportsCurrentPlatform:(SEL)testCaseSelector;

/**
 Called before any test cases are run.
 
 In this method, tests should establish any state shared by all test cases, 
 including navigating to the part of the app being exercised by the test cases.
 
 In this method, tests can (and should) use test assertions to ensure
 that set-up was successful.
 
 @warning If set-up fails, this test will be aborted and its cases skipped. 
 However, -tearDownTest will still be executed.

 Users of OCUnit (or other JUnit-inspired frameworks) may wonder why there's no -setUp.
 The reason is that Subliminal distinguishes between setting up the whole test and
 setting up individual test cases (OCUnit's -setUp is called for every test case).
 The same consideration holds for the tear-down methods.

 @sa -tearDownTest
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

 @sa setUpTest
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

 @sa -tearDownTestCaseWithSelector:
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

 @sa -setUpTestCaseWithSelector:
 */
- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector;

/**
 Returns YES if the test has at least one test case which is focused
 and which can run on the current platform.

 When a test is run, if any of its test cases are focused, only those test cases will run.
 This may be useful when writing or debugging tests.

 A test case is focused by prefixing its name with "focus_", like so:

     - (void)focus_testFoo;

 It is also possible to implicitly focus all test cases by prefixing
 their test's name with "Focus_". But if some test cases are explicitly focused 
 (as above), only those test cases will run--the narrowest focus applies.
 
 If a test is focused, that focus will apply to any tests which descend from it.

 @warning Methods that take test case selectors as arguments (like 
 -setUpTestCaseWithSelector:) are invoked with the unfocused form of the selectors
 --they need not (and should not) be modified when a test case is focused.

 @warning Focused test cases will not be run if their test is not run (e.g. if
 it is not included in the set of tests to be run, or if it does not support 
 the current platform).

 @return YES if any test cases are focused and can be run on the current platform.

 @see -[SLTestController runTests:withCompletionBlock:]
 */
+ (BOOL)isFocused;


#pragma mark - Utilities

/**
 Delays test execution for the specified time interval.
 
 You can use this method to provide enough time for lengthy operations to complete.
 
 If you have a specific condition on which you're waiting, it is more appropriate 
 to use the SLAssertTrueWithTimeout macro.
 
 @param interval The time interval for which to wait.
 */
- (void)wait:(NSTimeInterval)interval;


#pragma mark - SLElement Use

- (void)recordLastKnownFile:(char *)filename line:(int)lineNumber;

/**
 Wrap an SLElement in the UIAElement macro whenever calling an SLElement method 
 that might throw an exception.

 The macro records the filename and line number, so that if the call throws, 
 and the test fails, the test logs will report where the failure occurred.
 
 Use the macro like:
    
    SLButton *fooButton = ...
    [UIAElement(fooButton) tap];
 
 It may help to think that you're preparing to send a message to the 
 UIAutomation element corresponding to the wrapped SLElement.
 */
#define UIAElement(slElement) ({ \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    slElement; \
})

#pragma mark - Test Assertions

#define SLAssertTrue(expr, description, ...) do { \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    BOOL __result = (expr); \
    if (!__result) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" should be true.%@", \
                                @(#expr), SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
} while (0)

/**
 The SLAssertTrueWithTimeout macro allows an SLTest to wait for an arbitrary
 condition to become true within a specified timeout.

 The macro polls the condition at small intervals.
 If the condition is not true when the timeout elapses, the macro
 will throw an exception.

 @param expr A boolean expression on whose truth the test should wait.
 @param timeout The interval for which to wait.
 @param description A description of the wait's failure should that occur.
 This may be a format string taking variable arguments.
 @exception SLTestAssertionFailedException if expr does not evaluate to true
 within the specified timeout.
 */
#define SLAssertTrueWithTimeout(expr, timeout, description, ...) do {\
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    NSTimeInterval _retryDelay = 0.25; \
    \
    NSDate *_startDate = [NSDate date]; \
    BOOL _exprTrue = NO; \
    while (!(_exprTrue = (expr)) && \
        ([[NSDate date] timeIntervalSinceDate:_startDate] < timeout)) { \
        [NSThread sleepForTimeInterval:_retryDelay]; \
    } \
    if (!_exprTrue) { \
        NSString *reason = [NSString stringWithFormat:@"\"%@\" did not become true within %g seconds.%@", \
        @(#expr), timeout, SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:reason userInfo:nil]; \
    } \
} while (0)

#define SLAssertFalse(expr, description, ...) do { \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    BOOL __result = (expr); \
    if (__result) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" should be false.%@", \
                                @(#expr), SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
} while (0)

#define SLAssertThrows(expr, description, ...) do { \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    BOOL __caughtException = NO; \
    @try { \
        (expr); \
    } \
    @catch (id __anException) { \
        __caughtException = YES; \
    } \
    if (!__caughtException) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" should have thrown an exception.%@", \
                                @(#expr), SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
} while (0)

#define SLAssertThrowsNamed(expr, exceptionName, description, ...) do { \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    BOOL __caughtException = NO; \
    @try { \
        (expr); \
    } \
    @catch (NSException *__anException) { \
        if (![[__anException name] isEqualToString:exceptionName]) { \
            NSString *__reason = [NSString stringWithFormat:@"\"%@\" threw an exception named \"%@\" (\"%@\"), but not an exception named \"%@\". %@", \
                                    @(#expr), [__anException name], [__anException reason], exceptionName, SLComposeString(@" ", description, ##__VA_ARGS__)]; \
            @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
        } else {\
            __caughtException = YES; \
        }\
    } \
    @catch (id __anException) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" threw an exception, but not an exception named \"%@\". %@", \
                                @(#expr), exceptionName, SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
    if (!__caughtException) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" should have thrown an exception named \"%@\".%@", \
                                @(#expr), exceptionName, SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
} while (0)

#define SLAssertNoThrow(expr, description, ...) do { \
    [self recordLastKnownFile:__FILE__ line:__LINE__]; \
    @try { \
        (expr); \
    } \
    @catch (id __anException) { \
        NSString *__reason = [NSString stringWithFormat:@"\"%@\" should not have thrown an exception: \"%@\" (\"%@\").%@", \
                                @(#expr), [__anException name], [__anException reason], SLComposeString(@" ", description, ##__VA_ARGS__)]; \
        @throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
    } \
} while (0)

@end

