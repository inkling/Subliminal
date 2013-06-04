//
//  SLLogger.m
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
    [self logMessage:[NSString stringWithFormat:@"Testing finished: executed %u test%@, with %u failure%@.",
                                                numTestsExecuted, (numTestsExecuted == 1 ? @"" : @"s"),
                                                numTestsFailed, (numTestsFailed == 1 ? @"" : @"s")]];
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
