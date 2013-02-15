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
    SLAskApp1(presentTestWithInfo:,
              (@{
                   SLTestNameKey:   test,
                   SLTestCasesKey:  [[self class] testCasesToRun]
               }));
    SLWaitUntilTrue([SLAskApp(currentTest) isEqualToString:test], 5.0,
                    @"App failed to present test %@.", test);
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    NSString *testCase = NSStringFromSelector(testSelector);
    SLAskApp1(presentTestCaseWithInfo:,
              (@{
                   SLTestCaseKey: testCase,
                   SLTestCaseViewControllerClassNameKey: [[self class] testCaseViewControllerClassName]
               }));
    SLWaitUntilTrue([SLAskApp(currentTestCase) isEqualToString:testCase], 5.0,
                    @"App failed to present test case %@.", testCase);
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    SLAskApp(dismissCurrentTestCase);
    SLWaitUntilTrue(!SLAskApp(currentTestCase), 5.0, @"App failed to dismiss current test case.");
}

- (void)tearDownTest {
    SLAskApp(dismissCurrentTest);
    SLWaitUntilTrue(!SLAskApp(currentTest), 5.0, @"App failed to dismiss current test.");
}

@end
