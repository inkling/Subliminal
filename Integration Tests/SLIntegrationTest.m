//
//  SLIntegrationTest.m
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
    SLAssertTrueWithTimeout([SLAskApp(currentTest) isEqualToString:test], 5.0,
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
    SLAssertTrueWithTimeout([SLAskApp(currentTestCase) isEqualToString:testCase], 5.0,
                    @"App failed to present test case %@.", testCase);
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(dismissCurrentTestCase);
    SLAssertTrueWithTimeout(!SLAskApp(currentTestCase), 5.0, @"App failed to dismiss current test case.");
}

- (void)tearDownTest {
    SLAskApp(dismissCurrentTest);
    SLAssertTrueWithTimeout(!SLAskApp(currentTest), 5.0, @"App failed to dismiss current test.");
}

@end
