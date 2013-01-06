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

@implementation SLTestController

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
    
    [[SLLogger sharedLogger] logTestingStart];
}

- (void)runTests:(NSArray *)tests {
    dispatch_async([[self class] runQueue], ^{
        NSAssert([SLLogger sharedLogger], @"SLTestController cannot run tests without a logger.");
        
        [self _beginTesting];

        // search for startup test
        __block NSUInteger startupTestIndex = NSNotFound;
        [tests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isStartUpTest]) {
                startupTestIndex = idx;
                *stop = YES;
            }
        }];
        // ensure we'll execute startup test first if present
        NSMutableArray *sortedTests = [NSMutableArray arrayWithArray:tests];
        if (startupTestIndex != NSNotFound) {
            id startupTestClass = [sortedTests objectAtIndex:startupTestIndex];
            [sortedTests removeObjectAtIndex:startupTestIndex];
            [sortedTests insertObject:startupTestClass atIndex:0];
        }
        
        for (Class testClass in sortedTests) {
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
                NSString *message = nil;
                if (fileName) {
                    message = [NSString stringWithFormat:@"%@:%d: Exception occurred: **%@** for reason: %@", fileName, lineNumber, [e name], [e reason]];
                } else {
                    message =[NSString stringWithFormat:@"Exception occurred: **%@** for reason: %@", [e name], [e reason]];
                }
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
    [[SLLogger sharedLogger] logTestingFinish];
    [[SLTerminal sharedTerminal] eval:@"_testingHasFinished = true;"];

    // set exception handler back to the app's handler, if there was one
    // this is important when unit testing Subliminal, so that successive Subliminal testing runs
    // don't treat Subliminal's handler as the app's handler,
    // which would cause Subliminal's handler to recurse (as it calls the app's handler)
    if (appsUncaughtExceptionHandler) NSSetUncaughtExceptionHandler(appsUncaughtExceptionHandler);
}

@end
