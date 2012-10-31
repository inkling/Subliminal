//
//  SLLogger.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SLLogger : NSObject


- (void)logMessage:(NSString *)message, ... NS_FORMAT_FUNCTION(1, 2);

@end


@interface SLLogger (SLTestController)

- (void)logTestingStart;

- (void)logTestStart:(NSString *)test;

- (void)logTestFinish:(NSString *)test
 withNumCasesExecuted:(NSUInteger)numCasesExecuted
       numCasesFailed:(NSUInteger)numCasesFailed;

- (void)logTestAbort:(NSString *)test;

- (void)logTestingFinish;

@end


@interface SLLogger (SLTest)

- (void)logTest:(NSString *)test caseStart:(NSString *)testCase;
- (void)logTest:(NSString *)test caseFail:(NSString *)testCase;
- (void)logTest:(NSString *)test casePass:(NSString *)testCase;
- (void)logTest:(NSString *)test caseAbort:(NSString *)testCase;

- (void)logException:(NSString *)exception, ... NS_FORMAT_FUNCTION(1, 2);

@end
