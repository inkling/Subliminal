//
//  SLTestCaseExceptionInfo.h
//  Subliminal
//
//  Created by Jacob Relkin on 6/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `SLTestCaseExceptionInfo` is a class whose objects encapsulate the state of a test run when an exception was caught.
  */

@interface SLTestCaseExceptionInfo : NSObject

/**
 Initializes a new `SLTestExceptionInfo` object.
 @param exception The underlying `NSException` that was thrown. (Required)
 @param testCaseSelector The test case selector at the time of throw, or NULL if thrown outside of a test case.
 @see -[SLTest testRunDidCatchExceptionWithExceptionInfo:]
 @return A new `SLTestExceptioninfo` object.
 */
+ (instancetype)exceptionInfoWithException:(NSException *)exception testCaseSelector:(SEL)testCaseSelector;

/**
 The test case selector at the time of throw, or NULL if thrown outside of a test case.
 The default value is NULL.
 */
@property (nonatomic, readonly, assign) SEL testCaseSelector;

/**
 The underlying exception that was thrown.
 */
@property (nonatomic, readonly, strong) NSException *exception;

/**
 If the thrown exception was expected.
 */
@property (nonatomic, readonly, getter = isExpected) BOOL expected;

@end
