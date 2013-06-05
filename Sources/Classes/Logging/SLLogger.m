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

#import "SLLogger.h"
#import "SLTerminal.h"
#import "SLStringUtilities.h"


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

@implementation SLLogger {
    dispatch_queue_t _loggingQueue;
}

+ (SLLogger *)sharedLogger {
    static SLLogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [[SLLogger alloc] init];
    });
    return sharedLogger;
}

- (id)init {
    self = [super init];
    if (self) {
        _loggingQueue = dispatch_queue_create("com.inkling.subliminal.SLUIALogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_loggingQueue);
}

- (dispatch_queue_t)loggingQueue {
    return _loggingQueue;
}

- (void)logDebug:(NSString *)debug {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logDebug:debug];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logDebug('%@');", [debug slStringByEscapingForJavaScriptLiteral]];
}

- (void)logMessage:(NSString *)message {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logMessage:message];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');", [message slStringByEscapingForJavaScriptLiteral]];
}

- (void)logWarning:(NSString *)warning {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logWarning:warning];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logWarning('%@');", [warning slStringByEscapingForJavaScriptLiteral]];
}

- (void)logError:(NSString *)error {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logError:error];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logError('%@');", [error slStringByEscapingForJavaScriptLiteral]];
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
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logTest:test caseStart:testCase];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logStart('Test case \"-[%@ %@]\" started.');", test, testCase];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase expected:(BOOL)expected {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logTest:test caseFail:testCase expected:expected];
        });
        return;
    }

    if (expected) {
        [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logFail('Test case \"-[%@ %@]\" failed.');", test, testCase];
    } else {
        [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logIssue('Test case \"-[%@ %@]\" failed unexpectedly.');", test, testCase];
    }
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logTest:test casePass:testCase];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logPass('Test case \"-[%@ %@]\" passed.');", test, testCase];
}

@end
