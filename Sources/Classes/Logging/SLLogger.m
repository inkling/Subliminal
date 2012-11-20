//
//  SLLogger.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLLogger.h"

#import "SLUIALogger.h"


void SLLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    [[SLLogger sharedLogger] logMessage:[[NSString alloc] initWithFormat:format arguments:args]];
    va_end(args);
}


@implementation SLLogger

static SLLogger *__sharedLogger = nil;
+ (SLLogger *)sharedLogger {
    return __sharedLogger;
}

+ (void)setSharedLogger:(SLLogger *)logger {
    __sharedLogger = logger;
}

- (void)logDebug:(NSString *)debug test:(NSString *)test testCase:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Debug: %@", debug]];
}

- (void)logMessage:(NSString *)message test:(NSString *)test testCase:(NSString *)testCase {
    NSLog(@"Concrete SLLogger subclass (%@) must provide an interface to a Javascript logging functions", NSStringFromClass([self class]));
    [self doesNotRecognizeSelector:_cmd];
}

- (void)logWarning:(NSString *)warning test:(NSString *)test testCase:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Warning: %@", warning]];
}

- (void)logError:(NSString *)error test:(NSString *)test testCase:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Error: %@", error]];
}

- (void)logDebug:(NSString *)debug {
    [self logDebug:debug test:nil testCase:nil];
}

- (void)logMessage:(NSString *)message {
    [self logMessage:message test:nil testCase:nil];
}

- (void)logWarning:(NSString *)warning {
    [self logWarning:warning test:nil testCase:nil];
}

- (void)logError:(NSString *)error {
    [self logError:error test:nil testCase:nil];
}

@end


@implementation SLLogger (SLTestController)

- (void)logTestingStart {
    [self logMessage:@"Testing started."];
}

- (void)logTestStart:(NSString *)test {
    [self logMessage:[NSString stringWithFormat:@"Test \"%@\" started.", test]];
}

- (void)logTestFinish:(NSString *)test
 withNumCasesExecuted:(NSUInteger)numCasesExecuted
       numCasesFailed:(NSUInteger)numCasesFailed {
    [self logMessage:[NSString stringWithFormat:@"Test \"%@\" finished: executed %u tests, with %u failures.", test, numCasesExecuted, numCasesFailed]];
}

- (void)logTestAbort:(NSString *)test {
    [self logError:[NSString stringWithFormat:@"Test \"%@\" terminated abnormally.", test]];
}

- (void)logTestingFinish {
    [self logMessage:@"Testing finished."];
}

@end


@implementation SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" started.", test, testCase]];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase {
    [self logError:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" failed.", test, testCase]];
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" passed.", test, testCase]];
}

- (void)logTest:(NSString *)test caseIssue:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" terminated abnorally.", test, testCase]];
}

@end
