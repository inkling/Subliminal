//
//  SLTestCaseExceptionInfo.h
//  Subliminal
//
//  Created by Jacob Relkin on 6/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLTestCaseExceptionInfo : NSObject

+ (instancetype)exceptionInfoWithException:(NSException *)exception testCaseSelector:(SEL)testCaseSelector;

@property (nonatomic, readonly, assign) SEL testCaseSelector;
@property (nonatomic, readonly, strong) NSException *exception;
@property (nonatomic, readonly, getter = isExpected) BOOL expected;

@end
