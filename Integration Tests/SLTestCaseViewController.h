//
//  SLTestCaseViewController.h
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
 SLTestCaseViewController is an abstract base class whose concrete subclasses 
 define the user interfaces exercised by [Subliminal's integration tests](SLIntegrationTest).
 
 Each concrete SLTestCaseViewController subclass accompanies a subclass of 
 SLIntegrationTest, as [specified by](+[SLIntegrationTest testCaseViewControllerClassName]) 
 that test class. Before Subliminal executes each of that test's cases, 
 an instance of the corresponding SLTestCaseViewController subclass 
 will be initialized with that case and pushed onto the target's navigation stack.
 
 For each case of the corresponding test, a SLTestCaseViewController subclass 
 must either define a view [in a nib](+nibNameForTestCase:) or
 [programmatically](-loadViewForTestCase:).
 */
@interface SLTestCaseViewController : UIViewController

/**
 The test case with which this object was initialized.
 */
@property (nonatomic, readonly) SEL testCase;

/**
 The name of the nib file to associate with a view controller 
 initialized with the specified test case.
 
 The nib should be located in the main bundle.

 The value returned by this method will be used to initialize the view controller 
 (i.e. using -[UIView initWithNibName:bundle:]). For a given test case, 
 this method may return nil, so long as -loadViewForTestCase: loads a view
 for the test case.
 
 The default implementation of this method returns nil.

 @param testCase A case of the SLIntegrationTest corresponding to this class.
 @return The name of the nib file to associate with a view controller initialized 
 with the specified test case, or nil, if instances of this class should use 
 programmatically-created views for the specified test case.
 */
+ (NSString *)nibNameForTestCase:(SEL)testCase;

/**
 Creates the view that the controller, initialized with the specified
 test case, manages.
 
 The view controller calls this method when its [view](-[UIView view]) property
 is requested but is currently nil, if and only if this class returns `nil` from
 +nibNameForTestCase: for the specified test case.
 
 This method should create a view hierarchy and then assign the root view 
 of the hierarchy to the [view](-[UIView view]) property.
 
 Subclasses can use the methods in the `ConvenienceViews` category
 to load views for standard test scenarios.

 The default implementation of this method is a no-op.
 
 @param testCase A case of the SLIntegrationTest corresponding to this class.
 */
- (void)loadViewForTestCase:(SEL)testCase;

/**
 Returns a newly initialized view controller with the specified test case.
 
 This is the designated initializer for this class. The default implementation 
 calls +nibNameForTestCase: and uses the value returned to initialize the instance.

 @param testCase A case of the SLIntegrationTest corresponding to this class, 
 for which this view controller will be used to present an appropriate user interface.
 @return A newly initialized SLTestCaseViewController object.
 */
- (instancetype)initWithTestCaseWithSelector:(SEL)testCase;

@end


/**
 The methods in the `SLTestCaseViewController (ConvenienceViews)` category
 may be used to load views for certain standard test scenarios.
 
 A subclass of `SLTestCaseViewController` would call one of these methods
 from within its implementation of `-loadViewForTestCase:`.
 */
@interface SLTestCaseViewController (ConvenienceViews)

/**
 Creates a generic view.
 
 This method is to be used by test controllers that don't need to
 display any particular interface, perhaps because they're testing
 a system modal view/view controller presented in front of their view
 or because they're testing some aspect of Subliminal unrelated to their view.
 */
- (void)loadGenericView;

@end
