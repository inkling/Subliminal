//
//  SLUIALogger.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLUIALogger.h"

@implementation SLUIALogger

- (void)logMessage:(NSString *)message, ... {
    [self.terminal send:@"UIALogger.logMessage('%@');", SLStringWithFormatAfter(message)];
}

@end


@implementation SLUIALogger (SLTestController)

- (void)logTestAbort:(NSString *)test {
    [self.terminal send:@"UIALogger.logIssue('Test \"%@\" terminated abnormally.');", test];
}

@end


@implementation SLUIALogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase {
    [self.terminal send:@"UIALogger.logStart('Test case \"-[%@ %@]\" started.');", test, testCase];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase {
    [self.terminal send:@"UIALogger.logFail('Test case \"-[%@ %@]\" failed.');", test, testCase];
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    [self.terminal send:@"UIALogger.logPass('Test case \"-[%@ %@]\" passed.');", test, testCase];
}

- (void)logTest:(NSString *)test caseAbort:(NSString *)testCase {
    [self.terminal send:@"UIALogger.logIssue('Test case \"-[%@ %@]\" terminated abnormally.');", test, testCase];
}

- (void)logException:(NSString *)exception, ... {
    [self.terminal send:@"UIALogger.logError('%@');", SLStringWithFormatAfter(exception)];
}

@end