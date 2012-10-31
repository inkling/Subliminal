//
//  SLTestCase.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTest.h"

#import "SLLogger.h"
#import "SLElement.h"

#import <objc/runtime.h>
#import <objc/message.h>


NSString *const SLTestAssertionFailedException = @"SLTestCaseAssertionFailedException";

NSString *const SLTestExceptionFilenameKey = @"SLExceptionFilenameKey";
NSString *const SLTestExceptionLineNumberKey = @"SLExceptionLineNumberKey";


@implementation SLTest {
    NSString *_lastKnownFilename;
    int _lastKnownLineNumber;
}

+ (NSArray *)allTests {
    NSMutableArray *tests = [[NSMutableArray alloc] init];
    
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        objc_getClassList(classes, numClasses);
        
        for (int i = 0; i < numClasses; i++) {
            Class klass = classes[i];
            Class metaClass = object_getClass(klass);
            // Class methods are defined on the metaclass
            if (class_respondsToSelector(metaClass, @selector(isSubclassOfClass:)) &&
                [klass isSubclassOfClass:[SLTest class]]) {
                // Add all SLTests except SLTest itself
                if (klass != [SLTest class]) [tests addObject:klass];
            }
        }
        
        free(classes);
    }
    
    return tests;
}

+ (Class)testNamed:(NSString *)test {
    Class klass = NSClassFromString(test);
    BOOL classIsTestClass = (class_respondsToSelector(object_getClass(klass), @selector(isSubclassOfClass:)) &&
                             [klass isSubclassOfClass:[SLTest class]]);
    return (classIsTestClass ? klass : nil);
}

+ (BOOL)isStartUpTest {
    return NO;
}

- (id)initWithTestController:(SLTestController *)testController {
    self = [super init];
    if (self) {
        _testController = testController;
    }
    return self;
}

- (void)setUp {
    // nothing to do here
}

- (void)tearDown {
    // nothing to do here
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    // nothing to do here
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    // nothing to do here
}

- (NSUInteger)run:(NSUInteger *)numCasesExecuted {
    // Run all methods beginning with "test" and taking no arguments
    static NSString *const kSelectorPrefix = @"test";
    
    unsigned int methodCount;
    Method *methods = class_copyMethodList([self class], &methodCount);
    NSMutableArray *selectorStrings = [NSMutableArray array];
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *selectorString = NSStringFromSelector(selector);
        if ([selectorString hasPrefix:kSelectorPrefix] &&
            ![selectorString hasSuffix:@":"]) {
            [selectorStrings addObject:selectorString];
        }
    }
    if (methods) free(methods);

    @try {
        [self setUp];
    }
    @catch (NSException *e) {
        // Abort if the test failed during setup
        @throw [self exceptionByAddingFileInfo:e];
    }

    NSString *test = NSStringFromClass([self class]);
    NSUInteger numberOfCasesExecuted = 0, numberOfCasesFailed = 0;
    for (NSString *testSelectorString in selectorStrings) {
        [[SLLogger sharedLogger] logTest:test caseStart:testSelectorString];
        SEL testSelector = NSSelectorFromString(testSelectorString);

        BOOL caseFailed = NO;
        @try {            
            [self setUpTestCaseWithSelector:testSelector];
            
            // We use objc_msgSend so that Clang won't complain about performSelector leaks
            ((void(*)(id, SEL))objc_msgSend)(self, testSelector);

            [self tearDownTestCaseWithSelector:testSelector];
        }
        @catch (NSException *e) {
            // Catch all exceptions in test cases. If the app is in an inconsistent state then -tearDown: should abort completely.
            if ([[e name] isEqualToString:SLTestAssertionFailedException]) {
                [[SLLogger sharedLogger] logException:@"%@:%d: %@", _lastKnownFilename, _lastKnownLineNumber, [e reason]];
            } else {
                [[SLLogger sharedLogger] logException:@"%@:%d: Exception occurred ***%@*** for reason: %@", _lastKnownFilename, _lastKnownLineNumber, [e name], [e reason]];
            }
            [[SLLogger sharedLogger] logTest:test caseFail:testSelectorString];
            
            _lastKnownFilename = nil;
            _lastKnownLineNumber = 0;
            
            caseFailed = YES;
            numberOfCasesFailed++;
        }
        @finally {
            if (!caseFailed) {
                [[SLLogger sharedLogger] logTest:test casePass:testSelectorString];
            }
                        
            numberOfCasesExecuted++;
        }
    }

    @try {
        [self tearDown];
    }
    @catch (NSException *e) {
        // Abort if the test failed during teardown
        @throw [self exceptionByAddingFileInfo:e];
    }

    if (numCasesExecuted) *numCasesExecuted = numberOfCasesExecuted;
    return numberOfCasesFailed;
}

- (void)wait:(NSTimeInterval)interval {
    [NSThread sleepForTimeInterval:interval];
}

- (void)failWithException:(NSException *)exception {
    [exception raise];
}

- (void)recordLastKnownFile:(char *)filename line:(int)lineNumber {
    _lastKnownFilename = [@(filename) lastPathComponent];
    _lastKnownLineNumber = lineNumber;
}

- (NSException *)exceptionByAddingFileInfo:(NSException *)exception {
    NSMutableDictionary *userInfo = [[exception userInfo] mutableCopy];
    userInfo[SLTestExceptionFilenameKey] = _lastKnownFilename;
    userInfo[SLTestExceptionLineNumberKey] = @(_lastKnownLineNumber);
    
    return [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
}

@end


@implementation NSException (SLTestException)

+ (NSException *)testFailureInFile:(char *)filename atLine:(int)lineNumber reason:(NSString *)failureReason, ... {
    va_list(args);
    va_start(args, failureReason);
    NSString *reason = [[NSString alloc] initWithFormat:failureReason arguments:args];
    va_end(args);
    
    NSDictionary *userInfo = @{ SLTestExceptionFilenameKey : @(filename), SLTestExceptionLineNumberKey : @(lineNumber) };
    
    return [NSException exceptionWithName:SLTestAssertionFailedException reason:reason userInfo:userInfo];
}

@end
