//
//  SLUIALogger.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLUIALogger.h"

#import "SLTerminal.h"


@implementation SLUIALogger

- (void)log:(NSString *)message {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');", [message stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
}

- (void)logMessage:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *text = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');", [text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
}

@end


@implementation SLUIALogger (SLTestController)

- (void)logTestAbort:(NSString *)test {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logIssue('Test \"%@\" terminated abnormally.');", test];
}

@end


@implementation SLUIALogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logStart('Test case \"-[%@ %@]\" started.');", test, testCase];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logFail('Test case \"-[%@ %@]\" failed.');", test, testCase];
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logPass('Test case \"-[%@ %@]\" passed.');", test, testCase];
}

- (void)logTest:(NSString *)test caseIssue:(NSString *)testCase {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logIssue('Test case \"-[%@ %@]\" terminated abnormally.');", test, testCase];
}

- (void)logException:(NSString *)exception, ... {
    va_list args;
    va_start(args, exception);
    NSString *text = [[NSString alloc] initWithFormat:exception arguments:args];
    va_end(args);

    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logError('%@');", [text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
}

@end