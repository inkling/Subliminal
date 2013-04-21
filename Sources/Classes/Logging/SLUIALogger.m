//
//  SLUIALogger.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLUIALogger.h"

#import "SLTerminal.h"
#import "NSString+SLJavaScript.h"


@implementation SLUIALogger {
    dispatch_queue_t _loggingQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        _loggingQueue = dispatch_queue_create("com.subliminal.SLUIALogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
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

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logTest:test caseFail:testCase];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logFail('Test case \"-[%@ %@]\" failed.');", test, testCase];
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

- (void)logTest:(NSString *)test caseIssue:(NSString *)testCase {
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self logTest:test caseIssue:testCase];
        });
        return;
    }

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logIssue('Test case \"-[%@ %@]\" terminated abnorally.');", test, testCase];
}

@end
