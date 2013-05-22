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
 
 Functionally equivalent to NSLog(), except for the output medium.
 The message is output using [[SLLogger sharedLogger] logMessage:].
 */
void SLLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

/**
 Asynchronously logs a message to the testing environment.
 
 This variant of SLLog is for use by the application 
 and other main thread contexts.
 */
void SLLogAsync(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);


@interface SLLogger : NSObject

+ (SLLogger *)sharedLogger;
+ (void)setSharedLogger:(SLLogger *)logger;

/// Returns a queue on which log messages may be serialized.
- (dispatch_queue_t)loggingQueue;

- (void)logDebug:(NSString *)debug;
- (void)logMessage:(NSString *)message;
- (void)logWarning:(NSString *)warning;
- (void)logError:(NSString *)error;

@end


@interface SLLogger (SLTestController)

- (void)logTestingStart;

- (void)logTestStart:(NSString *)test;

- (void)logTestFinish:(NSString *)test
 withNumCasesExecuted:(NSUInteger)numCasesExecuted
       numCasesFailed:(NSUInteger)numCasesFailed;

- (void)logTestAbort:(NSString *)test;

- (void)logTestingFinishWithNumTestsExecuted:(NSUInteger)numTestsExecuted
                              numTestsFailed:(NSUInteger)numTestsFailed;

@end


@interface SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase;
- (void)logTest:(NSString *)test caseFail:(NSString *)testCase;
- (void)logTest:(NSString *)test casePass:(NSString *)testCase;
- (void)logTest:(NSString *)test caseIssue:(NSString *)testCase;

- (void)logDebug:(NSString *)debug test:(NSString *)test testCase:(NSString *)testCase;
- (void)logMessage:(NSString *)message test:(NSString *)test testCase:(NSString *)testCase;
- (void)logWarning:(NSString *)warning test:(NSString *)test testCase:(NSString *)testCase;
- (void)logError:(NSString *)error test:(NSString *)test testCase:(NSString *)testCase;

@end
