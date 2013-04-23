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
    NSCAssert([[SLLogger sharedLogger] conformsToProtocol:@protocol(SLThreadSafeLogger)],
              @"SLLogAsync can only be used if the shared logger is thread-safe.");
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    dispatch_async([(id<SLThreadSafeLogger>)[SLLogger sharedLogger] loggingQueue], ^{
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

- (void)logDebug:(NSString *)debug {
    [self logMessage:[NSString stringWithFormat:@"Debug: %@", debug]];
}

- (void)logMessage:(NSString *)message {
    NSLog(@"Concrete SLLogger subclass (%@) must implement %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
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

- (void)logDebug:(NSString *)debug test:(NSString *)test testCase:(NSString *)testCase {
    [self logDebug:[NSString stringWithFormat:@"-[%@ %@]: %@", test, testCase, debug]];
}

- (void)logMessage:(NSString *)message test:(NSString *)test testCase:(NSString *)testCase {
    [self logMessage:[NSString stringWithFormat:@"-[%@ %@]: %@", test, testCase, message]];
}

- (void)logWarning:(NSString *)warning test:(NSString *)test testCase:(NSString *)testCase {
    [self logWarning:[NSString stringWithFormat:@"-[%@ %@]: %@", test, testCase, warning]];
}

- (void)logError:(NSString *)error test:(NSString *)test testCase:(NSString *)testCase {
    [self logError:[NSString stringWithFormat:@"-[%@ %@]: %@", test, testCase, error]];
}

@end
