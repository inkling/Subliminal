//
//  SLTestViewController.h
//  Subliminal
//
//  Created by Jeffrey Wear on 2/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

/// The test case to present.
extern NSString *const SLTestCaseKey;
/// The name of the SLTestCaseViewController subclass to present for the test case.
extern NSString *const SLTestCaseViewControllerClassNameKey;

/**
 An SLTestViewController displays a list of SLTest test cases in a plain-style 
 table view.
 
 It defines a number of hooks to be called by SLIntegrationTest subclasses, 
 allowing those tests to present and dismiss SLTestCaseViewControllers.
 */
@interface SLTestViewController : UITableViewController

/**
 Returns a newly initialized view controller with the specified SLTest 
 subclass and test cases.
 
 This is the designated initializer for this class.
 
 @param test An SLTest subclass.
 @param testCases A list of SLTest test cases, represented as strings.
 @return A newly initialized SLTestViewController object.
 */
- (instancetype)initWithTest:(Class)test testCases:(NSArray *)testCases;

///
/// @name SLIntegrationTest app hooks
///

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
