//
//  SLTestCase.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLTestController+AppContext.h"


extern NSString *const SLTestAssertionFailedException;
extern NSString *const SLTestExceptionFilenameKey;
extern NSString *const SLTestExceptionLineNumberKey;


@class SLLogger;

@interface SLTest : NSObject

@property (nonatomic, weak, readonly) SLTestController *testController;
@property (nonatomic, strong, readonly) SLLogger *logger;

+ (NSArray *)allTests;
+ (Class)testNamed:(NSString *)test;

/**
 Returns YES if this test exercises the application's start-up state,
 and thus should be run first.

 Tests should be independent, and thus can be (and are) run in no particular order.
 But designating one test to be run first may be useful:
 *  the state exercised might occur only once, upon launch;
    and reproducing it later might be difficult or unnatural
 *  the test can clear that state (i.e. in its tearDown), 
    so that other tests' set-up phases might be more concise
 
 Only one test can be the start-up test. (Remember, however, that a test can have 
 multiple test cases.) If multiple tests return YES from this method, the 
 test framework's behavior is undefined.
 
 @warning If this test throws an exception during set-up or tear-down, 
 testing will abort, on the assumption that the app was not able to start-up.

 @return YES if this state is the one-and-only start-up test, and should be run first;
         NO otherwise.
 */
+ (BOOL)isStartUpTest;

- (id)initWithLogger:(SLLogger *)logger testController:(SLTestController *)testController;

- (NSUInteger)run:(NSUInteger *)casesExecuted;

@end


@interface SLTest (SLTestCase)

/**
 Called before any test cases are run.
 
 In this method, tests should establish any state shared by all test cases, 
 including navigating to the part of the app being exercised by the test cases.
 
 In this method, tests can (and should) use SLTest assertions and SLElement "wait until..."
 methods to ensure that set-up was successful.
 
 @warning If set-up fails, this test will be aborted and its cases skipped.
 
 @sa tearDown
 */
- (void)setUp;

/**
 Called after all test cases are run.

 In this method, tests should clean up any state shared by all test cases, 
 such as that which was established in setUp.

 In this method, tests can (and should) use SLTest assertions and SLElement "wait until..."
 methods to ensure that tear-down was successful.
 
 @warning If tear-down fails, the test will be logged as having aborted rather than finished, 
 but its test cases will have already executed, so their logs will be preserved.

 @sa setUp
 */
- (void)tearDown;

/**
 Called before each test case is run.
 
 In this method, tests should establish any state particular to the specified test case.
 
 In this method, tests can (and should) use SLTest assertions and SLElement "wait until..."
 methods to ensure that set-up was successful.
 
 @warning If set-up fails, this test case will be logged as having failed.

 @param testSelector The selector identifying the test case about to be run.

 @sa tearDownTestCaseWithSelector:
 */
- (void)setUpTestCaseWithSelector:(SEL)testSelector;

/**
 Called after each test case is run.
 
 In this method, tests should clean up state particular to the specified test case,
 such as that which was established in setUpTestCaseWithSelector:.

 In this method, tests can (and should) use SLTest assertions and SLElement "wait until..."
 methods to ensure that tear-down was successful.

 @warning If tear-down fails, this test case will be logged as having failed even 
 if the test case itself succeeded.
 
 @param testSelector The selector identifying the test case that was run.

 @sa setUpTestCaseWithSelector:
 */
- (void)tearDownTestCaseWithSelector:(SEL)testSelector;


#pragma mark - SLElement Use

- (void)recordLastUIAMessageSendInFile:(char *)fileName atLine:(int)lineNumber;

#define UIAElement(slElement) ({ \
    [self recordLastUIAMessageSendInFile:__FILE__ atLine:__LINE__]; \
    slElement; \
})


#pragma mark - Test Assertions

- (void)failWithException:(NSException *)exception;

#define SLAssertTrue(expr, ...) ({\
    BOOL _evaluatedExpression = (expr); \
    if (!_evaluatedExpression) { \
        [self failWithException:[NSException testFailureInFile:__FILE__ atLine:__LINE__ \
                                                         reason:@"\"%@\" should be true. %@", \
                                                                @(#expr), [NSString stringWithFormat:__VA_ARGS__]]]; \
    } \
})

#define SLAssertFalse(expr, ...) ({\
    BOOL _evaluatedExpression = (expr); \
    if (_evaluatedExpression) { \
        [self failWithException:[NSException testFailureInFile:__FILE__ atLine:__LINE__ \
                                                         reason:@"\"%@\" should be true. %@", \
                                                                @(#expr), [NSString stringWithFormat:__VA_ARGS__]]]; \
    } \
})

#define SLWait(expr, timeout, ...) ({\
    NSTimeInterval _retryDelay = 0.25; \
    \
    NSDate *_startDate = [NSDate currentDate]; \
    BOOL _exprTrue = NO; \
    while (!(_exprTrue = (expr)) && \
            ([[NSDate currentDate] timeIntervalSinceDate:_startDate] < timeout)) { \
        [[NSThread currentThread] sleepForTimeInterval:_retryDelay]; \
    } \
    if (!_exprTrue) { \
        [self failWithException:[NSException testFailureInFile:__FILE__ atLine:__LINE__ \
                                                         reason:@"\"%@\" did not become true within %g seconds. %@", \
                                                                @(#expr), timeout, [NSString stringWithFormat:__VA_ARGS__]]; \
    } \
})

@end


@interface NSException (SLTestException)
+ (NSException *)testFailureInFile:(char *)fileName atLine:(int)lineNumber reason:(NSString *)failureReason, ... NS_FORMAT_FUNCTION(3, 4);
- (NSException *)exceptionAnnotatedWithLineNumber:(int)lineNumber inFile:(char *)fileName;
@end
