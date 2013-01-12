//
//  SLTestController.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTestController.h"

#import "SLLogger.h"
#import "SLTest.h"
#import "SLTerminal.h"
#import "SLElement.h"

#import <objc/runtime.h>


static NSUncaughtExceptionHandler *appsUncaughtExceptionHandler = NULL;
static const NSTimeInterval kDefaultTimeout = 5.0;

static void SLUncaughtExceptionHandler(NSException *exception)
{
    NSString *exceptionMessage = [NSString stringWithFormat:@"Exception occurred: **%@** for reason: %@", [exception name], [exception reason]];
    [[SLLogger sharedLogger] logError:exceptionMessage];

    if (appsUncaughtExceptionHandler) {
        appsUncaughtExceptionHandler(exception);
    }
}

@implementation SLTestController {
    BOOL _runningWithFocus;
    NSMutableArray *_testsToRun;
    void(^_completionBlock)(void);
}

+ (void)initialize {
    // initialize shared test controller,
    // to prevent manual initialization of an SLTestController
    // prior to +sharedTestController being invoked
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
        SLLog(@"Focusing on test cases in specific tests: %@.", _testsToRun);
    }
    [[SLLogger sharedLogger] logTestingStart];
}

- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock {
    dispatch_async([[self class] runQueue], ^{
        NSAssert([SLLogger sharedLogger], @"A shared SLLogger must be set (+[SLLogger setSharedLogger:]) before SLTestController can run tests.");
        
        _completionBlock = [completionBlock copy];

        // if any tests are focused and can be run, only run those tests
        _testsToRun = [NSMutableArray arrayWithArray:[tests allObjects]];
        for (Class testClass in _testsToRun) {
            // a focused test must support the current platform in order to run
            if ([testClass supportsCurrentPlatform] && [testClass isFocused]) {
                _runningWithFocus = YES;
                break;
            }
        }
        if (_runningWithFocus) {
            [_testsToRun filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject isFocused];
            }]];
        }

        if (![_testsToRun count]) {
            SLLog(@"%@%@%@", @"There are no tests to run", (_runningWithFocus) ? @": no tests are focused" : @"", @".");
            [self _finishTesting];
            return;
        }

        [self _beginTesting];

        // ensure we'll execute startup test first if present
        // note: if this is a focused run, the startup test will only run if it is focused
        __block NSUInteger startupTestIndex = NSNotFound;
        [_testsToRun enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isStartUpTest]) {
                startupTestIndex = idx;
                *stop = YES;
            }
        }];
        if (startupTestIndex != NSNotFound) {
            id startupTestClass = [_testsToRun objectAtIndex:startupTestIndex];
            [_testsToRun removeObjectAtIndex:startupTestIndex];
            [_testsToRun insertObject:startupTestClass atIndex:0];
        }

        for (Class testClass in _testsToRun) {
            if (![testClass supportsCurrentPlatform]) {
                continue;
            }

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
                // attempt to recover information about the site of the exception
                NSString *fileName = [[e userInfo] objectForKey:SLTestExceptionFilenameKey];
                int lineNumber = [[[e userInfo] objectForKey:SLTestExceptionLineNumberKey] intValue];

                // all exceptions caught at this level should be considered unexpected,
                // and logged as such (contrast SLTest exception logging)
                NSString *message = [NSString stringWithFormat:@"%@:%d: Exception occurred: **%@** for reason: %@", fileName, lineNumber, [e name], [e reason]];
                [[SLLogger sharedLogger] logError:message];
                [[SLLogger sharedLogger] logTestAbort:testName];

                if ([[test class] isStartUpTest]) {
                    // we abort testing, on the assumption that the app failed to start up
                    break;
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
