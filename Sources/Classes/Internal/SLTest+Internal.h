//
//  SLTest+Internal.h
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import "SLTest.h"

/**
 The methods in the `SLTest (Internal)` category are to be used only
 within Subliminal.
 */
@interface SLTest (Internal)

#pragma mark - Internal Methods
/// ----------------------------------------
/// @name Internal Methods
/// ----------------------------------------

/**
 All test cases defined on this test.

 A test case is a method beginning with "test", taking no arguments, returning `void`.

 @return All test cases defined on this test, represented as strings.
 */
+ (NSSet *)testCases;

/**
 All focused test cases defined on this test.
 
 A focused test case is a [test case](+testCases) whose name is prefixed with 
 `SLTestFocusPrefix`. If no test cases are thus "explicitly" focused,
 all test cases may be "implicitly" focused if the test itself (or any superclass) 
 is focused (by its name being prefixed with `SLTestFocusPrefix`). If the test itself
 is focused *and* some test cases are explicitly focused, only the explicitly 
 focused test cases will be considered focused. (The "narrowest" focus applies.)
 
 @return All focused test cases defined on this test, represented as strings.
 */
+ (NSSet *)focusedTestCases;

/**
 The test cases that will be run when this test is [run](runAndReportNumExecuted:failed:failedUnexpectedly:).

 @return The test cases returned by `+testCases`, or `+focusedTestCases` 
 (if this test is [focused](isFocused)), filtered to those test cases that 
 support the current platform. The test cases are represented as strings.
 */
+ (NSSet *)testCasesToRun;

/**
 Runs all test cases defined on the receiver's class,
 and reports statistics about their execution.
 
 See `SLTest (SLTestCase)` for a discussion of test case execution.
 
 @param numCasesExecuted If this is non-`NULL`, on return, this will be set to
 the number of test cases that were executed--which will be the number of test
 cases defined by the receiver's class.
 @param numCasesFailed If this is non-`NULL`, on return, this will be set to the
 number of test cases that failed (the number of test cases that threw exceptions).
 @param numCasesFailedUnexpectedly If this is non-`NULL`, on return, this will
 be set to the number of test cases that failed unexpectedly (those test cases
 that threw exceptions for other reasons than test assertion failures).
 
 @return `YES` if the test successfully finished (all test cases were executed, regardless of their individual
 success or failure), `NO` otherwise (an exception occurred in test case [set-up](-setUpTest) or [tear-down](-tearDownTest) ).
 
 @warning If an exception occurs in test case set-up, the test's cases will be skipped.
 Thus, the caller should use the values returned in `numCasesExecuted`, `numCasesFailed`,
 and `numCasesFailedUnexpectedly` if and only if this method returns `YES`.
 */
- (BOOL)runAndReportNumExecuted:(NSUInteger *)numCasesExecuted
                         failed:(NSUInteger *)numCasesFailed
             failedUnexpectedly:(NSUInteger *)numCasesFailedUnexpectedly;

@end


/// The string to use to prefix test class names and test case names in order to focus them.
/// It does not matter if the prefix is capitalized.
static NSString *const SLTestFocusPrefix = @"focus_";
