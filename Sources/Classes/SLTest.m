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

+ (BOOL)supportsCurrentPlatform {
    return YES;
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
            UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
            BOOL hasIPadSuffix = [selectorString hasSuffix:@"_iPad"];
            BOOL hasIPhoneSuffix = [selectorString hasSuffix:@"_iPhone"];
            if ((userInterfaceIdiom == UIUserInterfaceIdiomPad && hasIPadSuffix) ||
                (userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasIPhoneSuffix) ||
                (!hasIPadSuffix && !hasIPhoneSuffix)) {
                [selectorStrings addObject:selectorString];
            }
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
        }
        @catch (NSException *e) {
            // Catch all exceptions in test cases. If the app is in an inconsistent state then -tearDown: should abort completely.
            [self logException:e inTestCase:testSelectorString];
            caseFailed = YES;
        }
        @finally {
            // tear-down test case last so that it always executes, regardless of earlier failures
            @try {
                [self tearDownTestCaseWithSelector:testSelector];
            }
            @catch (NSException *e) {
                [self logException:e inTestCase:testSelectorString];
                caseFailed = YES;
            }

            if (caseFailed) {
                [[SLLogger sharedLogger] logTest:test caseFail:testSelectorString];
                numberOfCasesFailed++;
            } else {
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

- (void)recordLastKnownFile:(char *)filename line:(int)lineNumber {
    _lastKnownFilename = [@(filename) lastPathComponent];
    _lastKnownLineNumber = lineNumber;
}

- (NSException *)exceptionByAddingFileInfo:(NSException *)exception {
    if (_lastKnownFilename) {
        // If there is file information, insert it into the userInfo dictionary
        NSMutableDictionary *userInfo = [[exception userInfo] mutableCopy];
        if (!userInfo) {
            userInfo = [NSMutableDictionary dictionary];
        }
        userInfo[SLTestExceptionFilenameKey] = _lastKnownFilename;
        userInfo[SLTestExceptionLineNumberKey] = @(_lastKnownLineNumber);
        
        return [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    } else {
        return exception;
    }
}

- (void)logException:(NSException *)exception inTestCase:(NSString *)testCase {
    NSString *message = nil;
    // "Expected" exceptions (failures in assertions or UIAccessibilityElement lookup)
    // are logged more tersely than other exceptions.
    if ([[exception name] isEqualToString:SLTestAssertionFailedException] ||
        [[exception name] isEqualToString:SLInvalidElementException]) {
        message = [NSString stringWithFormat:@"%@:%d: %@", _lastKnownFilename, _lastKnownLineNumber, [exception reason]];
    } else {
        message = [NSString stringWithFormat:@"%@:%d: Exception occurred ***%@*** for reason: %@",
                    _lastKnownFilename, _lastKnownLineNumber, [exception name], [exception reason]];
    }

    _lastKnownFilename = nil;
    _lastKnownLineNumber = 0;

    NSString *test = NSStringFromClass([self class]);
    [[SLLogger sharedLogger] logError:message test:test testCase:testCase];
}

@end

