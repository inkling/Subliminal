//
//  TestUtilities.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/26/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "TestUtilities.h"
#import <OCMock/OCMock.h>

void SLRunTestsAndWaitUntilFinished(NSSet *tests, void (^completionBlock)()) {
    SLRunTestsUsingSeedAndWaitUntilFinished(tests, SLTestControllerRandomSeed, completionBlock);
}

void SLRunTestsUsingSeedAndWaitUntilFinished(NSSet *tests, unsigned int seed, void (^completionBlock)()) {
    __block BOOL testingHasFinished = NO;
    [[SLTestController sharedTestController] runTests:tests
                                            usingSeed:seed
                                  withCompletionBlock:^{
                                      if (completionBlock) completionBlock();
                                      testingHasFinished = YES;
                                  }];
    while (!testingHasFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    // After the SLTestController executes its completion block
    // it still has a little more work to do to tear down its state.
    // We must spin once more to give it time to do so.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
}


@implementation SLTestController (UnitTestingEnv)

+ (void)load {
    setenv("SL_UNIT_TESTING", "YES", 1);
}

@end


@implementation SLTest (SLTestTestsMacroHelpers)

- (void)slAssertFailAtFilename:(NSString *__autoreleasing *)filename lineNumber:(int *)lineNumber {
    NSParameterAssert(filename);
    NSParameterAssert(lineNumber);

    // purposefully put everything below on one line
    // so that we return by-reference the same filename and line number
    // as the assertion uses
    *filename = [@(__FILE__) lastPathComponent]; *lineNumber = __LINE__; SLAssertTrue(NO, @"Expected failure.");
}

- (void)slAssertTrue:(BOOL (^)(void))condition {
    NSParameterAssert(condition);
    SLAssertTrue(condition(), nil);
}

- (void)slAssertTrueWithUnsignedInteger:(NSUInteger (^)(void))expression {
    NSParameterAssert(expression);
    SLAssertTrue(expression(), nil);
}

- (void)slAssertFalse:(BOOL (^)(void))condition {
    NSParameterAssert(condition);
    SLAssertFalse(condition(), nil);
}

- (void)SLAssertTrueWithTimeout:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout {
    NSParameterAssert(condition);
    SLAssertTrueWithTimeout(condition(), timeout, nil);
}

- (BOOL)SLIsTrue:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout {
    NSParameterAssert(condition);
    return SLIsTrueWithTimeout(condition(), timeout);
}

- (BOOL)SLWaitUntilTrue:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout {
    NSParameterAssert(condition);
    return SLWaitUntilTrue(condition(), timeout);
}

- (void)slAssertThrows:(void (^)(void))expression {
    NSParameterAssert(expression);
    SLAssertThrows(expression(), nil);
}

- (void)slAssertThrows:(void (^)(void))expression named:(NSString *)exceptionName {
    NSParameterAssert(expression);
    NSParameterAssert(exceptionName);
    SLAssertThrowsNamed(expression(), exceptionName, nil);
}

- (void)slAssertNoThrow:(void (^)(void))expression {
    NSParameterAssert(expression);
    SLAssertNoThrow(expression(), nil);
}

- (void)slFailWithExceptionRecordedByUIAElementMacro:(NSException *)exception
                                thrownBySLUIAElement:(BOOL)haveSLUIAElementThrow
                                          atFilename:(NSString *__autoreleasing *)filename lineNumber:(int *)lineNumber {
    NSParameterAssert(exception);
    NSParameterAssert(filename);
    NSParameterAssert(lineNumber);

    // create a fake element to tap, optionally throwing the exception with which this test case should fail
    id mockElement = [OCMockObject niceMockForClass:[SLUIAElement class]];
    if (haveSLUIAElementThrow) {
        [[[mockElement stub] andThrow:exception] tap];
    }

    // purposefully put everything below on one line
    // so that we return by-reference the same filename and line number that `UIAElement` records
    *filename = [@(__FILE__) lastPathComponent]; *lineNumber = __LINE__; [UIAElement(mockElement) tap];

    NSAssert(!haveSLUIAElementThrow,
             @"If `haveSLUIAElementThrow` was `YES`, this method should have already thrown an exception.");
    [exception raise];
}

@end
