//
//  SLLogger.h
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
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


#pragma mark Convenience Functions

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
    TODO: Jeff, please fill in documentation for SLLogger
 */
@interface SLLogger : NSObject

#pragma mark - Getting and Setting the Shared Logger
/// ----------------------------------------------
/// @name Getting and Setting the Shared Logger
/// ----------------------------------------------

/**
 The shared logger used by the Subliminal framework and by user-defined tests.

 @return The shared logger.
 */
+ (SLLogger *)sharedLogger;

#pragma mark - Primitive Methods
/// -------------------------------------
/// @name Primitive Methods
/// -------------------------------------

/**
 Returns a queue on which log messages may be serialized.
 
 @return A custom serial dispatch queue on which to serialize log messages.
 */
- (dispatch_queue_t)loggingQueue;

/**
 Logs a message.
 
 This method is the primitive logging method used by all other logging methods 
 (by default) as well as by `SLLog` and `SLLogAsync`.

 @param message The message to log.
 */
- (void)logMessage:(NSString *)message;

#pragma mark - Logging with Severity Levels
/// -------------------------------------
/// @name Logging with Severity Levels
/// -------------------------------------

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
 shared test controller to log the progress of the test run. They should not 
 be called by a test writer.
 
 See `-[SLTestTests testCompleteTestRunSequence]` for an illustration
 of when these methods are called.
 */
@interface SLLogger (SLTestController)

#pragma mark - Logging Run Progress
/// -------------------------------------
/// @name Logging Run Progress
/// -------------------------------------

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

#pragma mark - Logging Test Progress
/// -------------------------------------
/// @name Logging Test Progress
/// -------------------------------------

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
