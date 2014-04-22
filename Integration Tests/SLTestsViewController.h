//
//  SLTestsViewController.h
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

#import <UIKit/UIKit.h>


/**
 An SLTestsViewController displays a list of SLTest subclasses 
 in a plain-style table view.
 
 It defines a number of hooks to be called by SLIntegrationTest subclasses,
 allowing those tests to present and dismiss SLTestViewControllers.
 */
@interface SLTestsViewController : UITableViewController

#pragma mark - Initializing a Tests View Controller
/// ---------------------------------------------
/// @name Initializing a Tests View Controller
/// ---------------------------------------------

/**
 Returns a newly initialized view controller with the specified tests.
 
 This is the designated initializer for this class.

 @param tests An array of SLTest subclasses.
 @return A newly initialized SLTestsViewController object.
 */
- (instancetype)initWithTests:(NSArray *)tests;

#pragma mark - SLIntegrationTest App Hooks
/// ------------------------------------
/// @name SLIntegrationTest App Hooks
/// ------------------------------------

/**
 Presents an SLTestViewController initialized with the specified information.
 
 The dictionary provided should contain values for SLTestNameKey and SLTestCasesKey. 
 See above for descriptions of those keys.
 
 A test may wait on -currentTest becoming non-nil as a proxy for 
 the SLTestViewController having been fully presented.

 @param testInfo A dictionary providing the information necessary to initialize 
 an SLTestViewController.
 */
- (void)presentTestWithInfo:(NSDictionary *)testInfo;

/**
 The name of the current test.
 
 @return If an SLTestViewController is currently presented, its test's name,
 otherwise nil.
 */
- (NSString *)currentTest;

/**
 Dismisses the current SLTestViewController.
 
 A test may wait on -currentTest becoming nil as a proxy for
 the SLTestViewController having been fully dismissed.
 
 This is a no-op if no SLTestViewController is currently presented.
 */
- (void)dismissCurrentTest;

@end


#pragma mark - Constants

/// The name of an SLTest subclass to present.
extern NSString *const SLTestNameKey;
/// An NSSet * containing the NSString * test cases of the above subclass
/// that will be executed by Subliminal.
extern NSString *const SLTestCasesKey;
