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


@implementation SLUIALogger

- (void)logDebug:(NSString *)debug {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logDebug('%@');", [debug slStringByEscapingForJavaScriptLiteral]];
}

- (void)logMessage:(NSString *)message {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');", [message slStringByEscapingForJavaScriptLiteral]];
}

- (void)logWarning:(NSString *)warning {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logWarning('%@');", [warning slStringByEscapingForJavaScriptLiteral]];
}

- (void)logError:(NSString *)error {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logError('%@');", [error slStringByEscapingForJavaScriptLiteral]];
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
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logIssue('Test case \"-[%@ %@]\" terminated abnorally.');", test, testCase];
}

@end
