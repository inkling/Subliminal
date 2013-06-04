//
//  SLTestViewController.h
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

#import <UIKit/UIKit.h>

/**
 An SLTestViewController displays a list of SLTest test cases in a plain-style 
 table view.
 
 It defines a number of hooks to be called by SLIntegrationTest subclasses, 
 allowing those tests to present and dismiss SLTestCaseViewControllers.
 */
@interface SLTestViewController : UITableViewController

#pragma mark - Initializing a Test View Controller
/// --------------------------------------------
/// @name Initializing a Test View Controller
/// --------------------------------------------

/**
 Returns a newly initialized view controller with the specified SLTest 
 subclass and test cases.
 
 This is the designated initializer for this class.
 
 @param test An SLTest subclass.
 @param testCases A set of SLTest test cases, represented as strings.
 @return A newly initialized SLTestViewController object.
 */
- (instancetype)initWithTest:(Class)test testCases:(NSSet *)testCases;

#pragma mark - SLIntegrationTest App Hooks
/// --------------------------------------------
/// @name SLIntegrationTest App Hooks
/// --------------------------------------------

/**
 Presents an SLTestCaseViewController initialized with the specified information.
 
 The dictionary provided should contain values for SLTestCaseKey and 
 SLTestCaseViewControllerClassNameKey. See above for descriptions of those keys.
 
 A test may wait on -currentTestCase becoming non-nil as a proxy for the 
 SLTestCaseViewController having been fully presented.
 
 @param testCaseInfo A dictionary providing the information necessary to initialize 
 an SLTestCaseViewController.
 */
- (void)presentTestCaseWithInfo:(NSDictionary *)testCaseInfo;

/**
 The name of the current test case.
 
 @return If an SLTestCaseViewController is currently presented, its test case's 
 name, otherwise nil.
 */
- (NSString *)currentTestCase;

/**
 Dismisses the current SLTestCaseViewController.
 
 A test may wait on -currentTestCase becoming nil as a proxy for 
 the SLTestCaseViewController having been fully dismissed.
 
 This is a no-op if no SLTestCaseViewController is currently presented.
 */
- (void)dismissCurrentTestCase;

@end


#pragma mark - Constants

/// The test case to present.
extern NSString *const SLTestCaseKey;
/// The name of the SLTestCaseViewController subclass to present for the test case.
extern NSString *const SLTestCaseViewControllerClassNameKey;
