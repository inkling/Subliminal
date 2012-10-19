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
    NSString *_lastUIAMessageSendFilename;
    int _lastUIAMessageSendLineNumber;
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

- (id)initWithLogger:(SLLogger *)logger testController:(SLTestController *)testController {
    self = [super init];
    if (self) {
        _logger = logger;
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

    @try {
        [self setUp];
    }
    @catch (NSException *e) {
        // if the exception is due to UIAElement access,
        // attach our cached location information to the exception
        if ([[e name] hasPrefix:SLElementExceptionPrefix]) {
            e = [e exceptionAnnotatedWithLineNumber:_lastUIAMessageSendLineNumber
                                             inFile:(char *)[_lastUIAMessageSendFilename UTF8String]];
            // not necessary to clear the cache because we're aborting
        }
        // rethrow, for logging by test controller
        @throw e;
    }

    NSString *test = NSStringFromClass([self class]);
    NSUInteger numberOfCasesExecuted = 0, numberOfCasesFailed = 0;
    for (NSString *testSelectorString in selectorStrings) {
        [self.logger logTest:test caseStart:testSelectorString];
        SEL testSelector = NSSelectorFromString(testSelectorString);

        BOOL caseFailed = NO;
        @try {            
            [self setUpTestCaseWithSelector:testSelector];
            
            // We use objc_msgSend so that Clang won't complain about performSelector leaks
            objc_msgSend(self, testSelector);

            [self tearDownTestCaseWithSelector:testSelector];
        }
        @catch (NSException *e) {
            // attempt to recover information about the site of the exception
            NSString *fileName = nil;
            int lineNumber = 0;
            if ([[e name] hasPrefix:SLElementExceptionPrefix]) {
                fileName = _lastUIAMessageSendFilename;
                _lastUIAMessageSendFilename = nil;
                
                lineNumber = _lastUIAMessageSendLineNumber;
                _lastUIAMessageSendLineNumber = 0;
            } else {
                fileName = [[e userInfo] objectForKey:SLTestExceptionFilenameKey];
                lineNumber = [[[e userInfo] objectForKey:SLTestExceptionLineNumberKey] intValue];
            }
            
            // log the exceptions differently according to whether they were "expected" (i.e. assertions) or not
            if ([[e name] isEqualToString:SLTestAssertionFailedException]) {
                [self.logger logException:@"%@:%d: %@",
                                            fileName, lineNumber, [e reason]];
                [self.logger logTest:test caseFail:testSelectorString];
            } else {
                if (fileName) {
                    [self.logger logException:@"%@:%d: Exception occurred: **%@** for reason: %@",
                                                fileName, lineNumber, [e name], [e reason]];
                } else {
                    [self.logger logException:@"Exception occurred: **%@** for reason: %@",
                                                [e name], [e reason]];
                }
                [self.logger logTest:test caseAbort:testSelectorString];
            }
            
            caseFailed = YES;
            numberOfCasesFailed++;
        }
        @finally {
            if (!caseFailed) {
                [self.logger logTest:test casePass:testSelectorString];
            }
                        
            numberOfCasesExecuted++;
        }
    }

    @try {
        [self tearDown];
    }
    @catch (NSException *e) {
        // if the exception is due to UIAElement access,
        // attach our cached location information to the exception
        if ([[e name] hasPrefix:SLElementExceptionPrefix]) {
            e = [e exceptionAnnotatedWithLineNumber:_lastUIAMessageSendLineNumber
                                             inFile:(char *)[_lastUIAMessageSendFilename UTF8String]];
            // not necessary to clear the cache because we're aborting
        }
        // rethrow, for logging by test controller
        @throw e;
    }

    if (numCasesExecuted) *numCasesExecuted = numberOfCasesExecuted;
    return numberOfCasesFailed;
}

- (void)failWithException:(NSException *)exception {
    [exception raise];
}

- (void)recordLastUIAMessageSendInFile:(char *)fileName atLine:(int)lineNumber {
    _lastUIAMessageSendFilename = [@(fileName) lastPathComponent];
    _lastUIAMessageSendLineNumber = lineNumber;
}

@end


@implementation NSException (SLTestException)

+ (NSException *)testFailureInFile:(char *)fileName atLine:(int)lineNumber reason:(NSString *)failureReason, ... {
    NSException *exception = [NSException exceptionWithName:SLTestAssertionFailedException
                                                     reason:SLStringWithFormatAfter(failureReason)
                                                   userInfo:nil];
    return [exception exceptionAnnotatedWithLineNumber:lineNumber inFile:fileName];
}

- (NSException *)exceptionAnnotatedWithLineNumber:(int)lineNumber inFile:(char *)fileName {
    NSMutableDictionary *extendedUserInfo = [NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
    [extendedUserInfo setObject:[@(fileName) lastPathComponent] forKey:SLTestExceptionFilenameKey];
    [extendedUserInfo setObject:@(lineNumber) forKey:SLTestExceptionLineNumberKey];
    
    return [NSException exceptionWithName:[self name] reason:[self reason] userInfo:extendedUserInfo];
}

@end
