//
//  SLTestCase.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTest.h"
#import "SLTest+Internal.h"

#import "SLLogger.h"
#import "SLElement.h"

#import <objc/runtime.h>
#import <objc/message.h>


// all exceptions thrown by SLTest must have names beginning with this prefix
// so that they may be identified as "expected" throughout the testing framework
NSString *const SLTestExceptionNamePrefix       = @"SLTest";

NSString *const SLTestAssertionFailedException  = @"SLTestCaseAssertionFailedException";

NSString *const SLTestExceptionFilenameKey      = @"SLTestExceptionFilenameKey";
NSString *const SLTestExceptionLineNumberKey    = @"SLTestExceptionLineNumberKey";


@implementation SLTest {
    NSString *_lastKnownFilename;
    int _lastKnownLineNumber;
}

+ (NSSet *)allTests {
    NSMutableSet *tests = [[NSMutableSet alloc] init];
    
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
                [tests addObject:klass];
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

+ (BOOL)isAbstract {
    return ![[self testCases] count];
}

+ (BOOL)isFocused {    
    for (NSString *testCaseName in [self focusedTestCases]) {
        SEL testCaseSelector = NSSelectorFromString(testCaseName);
        if ([self testCaseWithSelectorSupportsCurrentPlatform:testCaseSelector]) return YES;
    }
    return NO;
}

+ (BOOL)isStartUpTest {
    return NO;
}

+ (BOOL)supportsCurrentPlatform {
    // examine whether this test or any of its superclasses are annotated
    // the "nearest" annotation determines support ("nearest" like with method overrides)
    BOOL testSupportsCurrentDevice = YES;
    UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    Class testClass = self;
    while (testClass != [SLTest class]) {
        NSString *testName = NSStringFromClass(testClass);
        if ([testName hasSuffix:@"_iPad"]) {
            testSupportsCurrentDevice = (userInterfaceIdiom == UIUserInterfaceIdiomPad);
            break;
        } else if ([testName hasSuffix:@"_iPhone"]) {
            testSupportsCurrentDevice = (userInterfaceIdiom == UIUserInterfaceIdiomPhone);
            break;
        }
        testClass = [testClass superclass];
    }

    return testSupportsCurrentDevice;
}

- (id)initWithTestController:(SLTestController *)testController {
    self = [super init];
    if (self) {
        _testController = testController;
    }
    return self;
}

- (void)setUpTest {
    // nothing to do here
}

- (void)tearDownTest {
    // nothing to do here
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    // nothing to do here
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    // nothing to do here
}

+ (NSArray *)testCases {
    static const void *const kTestCasesKey = &kTestCasesKey;
    NSArray *testCases = objc_getAssociatedObject(self, kTestCasesKey);
    if (!testCases) {
        static NSString *const kTestCaseNamePrefix = @"test";

        unsigned int methodCount;
        Method *methods = class_copyMethodList(self, &methodCount);
        NSMutableArray *selectorStrings = [NSMutableArray array];
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            char *methodReturnType = method_copyReturnType(method);
            NSString *selectorString = NSStringFromSelector(selector);

            // ignore the focus prefix for the purposes of aggregating all the test cases
            NSString *unfocusedTestCaseName = selectorString;
            NSRange rangeOfFocusPrefix = [selectorString rangeOfString:SLTestFocusPrefix];
            if (rangeOfFocusPrefix.location != NSNotFound) {
                unfocusedTestCaseName = [selectorString substringFromIndex:NSMaxRange(rangeOfFocusPrefix)];
            }

            if ([unfocusedTestCaseName hasPrefix:kTestCaseNamePrefix] &&
                methodReturnType && strlen(methodReturnType) > 0 && methodReturnType[0] == 'v' &&
                ![selectorString hasSuffix:@":"]) {
                // make sure to add the actual selector name including focus
                [selectorStrings addObject:selectorString];
            }
            
            if (methodReturnType) free(methodReturnType);
        }
        if (methods) free(methods);

        objc_setAssociatedObject(self, kTestCasesKey, selectorStrings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        testCases = selectorStrings;
    }
    return testCases;
}

+ (NSArray *)focusedTestCases {
    static const void *const kFocusedTestCasesKey = &kFocusedTestCasesKey;
    NSArray *focusedTestCases = objc_getAssociatedObject(self, kFocusedTestCasesKey);
    if (!focusedTestCases) {
        NSArray *testCases = [self testCases];
        
        // if our class' name (or the name of any superclass) is prefixed, all test cases are focused
        BOOL classIsFocused = NO;
        Class testClass = self;
        while (testClass != [SLTest class]) {
            if ([[NSStringFromClass(testClass) lowercaseString] hasPrefix:SLTestFocusPrefix]) {
                classIsFocused = YES;
                break;
            }
            testClass = [testClass superclass];
        }
        if (classIsFocused) {
            focusedTestCases = [testCases copy];

        // otherwise, only prefixed test cases are focused
        } else {
            NSMutableArray *filteredTestCases = [NSMutableArray arrayWithCapacity:[testCases count]];
            for (NSString *name in testCases) {
                if ([[name lowercaseString] hasPrefix:SLTestFocusPrefix]) {
                    [filteredTestCases addObject:name];
                }
            }
            focusedTestCases = [filteredTestCases copy];
        }
        objc_setAssociatedObject(self, kFocusedTestCasesKey, focusedTestCases, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return focusedTestCases;
}

+ (NSArray *)testCasesToRun {
    return (([[self class] isFocused]) ? [[self class] focusedTestCases] : [[self class] testCases]);
}

+ (BOOL)testCaseWithSelectorSupportsCurrentPlatform:(SEL)testCaseSelector {
    NSString *testCaseName = NSStringFromSelector(testCaseSelector);
    
    UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if ([testCaseName hasSuffix:@"_iPad"]) return (userInterfaceIdiom == UIUserInterfaceIdiomPad);
    if ([testCaseName hasSuffix:@"_iPhone"]) return (userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    return YES;
 }

- (NSUInteger)run:(NSUInteger *)numCasesExecuted {
    NSUInteger numberOfCasesExecuted = 0, numberOfCasesFailed = 0;

    NSException *setUpOrTearDownException = nil;
    @try {
        [self setUpTest];
    }
    @catch (NSException *e) {
        // save exception to throw after tearDownTest
        setUpOrTearDownException = [self exceptionByAddingFileInfo:e];
    }

    // if setUpTest failed, skip the test cases
    if (!setUpOrTearDownException) {
        NSString *test = NSStringFromClass([self class]);
        for (NSString *testCaseName in [[self class] testCasesToRun]) {
            // only run test case if it's appropriate for the current platform
            SEL testCaseSelector = NSSelectorFromString(testCaseName);
            if (![[self class] testCaseWithSelectorSupportsCurrentPlatform:testCaseSelector]) {
                continue;
            }

            [[SLLogger sharedLogger] logTest:test caseStart:testCaseName];

            BOOL caseFailed = NO;
            @try {            
                [self setUpTestCaseWithSelector:testCaseSelector];
                
                // We use objc_msgSend so that Clang won't complain about performSelector leaks
                ((void(*)(id, SEL))objc_msgSend)(self, testCaseSelector);
            }
            @catch (NSException *e) {
                // Catch all exceptions in test cases. If the app is in an inconsistent state then -tearDown: should abort completely.
                [self logException:e inTestCase:testCaseName];
                caseFailed = YES;
            }
            @finally {
                // tear-down test case last so that it always executes, regardless of earlier failures
                @try {
                    [self tearDownTestCaseWithSelector:testCaseSelector];
                }
                @catch (NSException *e) {
                    [self logException:e inTestCase:testCaseName];
                    caseFailed = YES;
                }

                if (caseFailed) {
                    [[SLLogger sharedLogger] logTest:test caseFail:testCaseName];
                    numberOfCasesFailed++;
                } else {
                    [[SLLogger sharedLogger] logTest:test casePass:testCaseName];
                }

                numberOfCasesExecuted++;
            }
        }
    }

    // still perform tearDownTest even if setUpTest failed
    @try {
        [self tearDownTest];
    }
    @catch (NSException *e) {
        // ignore the exception if we already failed during setUpTest
        if (!setUpOrTearDownException) {
            setUpOrTearDownException = [self exceptionByAddingFileInfo:e];
        }
    }

    // if setUpTest or tearDownTest failed, report their failure rather than returning normally
    if (setUpOrTearDownException) {
        @throw setUpOrTearDownException;
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
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
        userInfo[SLTestExceptionFilenameKey] = _lastKnownFilename;
        userInfo[SLTestExceptionLineNumberKey] = @(_lastKnownLineNumber);

        _lastKnownFilename = nil;
        _lastKnownLineNumber = 0;
        
        return [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    } else {
        return exception;
    }
}

- (void)logException:(NSException *)exception inTestCase:(NSString *)testCase {
    NSString *message = nil;
    // Exceptions thrown by SLTest or SLElement were likely expected
    // --with call site information recorded by an assertion or UIAElement macro--
    // and are logged more tersely than other exceptions.
    if ([[exception name] hasPrefix:SLTestExceptionNamePrefix] ||
        [[exception name] hasPrefix:SLElementExceptionNamePrefix]) {
        message = [NSString stringWithFormat:@"%@:%d: %@", _lastKnownFilename, _lastKnownLineNumber, [exception reason]];
    } else {
        message = [NSString stringWithFormat:@"Unexpected exception occurred ***%@*** for reason: %@",
                    [exception name], [exception reason]];
    }

    _lastKnownFilename = nil;
    _lastKnownLineNumber = 0;

    NSString *test = NSStringFromClass([self class]);
    [[SLLogger sharedLogger] logError:message test:test testCase:testCase];
}

@end

