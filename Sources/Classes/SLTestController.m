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


static const NSTimeInterval kDefaultTimeout = 5.0;


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
                if (fileName) {
                    [[SLLogger sharedLogger] logException:@"%@:%d: Exception occurred: **%@** for reason: %@", fileName, lineNumber, [e name], [e reason]];
                } else {
                    [[SLLogger sharedLogger] logException:@"Exception occurred: **%@** for reason: %@", [e name], [e reason]];
                }
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
}

@end
