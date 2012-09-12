//
//  SLLogger.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLLogger.h"

#import "SLTerminal.h"


@implementation SLLogger

- (id)initWithTerminal:(SLTerminal *)terminal {
    self = [super init];
    if (self) {
        _terminal = terminal;
    }
    return self;
}

- (void)logMessage:(NSString *)message, ... {
    NSLog(@"Concrete SLLogger subclass (%@) must provide an interface to a Javascript logging functions", NSStringFromClass([self class]));
    [self doesNotRecognizeSelector:_cmd];
}

@end


@implementation SLLogger (SLTestController)

- (void)logTestingStart {
    [self logMessage:@"Testing started."];
}

- (void)logTestStart:(NSString *)test {
    [self logMessage:@"Test \"%@\" started.", test];
}

- (void)logTestFinish:(NSString *)test
 withNumCasesExecuted:(NSUInteger)numCasesExecuted
       numCasesFailed:(NSUInteger)numCasesFailed {
    [self logMessage:@"Test \"%@\" finished: executed %u tests, with %u failures.", test, numCasesExecuted, numCasesFailed];
}

- (void)logTestingFinish {
    [self logMessage:@"Testing finished."];
}

@end


@implementation SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase {
    [self logMessage:@"Test case \"-[%@ %@]\" started.", test, testCase];
}

- (void)logTest:(NSString *)test caseFail:(NSString *)testCase {
    [self logMessage:@"Test case \"-[%@ %@]\" failed.", test, testCase];
}

- (void)logTest:(NSString *)test casePass:(NSString *)testCase {
    [self logMessage:@"Test case \"-[%@ %@]\" passed.", test, testCase];
}

- (void)logTest:(NSString *)test caseAbort:(NSString *)testCase {
    [self logMessage:@"Test case \"-[%@ %@]\" terminated abnormally.", test, testCase];
}

- (void)logException:(NSString *)exception, ... {
    [self logMessage:@"Error: \"%@\"", SLStringWithFormatAfter(exception)];
}

@end
