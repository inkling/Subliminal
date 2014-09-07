//
//  SLTestState.m
//  Subliminal
//
//  Created by Jacob Relkin on 8/22/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestState.h"
#import "SLTestFailure.h"

@interface SLTestState ()

@property (nonatomic, readwrite) BOOL failed;
@property (nonatomic, readwrite) BOOL failureWasExpected;

@end

@implementation SLTestState

- (void)recordFailure:(SLTestFailure *)failure {
    NSParameterAssert(failure);

    if (!self.failed) {
        self.failureWasExpected = failure.isExpected;
    }

    self.failed = YES;
}

@end
