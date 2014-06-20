//
//  SLTestCaseExceptionInfo.m
//  Subliminal
//
//  Created by Jacob Relkin on 6/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseExceptionInfo.h"
#import "SLTest.h"

@interface SLTestCaseExceptionInfo ()

@property (nonatomic, readwrite, strong) NSException *exception;
@property (nonatomic, readwrite, assign) SEL testCaseSelector;

@end

@implementation SLTestCaseExceptionInfo

+ (instancetype)exceptionInfoWithException:(NSException *)exception testCaseSelector:(SEL)testCaseSelector {
    SLTestCaseExceptionInfo *info = [self new];
    info.exception = exception;
    info.testCaseSelector = testCaseSelector;
    return info;
}

- (BOOL)isExpected {
    return [self.exception.name isEqualToString:SLTestAssertionFailedException];
}

@end
