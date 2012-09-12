//
//  SLTestCase.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SLLogger;

@interface SLTest : NSObject

@property (nonatomic, readonly) SLLogger *logger;

+ (NSArray *)allTests;
+ (Class)testNamed:(NSString *)test;

- (id)initWithLogger:(SLLogger *)logger;

- (NSUInteger)run:(NSUInteger *)casesExecuted;

@end


@interface SLTest (SLTestCase)

- (void)setUp;
- (void)tearDown;

- (void)setUpTestWithSelector:(SEL)testSelector;
- (void)tearDownTestWithSelector:(SEL)testSelector;


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