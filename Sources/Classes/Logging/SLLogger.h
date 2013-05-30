//
//  SLLogger.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Logs a message to the testing environment.
 
 Functionally equivalent to `NSLog`, except for the output medium.
 The message is output using `[[SLLogger sharedLogger] logMessage:]`.
 
 @param format A format string (in the manner of `-[NSString stringWithFormat:]`).
 @param ... (Optional) A comma-separated list of arguments to substitute into `format`.
 */
void SLLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

/**
 Asynchronously logs a message to the testing environment.
 
 This variant of `SLLog` is for use by the application
 and other main thread contexts.
 
 @param format A format string (in the manner of `-[NSString stringWithFormat:]`).
 @param ... (Optional) A comma-separated list of arguments to substitute into `format`.
 */
void SLLogAsync(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);


/**
 `SLLogger` is the abstract superclass of loggers used by the Subliminal framework
 and user-defined tests.
 
 A project that uses Subliminal must [set the shared logger](+setSharedLogger:) 
 before testing begins. The shared logger will then be used by Subliminal to log 
 test progress. It may be used by tests, and by the application itself, to log 
 custom messages to the test output.
 
 Concrete subclasses of `SLLogger` provide a mechanism and a destination for log
 output. Subliminal provides several concrete subclasses:
 
 * SLUIALogger, to log to the Automation instrument
 * SLMultiLogger, to log to multiple sources
 
 It is also possible for clients to subclass `SLLogger` to log to other destinations.
 
 ### Subclassing SLLogger

 Concrete subclasses must override two methods: `-logMessage`, and `-loggingQueue`.
 
 Subclasses override `-logMessage` to provide a mechanism and a destination for
 log output. All other log methods simply format their arguments and call
 `-logMessage`, so subclasses need override those methods only if they wish to
 define different formatting than the base class, or if they wish to use 
 distinct logging mechanisms for different types of messages.
 
 Subclasses override `-loggingQueue` to provide a dispatch queue on which to
 serialize log messages. This allows the shared logger to be used
 both from Subliminal's testing thread and the main thread. 
 
 See `SLUIALogger` for a reference implementation. Note that `SLUIALogger`
 overrides log methods other than `-logMessage` only because it uses distinct 
 logging mechanisms for different types of messages.
 */
@interface SLLogger : NSObject

/**
 The shared logger used by the Subliminal framework and by user-defined tests.
 
 This must be set before testing begins.

 @return The shared logger.
 
 @see +setSharedLogger:
 */
+ (SLLogger *)sharedLogger;

/**
 Sets the shared logger used by the Subliminal framework and by user-defined tests.
 
 This should be called from the application delegate's implementation of 
 `-applicationDidFinishLaunching:`, before `-[SLTestController runTests:withCompletionBlock:]`
 is called.
 
 The logger should not be changed while the tests are running.
 
 @param logger A logger to set as the shared logger.
 */
+ (void)setSharedLogger:(SLLogger *)logger;

/**
 Returns a queue on which log messages may be serialized.
 
 @warning This must be overridden by concrete subclasses of SLLogger.
 See `SLUIALogger` for a reference implementation, while noting that only methods
 _that are overridden_ need be serialized. 
 
 By default, log methods other than `-logMessage:` format their arguments and call
 `-logMessage:`, so serializing that method would be sufficient to make a subclass
 thread-safe if that subclass only overrode `-logMessage:`.
 
 @return A custom serial dispatch queue on which to serialize log messages.
 */
- (dispatch_queue_t)loggingQueue;

/**
 Logs a message.
 
 This method is the primitive logging method used by all other logging methods 
 (by default) as well as by `SLLog` and `SLLogAsync`.

 @warning This must be overridden by concrete subclasses of `SLLogger` 
 to provide a mechanism and a destination for log output.

 @param message The message to log.
 */
- (void)logMessage:(NSString *)message;

/// ----------------------------------
/// @name Logging with severity levels
/// ----------------------------------

/**
 Logs a message as a "debug" message.
 
 @param debug The message to log.
 */
- (void)logDebug:(NSString *)debug;

/**
 Logs a message as a "warning" message.
 
 @param warning The message to log.
 */
- (void)logWarning:(NSString *)warning;

/**
 Logs a message as an "error" message.
 
 @param error The message to log.
 */
- (void)logError:(NSString *)error;

@end


/**
 The methods in the `SLLogger (SLTestController)` category are used by the
 shared test controller to log test progress. They should not be called 
 by a test writer.
 
 See `-[SLTestTests testCompleteTestRunSequence]` for an illustration
 of when these methods are called.
 */
@interface SLLogger (SLTestController)

/**
 Logs that testing has started.
 
 This method is called before any tests have run.
 */
- (void)logTestingStart;

/**
 Logs that the specified test has started.
 
 @param test The test that has started.
 */
- (void)logTestStart:(NSString *)test;

/**
 Logs that the specified test has finished.
 
 This means that it executed one or more test cases 
 and did not throw an exception in `[-setUpTest](-[SLTest setUpTest])` or
 `[-tearDownTest](-[SLTest tearDownTest])`.
 
 See `-[SLTest runAndReportNumExecuted:failed:failedUnexpectedly:]` for
 further discussion of the information that this method will be used to log.

 @param test The test that has finished.
 @param numCasesExecuted The number of cases that were executed.
 @param numCasesFailed Of `numCasesExecuted`, the number of cases that failed.
 @param numCasesFailedUnexpectedly Of `numCasesFailed`, the number of cases that failed unexpectedly 
 (those test cases that failed for reasons other than test assertion failures).
 
 @see -logTestAbort:
 */
- (void)logTestFinish:(NSString *)test
 withNumCasesExecuted:(NSUInteger)numCasesExecuted
       numCasesFailed:(NSUInteger)numCasesFailed
       numCasesFailedUnexpectedly:(NSUInteger)numCasesFailedUnexpectedly;

/**
 Logs that the specified test has aborted.
 
 As opposed to finishing; by throwing an exception in `[-setUpTest](-[SLTest setUpTest])`
 or `[-tearDownTest](-[SLTest tearDownTest])`.

 @param test The test that has aborted.
 
 @see -logTestFinish:withNumCasesExecuted:numCasesFailed:numCasesFailedUnexpectedly:
 */
- (void)logTestAbort:(NSString *)test;

/**
 Logs that testing has finished.
 
 This method is called after all tests have run.
 
 @param numTestsExecuted The number of tests that were executed.
 @param numTestsFailed Of `numTestsExecuted`, the number of tests that failed 
 (by throwing an exception in set-up, tear-down, or a test case).
 */
- (void)logTestingFinishWithNumTestsExecuted:(NSUInteger)numTestsExecuted
                              numTestsFailed:(NSUInteger)numTestsFailed;

@end


/**
 The methods in the `SLLogger (SLTest)` category are used by the
 tests to log test progress. They should not be called by a test writer.

 See `-[SLTestTests testCompleteTestRunSequence]` for an illustration
 of when these methods are called.
 */
@interface SLLogger (SLTest)

/**
 Logs that the specified test case has started.
 
 @param test The test that is currently running.
 @param testCase The test case that has started.
 */
- (void)logTest:(NSString *)test caseStart:(NSString *)testCase;

/**
 Logs that the specified test case has passed.
 
 By not throwing any exceptions.

 @param test The test that is currently running.
 @param testCase The test case that has passed.
 */
- (void)logTest:(NSString *)test casePass:(NSString *)testCase;

/**
 Logs that the specified test case has failed.
 
 See the discussion on the `SLTest (SLTestCase)` category for what constitutes 
 an "expected" failure.
 
 @param test The test that is currently running.
 @param testCase The test case that has failed.
 @param expected YES if the failure was "expected", otherwise NO.
 */
- (void)logTest:(NSString *)test caseFail:(NSString *)testCase expected:(BOOL)expected;

@end
