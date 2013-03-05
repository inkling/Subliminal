//
//  SLTestController.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTestController.h"
#import "SLTestController+Internal.h"

#import "SLLogger.h"
#import "SLTest.h"
#import "SLTerminal.h"
#import "SLElement.h"

#import <objc/runtime.h>


static NSUncaughtExceptionHandler *appsUncaughtExceptionHandler = NULL;
static const NSTimeInterval kDefaultTimeout = 5.0;

/// Uncaught exceptions are logged to Subliminal for visibility.
static void SLUncaughtExceptionHandler(NSException *exception)
{
    NSString *exceptionMessage = [NSString stringWithFormat:@"Exception occurred: **%@** for reason: %@", [exception name], [exception reason]];
    if ([NSThread isMainThread]) {
        // We need to wait for UIAutomation, but we can't block the main thread,
        // so we spin the run loop instead.
        __block BOOL hasLogged = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            SLLog(@"%@", exceptionMessage);
            hasLogged = YES;
        });
        while (!hasLogged) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
        }
    } else {
        SLLog(@"%@", exceptionMessage);
    }

    if (appsUncaughtExceptionHandler) {
        appsUncaughtExceptionHandler(exception);
    }
}

@implementation SLTestController {
    BOOL _runningWithFocus;
    NSSet *_testsToRun;
    void(^_completionBlock)(void);
}

+ (void)initialize {
    // initialize shared test controller, to prevent an SLTestController
    // from being manually initialized prior to +sharedTestController being invoked,
    // bypassing the assert at the top of -init
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [SLTestController sharedTestController];
#pragma clang diagnostic pop
}

static SLTestController *__sharedController = nil;
+ (id)sharedTestController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedController = [[SLTestController alloc] init];
    });
    return __sharedController;
}

+ (dispatch_queue_t)runQueue {
    static dispatch_queue_t __runQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __runQueue = dispatch_queue_create("com.inkling.subliminal.SLTest.runQueue", DISPATCH_QUEUE_SERIAL);
    });
    return __runQueue;
}

+ (NSSet *)testsToRun:(NSSet *)tests withFocus:(BOOL *)withFocus {
    // only run tests that are concrete...
    NSMutableSet *testsToRun = [NSMutableSet setWithSet:tests];
    [testsToRun filterUsingPredicate:[NSPredicate predicateWithFormat:@"isAbstract == NO"]];

    // ...that support the current platform...
    [testsToRun filterUsingPredicate:[NSPredicate predicateWithFormat:@"supportsCurrentPlatform == YES"]];

    // ...and that are focused (if any remaining are focused)
    NSSet *focusedTests = [testsToRun objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return [obj isFocused];
    }];
    BOOL runningWithFocus = ([focusedTests count] > 0);
    if (runningWithFocus) {
        testsToRun = [NSMutableSet setWithSet:focusedTests];
    }
    if (withFocus) *withFocus = runningWithFocus;

    return [testsToRun copy];
}

- (id)init {
    NSAssert(!__sharedController, @"SLTestController should not be initialized manually. Use +sharedTestController instead.");
    
    self = [super init];
    if (self) {
        _defaultTimeout = kDefaultTimeout;
    }
    return self;
}

- (void)_beginTesting {
    appsUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&SLUncaughtExceptionHandler);

    // register defaults
    SLLog(@"Tests are starting up... ");

    [SLElement setDefaultTimeout:_defaultTimeout];
    
    if (_runningWithFocus) {
        SLLog(@"Focusing on test cases in specific tests: %@.", [[_testsToRun allObjects] componentsJoinedByString:@","]);
    }
    [[SLLogger sharedLogger] logTestingStart];
}

- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock {
    dispatch_async([[self class] runQueue], ^{
        NSAssert([SLLogger sharedLogger], @"A shared SLLogger must be set (+[SLLogger setSharedLogger:]) before SLTestController can run tests.");
        
        _completionBlock = [completionBlock copy];

        _testsToRun = [[self class] testsToRun:tests withFocus:&_runningWithFocus];
        if (![_testsToRun count]) {
            SLLog(@"%@%@%@", @"There are no tests to run", (_runningWithFocus) ? @": no tests are focused" : @"", @".");
            [self _finishTesting];
            return;
        }

        [self _beginTesting];

        for (Class testClass in _testsToRun) {
            @autoreleasepool {
                SLTest *test = (SLTest *)[[testClass alloc] initWithTestController:self];

                NSString *testName = NSStringFromClass(testClass);
                [[SLLogger sharedLogger] logTestStart:testName];

                @try {
                    NSUInteger numCasesExecuted = 0;
                    NSUInteger numCasesFailed = [test run:&numCasesExecuted];

                    [[SLLogger sharedLogger] logTestFinish:testName
                                      withNumCasesExecuted:numCasesExecuted
                                            numCasesFailed:numCasesFailed];
                }
                @catch (NSException *e) {
                    // If an assertion carries call site info, that suggests it was "expected",
                    // and we log it more tersely than other exceptions.
                    NSString *fileName = [[e userInfo] objectForKey:SLTestExceptionFilenameKey];
                    int lineNumber = [[[e userInfo] objectForKey:SLTestExceptionLineNumberKey] intValue];
                    NSString *message = nil;
                    if (fileName) {
                        message = [NSString stringWithFormat:@"%@:%d: %@",
                                   fileName, lineNumber, [e reason]];
                    } else {
                        message = [NSString stringWithFormat:@"Unexpected exception occurred ***%@*** for reason: %@",
                                   [e name], [e reason]];
                    }
                    [[SLLogger sharedLogger] logError:message];
                    [[SLLogger sharedLogger] logTestAbort:testName];
                }
            }
        }

        [self _finishTesting];
    });
}

- (void)_finishTesting {
    // only log that we finished if we ran some tests
    if ([_testsToRun count]) {
        [[SLLogger sharedLogger] logTestingFinish];

        if (_runningWithFocus) {
            SLLog(@"Warning: this was a focused run. Fewer test cases may have run than normal.");
        }
    } else {
        SLLog(@"Testing aborted.");
    }

    if (_completionBlock) dispatch_sync(dispatch_get_main_queue(), _completionBlock);

    // NOTE: Everything below the next line will not execute when running with Instruments attached,
    // because the UIAutomation script will terminate, and then the app.
    [[SLTerminal sharedTerminal] eval:@"_testingHasFinished = true;"];

    // clear controller state (important when testing Subliminal, when the controller will test repeatedly)
    _runningWithFocus = NO;
    _testsToRun = nil;
    _completionBlock = nil;

    // deregister Subliminal's exception handler
    // this is important when unit testing Subliminal, so that successive Subliminal testing runs
    // don't treat Subliminal's handler as the app's handler,
    // which would cause Subliminal's handler to recurse (as it calls the app's handler)
    NSSetUncaughtExceptionHandler(appsUncaughtExceptionHandler);
}

@end
