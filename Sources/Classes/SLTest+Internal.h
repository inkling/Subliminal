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
+ (NSSet *)testCases;

/**
 All focused test cases defined on this test.
 
 A focused test case is a [test case](testCases) whose name is prefixed with 
 SLTestFocusPrefix.
 
 @return All focused test cases defined on this test, represented as strings.
 */
+ (NSSet *)focusedTestCases;

/**
 The test cases that will be run when this test is [run](run:).

 @return testCases, or focusedTestCases (if this test is [focused](isFocused)),
 filtered to those test cases that support the current platform.
 The test cases are represented as strings.
 */
+ (NSSet *)testCasesToRun;

@end
