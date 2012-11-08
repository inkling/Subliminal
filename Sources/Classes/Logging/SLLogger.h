//
//  SLLogger.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Prints some information to the testing environment.
 
 Equivalent to NSLog() except for the output medium. Implemented using [SLLogger logMessage:].
 */
void SLLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);


@interface SLLogger : NSObject

+ (SLLogger *)sharedLogger;
+ (void)setSharedLogger:(SLLogger *)logger;

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

- (void)logTestingFinish;

@end


@interface SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase;
- (void)logTest:(NSString *)test caseFail:(NSString *)testCase;
- (void)logTest:(NSString *)test casePass:(NSString *)testCase;
- (void)logTest:(NSString *)test caseIssue:(NSString *)testCase;

@end
