//
//  SLTestCaseFailure.m
//  Subliminal
//
//  Created by Jacob Relkin on 6/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestFailure.h"
#import "SLTest.h"

@interface SLTestFailure ()

@property (nonatomic, readwrite, strong) NSException *exception;
@property (nonatomic, readwrite, assign) SEL testCaseSelector;
@property (nonatomic, readwrite, assign) SLTestFailurePhase phase;

@end

@implementation SLTestFailure

+ (instancetype)failureWithException:(NSException *)exception phase:(SLTestFailurePhase)phase testCaseSelector:(SEL)testCaseSelector {
    SLTestFailure *failure = [self new];
    failure.phase = phase;
    failure.exception = exception;
    failure.testCaseSelector = testCaseSelector;
    return failure;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SLTestFailure class]]) {
        return NO;
    }

    SLTestFailure *otherObject = object;
    return (otherObject.phase == self.phase &&
            otherObject.testCaseSelector == self.testCaseSelector &&
            otherObject.isExpected == self.isExpected &&
            [otherObject.exception.name isEqualToString:self.exception.name] &&
            [otherObject.exception.reason isEqualToString:self.exception.reason]);
}

- (BOOL)isExpected {
    return [self.exception.name isEqualToString:SLTestAssertionFailedException];
}

@end
