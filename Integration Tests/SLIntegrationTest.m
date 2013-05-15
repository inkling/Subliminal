//
//  SLIntegrationTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 1/31/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"
#import "SLTest+Internal.h"
#import "SLTestsViewController.h"
#import "SLTestViewController.h"

@implementation SLIntegrationTest

+ (NSString *)testCaseViewControllerClassName {
    NSAssert(NO, @"Concrete subclasses of %@ must override %@",
             NSStringFromClass([SLIntegrationTest class]), NSStringFromSelector(_cmd));    
    return nil;
}

- (void)setUpTest {
    NSString *test = NSStringFromClass([self class]);
    // strip focus prefixes from test cases if necessary,
    // to match the presentation in setUpTestCaseWithSelector:
    NSMutableSet *testCases = [NSMutableSet set];
    for (NSString *__strong testCase in [[self class] testCasesToRun]) {
        if ([testCase hasPrefix:SLTestFocusPrefix]) {
            testCase = [testCase substringFromIndex:[SLTestFocusPrefix length]];
        }
        [testCases addObject:testCase];
    }
    SLAskApp1(presentTestWithInfo:,
              (@{
                   SLTestNameKey:   test,
                   SLTestCasesKey:  testCases
               }));
    SLWaitUntilTrue([SLAskApp(currentTest) isEqualToString:test], 5.0,
                    @"App failed to present test %@.", test);
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    NSString *testCase = NSStringFromSelector(testCaseSelector);
    // strip focus prefix if necessary,
    // so that test case view controller doesn't have to handle the variant form
    if ([testCase hasPrefix:SLTestFocusPrefix]) {
        testCase = [testCase substringFromIndex:[SLTestFocusPrefix length]];
    }
    SLAskApp1(presentTestCaseWithInfo:,
              (@{
                   SLTestCaseKey: testCase,
                   SLTestCaseViewControllerClassNameKey: [[self class] testCaseViewControllerClassName]
               }));
    SLWaitUntilTrue([SLAskApp(currentTestCase) isEqualToString:testCase], 5.0,
                    @"App failed to present test case %@.", testCase);
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(dismissCurrentTestCase);
    SLWaitUntilTrue(!SLAskApp(currentTestCase), 5.0, @"App failed to dismiss current test case.");
}

- (void)tearDownTest {
    SLAskApp(dismissCurrentTest);
    SLWaitUntilTrue(!SLAskApp(currentTest), 5.0, @"App failed to dismiss current test.");
}

@end
