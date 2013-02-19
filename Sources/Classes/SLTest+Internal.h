//
//  SLTest+Internal.h
//  Subliminal
//
//  Created by Jeffrey Wear on 2/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTest.h"

/// The string to use to prefix test class names and test case names in order to focus them.
static NSString *const SLTestFocusPrefix = @"focus_";

@interface SLTest (Internal)

/**
 All test cases defined on this test.

 A test case is a method beginning with "test", taking no arguments, returning void.

 @return All test cases defined on this test, represented as strings.
 */
+ (NSArray *)testCases;

/**
 All focused test cases defined on this test.
 
 A focused test case is a [test case](testCases) whose name is prefixed with 
 SLTestFocusPrefix.
 
 @return All focused test cases defined on this test, represented as strings.
 */
+ (NSArray *)focusedTestCases;

/**
 The test cases that will be run when this test is [run](run:).

 @return testCases, unless this test is [focused](isFocused),
 in which case this method returns focusedTestCases.
 The test cases are represented as strings.
 */
+ (NSArray *)testCasesToRun;

@end
