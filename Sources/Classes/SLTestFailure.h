//
//  SLTestCaseFailure.h
//  Subliminal
//
//  Created by Jacob Relkin on 6/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLTestFailurePhase) {
    SLTestFailurePhaseTestSetup,
    SLTestFailurePhaseTestCaseSetup,
    SLTestFailurePhaseTestCaseExecution,
    SLTestFailurePhaseTestCaseTeardown,
    SLTestFailurePhaseTestTeardown
};

/**
 SLTestFailure objects hold failure information for Subliminal test and test cases.
 */

@interface SLTestFailure : NSObject

/**
 @param exception The exception that was thrown to cause this failure.
 @param phase The phase in the test lifecycle in which the failure happened.
 @param testCaseSelector The failed test case's selector. (can be NULL)
 @return A new SLTestFailure object.
 */
+ (instancetype)failureWithException:(NSException *)exception phase:(SLTestFailurePhase)phase testCaseSelector:(SEL)testCaseSelector;

/**
 The phase in the test lifecycle in which the failure happened.
 */
@property (nonatomic, readonly, assign) SLTestFailurePhase phase;

/**
 The failed test case's selector. (can be NULL)
 */
@property (nonatomic, readonly, assign) SEL testCaseSelector;

/**
 The exception that was thrown to cause this failure.
 */
@property (nonatomic, readonly, strong) NSException *exception;

/**
 If the failure was expected.
 */
@property (nonatomic, readonly, getter = isExpected) BOOL expected;

@end
