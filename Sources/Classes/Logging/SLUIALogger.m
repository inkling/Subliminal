//
//  SLUIALogger.m
//  SubliminalTest
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

#import "SLUIALogger.h"

#import "SLTerminal.h"
#import "SLStringUtilities.h"


@implementation SLUIALogger {
    dispatch_queue_t _loggingQueue;
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


@implementation SLUIALogger (SLTest)

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
