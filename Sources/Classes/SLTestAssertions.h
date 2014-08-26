//
//  SLTestAssertions.h
//  Subliminal
//
//  Created by Justin Martin on 7/8/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTest.h"

#pragma mark - Constants

/// Thrown if a test assertion fails.
extern NSString *const SLTestAssertionFailedException;

/// The interval for which `SLAssertTrueWithTimeout` and `SLIsTrueWithTimeout`
/// wait before re-evaluating their conditions.
extern const NSTimeInterval SLIsTrueRetryDelay;

// Log the deprecation warning asynchronously in case the constant was referenced
// from the main thread (possible).
#define SLWaitUntilTrueRetryDelay ({\
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{\
        [[SLLogger sharedLogger] logWarning:@"As of v1.2, `SLWaitUntilTrueRetryDelay` is deprecated: use `SLIsTrueRetryDelay` instead. `SLWaitUntilTrueRetryDelay` will be removed for v2.0."];\
    });\
    SLIsTrueRetryDelay;\
})

#pragma mark - Test Assertions

/**
 Records the current filename and line number and returns its argument.
 
 Wrap a `SLUIAElement` in the `UIAElement` macro whenever sending it a message
 that might throw an exception. If the call throws, and the test case fails, the
 logs will report where the failure occurred.
 
 Use the macro like:
 
 SLButton *fooButton = ...
 [UIAElement(fooButton) tap];
 
 It may help to think that "you're preparing to send a message to the
 UIAutomation element corresponding to the wrapped `SLUIAElement`."
 */
#define UIAElement(slElement) ({ \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
slElement; \
})

/**
 The SLAssert* class of methods should only be used from test setup, teardown,
 or execution methods as well as those methods called from within.
 
 @warning If you use an assertion inside a dispatch block--if your test case
 dispatches to the main queue, for instance--you must wrap the assertion in a
 try-catch block and re-throw the exception it generates (if any) outside the
 dispatch block. Otherwise, the tests will abort with an unhandled exception.
 */

/**
 Fails the test case if the specified expression is false.
 
 @param expression The expression to test.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into
 `failureDescription`.
 */
#define SLAssertTrue(expression, failureDescription, ...) do { \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
BOOL __result = !!(expression); \
if (!__result) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" should be true.%@", \
@(#expression), SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
} while (0)

/**
 Fails the test case if the specified expression does not become true
 within a specified timeout.
 
 The macro re-evaluates the condition at small intervals.
 
 There are two great advantages to using `SLAssertTrueWithTimeout` instead of `-wait:`:
 
 *  `SLAssertTrueWithTimeout` need not wait for the entirety of the specified timeout
 if the condition becomes true before the timeout elapses. This can lead
 to faster tests, and makes it feasible to allow even longer timeouts
 when using `SLAssertTrueWithTimeout` than when using `-wait:`.
 *  `SLAssertTrueWithTimeout` encourages test writers to describe specifically
 why they are waiting, not only by specifying an expression on which to wait
 but by specifying an error message. If waiting is not successful, this information
 will be used to produce a rich error message at the site of the failure. By
 contrast, if `-wait:` is "unsuccessful" (in the sense that the app does not
 change as expected while waiting), that failure will manifest later in ways
 that may be difficult to debug.
 
 `SLAssertTrueWithTimeout` may be used to wait for the UI to change as well as
 for the application to complete some lengthy operation. Some examples follow:
 
 // wait for a confirmation message to appear, e.g. after logging in
 SLAssertTrueWithTimeout([UIAElement(confirmationLabel) isValidAndVisible], 10.0,
 @"User did not successfully log in.");
 
 // wait for a progress indicator to disappear, e.g. after search results have loaded
 SLAssertTrueWithTimeout([UIAElement(progressIndicator) isInvalidOrInvisible], 10.0,
 @"Search results did not load.");
 
 // log in programmatically, then wait until the log-in operation succeeds
 // using app hooks (see SLTestController+AppHooks.h
 SLAskApp(logInWithInfo:, (@{ @"username": @"john@foo.com", @"password": @"Hello1234" }));
 SLAssertTrueWithTimeout(SLAskAppYesNo(isLoggedIn), 5.0, @"Log-in did not succeed.");
 
 @param expression A boolean expression on whose truth the test should wait.
 @param timeout The interval for which to wait.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 */
#define SLAssertTrueWithTimeout(expression, timeout, failureDescription, ...) do {\
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
\
if (!SLIsTrueWithTimeout(expression, timeout)) { \
NSString *reason = [NSString stringWithFormat:@"\"%@\" did not become true within %g seconds.%@", \
@(#expression), (NSTimeInterval)timeout, SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:reason userInfo:nil]; \
} \
} while (0)

/**
 Suspends test execution until the specified expression becomes true or the
 specified timeout is reached, and then returns the value of the specified
 expression at the moment of returning.
 
 The macro re-evaluates the condition at small intervals.
 
 The great advantage to using `SLIsTrueWithTimeout` instead of `-wait:` is that `SLIsTrueWithTimeout`
 need not wait for the entirety of the specified timeout if the condition becomes true
 before the timeout elapses. This can lead to faster tests, and makes it feasible
 to allow even longer timeouts when using `SLIsTrueWithTimeout` than when using
 `-wait:`.
 
 The difference between `SLIsTrueWithTimeout` and `SLAssertTrueWithTimeout` is that `SLIsTrueWithTimeout`
 may be used to wait upon a condition which might, with equal validity, evaluate to true _or_ false.
 For example:
 
 // wait for a confirmation message that may or may not appear, and dismiss it
 BOOL messageDisplayed = SLIsTrueWithTimeout([UIAElement(messageDismissButton) isValidAndVisible], 10.0);
 if (messageDisplayed) {
 [UIAElement(messageDismissButton) tap];
 }
 
 @param expression A boolean expression on whose truth the test should wait.
 @param timeout The interval for which to wait.
 @return Whether or not the expression evaluated to true before the timeout was reached.
 */
#define SLIsTrueWithTimeout(expression, timeout) ({\
NSDate *_startDate = [NSDate date];\
BOOL _expressionTrue = NO;\
while (!(_expressionTrue = (expression)) && ([[NSDate date] timeIntervalSinceDate:_startDate] < timeout)) {\
[NSThread sleepForTimeInterval:SLIsTrueRetryDelay];\
}\
_expressionTrue;\
})

/**
 Suspends test execution until the specified expression becomes true or the
 specified timeout is reached, and then returns the value of the specified
 expression at the moment of returning.
 
 @warning As of v1.2, `SLWaitUntilTrue` is deprecated: use `SLIsTrueWithTimeout`
 instead. `SLWaitUntilTrue` will be removed for v2.0.
 
 @param expression A boolean expression on whose truth the test should wait.
 @param timeout The interval for which to wait.
 @return Whether or not the expression evaluated to true before the timeout was reached.
 */
#define SLWaitUntilTrue(expression, timeout) ({\
    [[SLLogger sharedLogger] logWarning:@"As of v1.2, `SLWaitUntilTrue` is deprecated: use `SLIsTrueWithTimeout` instead. `SLWaitUntilTrue` will be removed for v2.0."];\
    SLIsTrueWithTimeout(expression, timeout);\
})

/**
 Fails the test case if the specified expression is true.
 
 @param expression The expression to test.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into
 `failureDescription`.
 */
#define SLAssertFalse(expression, failureDescription, ...) do { \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
BOOL __result = !!(expression); \
if (__result) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" should be false.%@", \
@(#expression), SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
} while (0)

/**
 Fails the test case if the specified expression doesn't raise an exception.
 
 @param expression The expression to test.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into
 `failureDescription`.
 */
#define SLAssertThrows(expression, failureDescription, ...) do { \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
BOOL __caughtException = NO; \
@try { \
(expression); \
} \
@catch (id __anException) { \
__caughtException = YES; \
} \
if (!__caughtException) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" should have thrown an exception.%@", \
@(#expression), SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
} while (0)

/**
 Fails the test case if the specified expression doesn't raise an exception
 with a particular name.
 
 @param expression The expression to test.
 @param exceptionName The name of the exception that should be thrown by `expression`.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into
 `failureDescription`.
 */
#define SLAssertThrowsNamed(expression, exceptionName, failureDescription, ...) do { \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
BOOL __caughtException = NO; \
@try { \
(expression); \
} \
@catch (NSException *__anException) { \
if (![[__anException name] isEqualToString:exceptionName]) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" threw an exception named \"%@\" (\"%@\"), but not an exception named \"%@\". %@", \
@(#expression), [__anException name], [__anException reason], exceptionName, SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} else {\
__caughtException = YES; \
}\
} \
@catch (id __anException) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" threw an exception, but not an exception named \"%@\". %@", \
@(#expression), exceptionName, SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
if (!__caughtException) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" should have thrown an exception named \"%@\".%@", \
@(#expression), exceptionName, SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
} while (0)

/**
 Fails the test case if the specified expression raises an exception.
 
 @param expression The expression to test.
 @param failureDescription A format string specifying the error message
 to be logged if the test fails. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into
 `failureDescription`.
 */
#define SLAssertNoThrow(expression, failureDescription, ...) do { \
[SLTest recordLastKnownFile:__FILE__ line:__LINE__]; \
@try { \
(expression); \
} \
@catch (id __anException) { \
NSString *__reason = [NSString stringWithFormat:@"\"%@\" should not have thrown an exception: \"%@\" (\"%@\").%@", \
@(#expression), [__anException name], [__anException reason], SLComposeString(@" ", failureDescription, ##__VA_ARGS__)]; \
@throw [NSException exceptionWithName:SLTestAssertionFailedException reason:__reason userInfo:nil]; \
} \
} while (0)
