//
//  SLTestController.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SLTestController.h"
#import "SLTestController+Internal.h"

#import "SLLogger.h"
#import "SLTest.h"
#import "SLTerminal.h"
#import "SLElement.h"
#import "SLAlert.h"

#import "SLStringUtilities.h"

#import <objc/runtime.h>


static NSUncaughtExceptionHandler *appsUncaughtExceptionHandler = NULL;
static const NSTimeInterval kDefaultTimeout = 5.0;

/// Uncaught exceptions are logged to Subliminal for visibility.
static void SLUncaughtExceptionHandler(NSException *exception)
{
    NSString *exceptionMessage = [NSString stringWithFormat:@"Uncaught exception occurred: ***%@*** for reason: %@", [exception name], [exception reason]];
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


@interface SLTestController () <UIAlertViewDelegate>
@end

@implementation SLTestController {
    dispatch_queue_t _runQueue;
    BOOL _runningWithFocus;
    NSSet *_testsToRun;
    NSUInteger _numTestsExecuted, _numTestsFailed;
    void(^_completionBlock)(void);

    dispatch_semaphore_t _startTestingSemaphore;
    BOOL _shouldWaitToStartTesting;
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
+ (instancetype)sharedTestController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedController = [[SLTestController alloc] init];
    });
    return __sharedController;
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
        NSString *runQueueName = [NSString stringWithFormat:@"com.inkling.subliminal.SLTestController-%p.runQueue", self];
        _runQueue = dispatch_queue_create([runQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
        _defaultTimeout = kDefaultTimeout;
        _startTestingSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_runQueue);
    dispatch_release(_startTestingSemaphore);
}

- (BOOL)shouldWaitToStartTesting {
    return _shouldWaitToStartTesting;
}

- (void)setShouldWaitToStartTesting:(BOOL)shouldWaitToStartTesting {
    if (shouldWaitToStartTesting != _shouldWaitToStartTesting) {
        _shouldWaitToStartTesting = shouldWaitToStartTesting;
    }
}

// Having the Accessibility Inspector enabled while tests are running
// can cause problems with touch handling and/or prevent UIAutomation's alert
// handler from being called.
//
// The Accessibility Inspector shouldn't affect unit tests, though (and the
// user directory path will be different in unit tests than when the application is running).
- (void)warnIfAccessibilityInspectorIsEnabled {
#if TARGET_IPHONE_SIMULATOR
    // To use a preprocessor macro here, we'd have to specially build Subliminal
    // when unit testing, e.g. using a "Unit Testing" build configuration
    if (getenv("SL_UNIT_TESTING")) return;

    // We detect if the Inspector is enabled by examining the simulator's Accessibility preferences
    // 1. get into the simulator's app support directory by fetching the sandboxed Library's path
    NSString *userDirectoryPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] path];

    // 2. get out of our application directory, back to the root support directory for this system version
    NSString *plistRootPath = [userDirectoryPath substringToIndex:([userDirectoryPath rangeOfString:@"Applications"].location)];
    
    // 3. locate, relative to here, the Accessibility preferences
    NSString *relativePlistPath = @"Library/Preferences/com.apple.Accessibility.plist";
    NSString *plistPath = [plistRootPath stringByAppendingPathComponent:relativePlistPath];

    // 4. Check whether the Inspector is enabled
    NSDictionary *accessibilityPreferences = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if ([accessibilityPreferences[@"AXInspectorEnabled"] boolValue]) {
        [[SLLogger sharedLogger] logWarning:@"The Accessibility Inspector is enabled. Tests may not run as expected."];
    }
#endif
}

- (void)_beginTesting {
    appsUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&SLUncaughtExceptionHandler);

    SLLog(@"Tests are starting up... ");

    // we use a local element resolution timeout
    // and suppress UIAutomation's timeout, to better control the timing of the tests
    [SLUIAElement setDefaultTimeout:_defaultTimeout];
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIATarget.localTarget().setTimeout(0);"];

    [SLAlertHandler loadUIAAlertHandling];

#if DEBUG
    if (self.shouldWaitToStartTesting) {
        static NSString *const kWaitToStartTestingAlertTitle = @"Waiting to start testing...";

        SLAlert *waitToStartTestingAlert = [SLAlert alertWithTitle:kWaitToStartTestingAlertTitle];
        [SLAlertHandler addHandler:[waitToStartTestingAlert dismissByUser]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:kWaitToStartTestingAlertTitle
                                        message:@"You can attach the debugger now."
                                       delegate:self
                              cancelButtonTitle:@"Continue"
                              otherButtonTitles:nil] show];
        });
        dispatch_semaphore_wait(_startTestingSemaphore, DISPATCH_TIME_FOREVER);
    }
#endif

    if (_runningWithFocus) {
        SLLog(@"Focusing on test cases in specific tests: %@.", [[_testsToRun allObjects] componentsJoinedByString:@","]);
    }

    [self warnIfAccessibilityInspectorIsEnabled];

    [[SLLogger sharedLogger] logTestingStart];
}

- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock {
    dispatch_async(_runQueue, ^{
        _completionBlock = completionBlock;

        _testsToRun = [[self class] testsToRun:tests withFocus:&_runningWithFocus];
        if (![_testsToRun count]) {
            SLLog(@"%@%@%@", @"There are no tests to run", (_runningWithFocus) ? @": no tests are focused" : @"", @".");
            [self _finishTesting];
            return;
        }

        [self _beginTesting];

        for (Class testClass in _testsToRun) {
            @autoreleasepool {
                SLTest *test = (SLTest *)[[testClass alloc] init];

                NSString *testName = NSStringFromClass(testClass);
                [[SLLogger sharedLogger] logTestStart:testName];

                @try {
                    NSUInteger numCasesExecuted = 0, numCasesFailed = 0, numCasesFailedUnexpectedly = 0;

                    [test runAndReportNumExecuted:&numCasesExecuted
                                           failed:&numCasesFailed
                               failedUnexpectedly:&numCasesFailedUnexpectedly];

                    [[SLLogger sharedLogger] logTestFinish:testName
                                      withNumCasesExecuted:numCasesExecuted
                                            numCasesFailed:numCasesFailed
                                numCasesFailedUnexpectedly:numCasesFailedUnexpectedly];
                    if (numCasesFailed > 0) _numTestsFailed++;
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
                    _numTestsFailed++;
                }
                _numTestsExecuted++;
            }
        }

        [self _finishTesting];
    });
}

- (void)_finishTesting {
    [[SLLogger sharedLogger] logTestingFinishWithNumTestsExecuted:_numTestsExecuted
                                                   numTestsFailed:_numTestsFailed];

    if (_runningWithFocus) {
        [[SLLogger sharedLogger] logWarning:@"This was a focused run. Fewer test cases may have run than normal."];
    }

    if (_completionBlock) dispatch_sync(dispatch_get_main_queue(), _completionBlock);

    // NOTE: Everything below the next line will not execute when running
    // from the command line, because the UIAutomation script will terminate,
    // and then the app.
    //
    // When running with the Instruments GUI, the script will terminate,
    // but the app will remain open and Instruments will keep recording
    // --the developer must explicitly stop recording to terminate the app.
    [[SLTerminal sharedTerminal] shutDown];

    // clear controller state (important when testing Subliminal, when the controller will test repeatedly)
    _numTestsExecuted = 0;
    _numTestsFailed = 0;
    _runningWithFocus = NO;
    _testsToRun = nil;
    _completionBlock = nil;

    // deregister Subliminal's exception handler
    // this is important when unit testing Subliminal, so that successive Subliminal testing runs
    // don't treat Subliminal's handler as the app's handler,
    // which would cause Subliminal's handler to recurse (as it calls the app's handler)
    NSSetUncaughtExceptionHandler(appsUncaughtExceptionHandler);
}


#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    dispatch_semaphore_signal(_startTestingSemaphore);
}

@end
