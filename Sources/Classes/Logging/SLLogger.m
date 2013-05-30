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

void SLLogAsync(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    dispatch_async([[SLLogger sharedLogger] loggingQueue], ^{
        [[SLLogger sharedLogger] logMessage:message];
    });
}

@implementation SLLogger

static SLLogger *__sharedLogger = nil;
+ (SLLogger *)sharedLogger {
    return __sharedLogger;
}

+ (void)setSharedLogger:(SLLogger *)logger {
    __sharedLogger = logger;
}

- (dispatch_queue_t)loggingQueue {
    NSAssert(NO, @"Concrete SLLogger subclass (%@) must implement %@",
             NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return NULL;
}

- (void)logMessage:(NSString *)message {
    NSLog(@"Concrete SLLogger subclass (%@) must implement %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
}

- (void)logDebug:(NSString *)debug {
    [self logMessage:[NSString stringWithFormat:@"Debug: %@", debug]];
}


- (void)logWarning:(NSString *)warning {
    [self logMessage:[NSString stringWithFormat:@"Warning: %@", warning]];
}

- (void)logError:(NSString *)error {
    [self logMessage:[NSString stringWithFormat:@"Error: %@", error]];
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
       numCasesFailed:(NSUInteger)numCasesFailed
       numCasesFailedUnexpectedly:(NSUInteger)numCasesFailedUnexpectedly {
    [self logMessage:[NSString stringWithFormat:@"Test \"%@\" finished: executed %u case%@, with %u failure%@ (%u unexpected).",
                                                test, numCasesExecuted, (numCasesExecuted == 1 ? @"" : @"s"),
                                                      numCasesFailed, (numCasesFailed == 1 ? @"" : @"s"), numCasesFailedUnexpectedly]];
}

- (void)logTestAbort:(NSString *)test {
    [self logError:[NSString stringWithFormat:@"Test \"%@\" terminated abnormally.", test]];
}

- (void)logTestingFinishWithNumTestsExecuted:(NSUInteger)numTestsExecuted
                              numTestsFailed:(NSUInteger)numTestsFailed {
    [self logMessage:[NSString stringWithFormat:@"Testing finished: executed %u test%@, with %u failures.",
                                                numTestsExecuted, (numTestsExecuted == 1 ? @"" : @"s"), numTestsFailed]];
}

@end


@implementation SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" started.", test, testCase]];
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" passed.", test, testCase]];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase expected:(BOOL)expected {
    [self logError:[NSString stringWithFormat:@"Test case \"-[%@ %@]\" failed%@.",
                                                test, testCase, (expected ? @"" : @" unexpectedly")]];
}

@end
