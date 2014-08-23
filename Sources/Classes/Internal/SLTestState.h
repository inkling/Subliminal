//
//  SLTestState.h
//  Subliminal
//
//  Created by Jacob Relkin on 8/22/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLTestFailure;

/**
 SLTestState objects define the state of a Subliminal test or test case.
 */

@interface SLTestState : NSObject

/**
 Denotes whether the test or test case failed
 */
@property (nonatomic, readonly) BOOL failed;

/**
 If the test or test case failure was expected.
 */
@property (nonatomic, readonly) BOOL failureWasExpected;

/**
 Sets the properties above, from the failure's description.
 The value of `failureWasExpected` is determined by the first failure that was encountered.

 @param failure The test failure to record.
 */
- (void)recordFailure:(SLTestFailure *)failure;

@end
