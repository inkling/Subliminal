//
//  TestUtilities.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/26/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "TestUtilities.h"

void SLRunTestsAndWaitUntilFinished(NSSet *tests, void (^completionBlock)()) {
    __block BOOL testingHasFinished = NO;
    [[SLTestController sharedTestController] runTests:tests
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
    SLAssertTrue(condition(), @"");
}

- (void)slAssertFalse:(BOOL (^)(void))condition {
    NSParameterAssert(condition);
    SLAssertFalse(condition(), @"");
}

- (void)sLWaitUntilTrue:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout {
    NSParameterAssert(condition);
    SLWaitUntilTrue(condition(), timeout, @"");
}

- (void)slAssertThrows:(void (^)(void))expression {
    NSParameterAssert(expression);
    SLAssertThrows(expression(), @"");
}

- (void)slAssertThrows:(void (^)(void))expression named:(NSString *)exceptionName {
    NSParameterAssert(expression);
    NSParameterAssert(exceptionName);
    SLAssertThrowsNamed(expression(), exceptionName, @"");
}

- (void)slAssertNoThrow:(void (^)(void))expression {
    NSParameterAssert(expression);
    SLAssertNoThrow(expression(), @"");
}

@end
