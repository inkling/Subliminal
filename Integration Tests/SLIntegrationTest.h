//
//  SLIntegrationTest.h
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

#import <Subliminal/Subliminal.h>

/**
 SLIntegrationTest is the abstract base class of any integration test
 written against Subliminal itself.

 Each concrete SLIntegrationTest subclass is accompanied by a SLTestCaseViewController
 subclass that defines the interface to be exercised by the test's cases.
 SLIntegrationTest presents an instance of that view controller class before 
 each test case and dismisses it after that case executes.
 
 Subclasses must make sure to call super at the start of their implementations 
 of -setUpTest and -setUpTestCaseWithSelector:. Subclasses must make sure to 
 call super at the _end_ of their implementations of -tearDownTest and
 -tearDownTestCaseWithSelector:.

 To write a new integration test against Subliminal:

     1. Create the view(s) that will be exercised by your test's cases,
     by creating a subclass of SLTestCaseViewController. 
     See SLTestCaseViewController for more details.
     2. Create a new SLIntegrationTest subclass, making sure to return the
     name of that SLTestCaseViewController class from -testCaseViewControllerClassName.
     3. Fill out your test's cases.

 */
@interface SLIntegrationTest : SLTest

/**
 The name of the view controller class which defines the interface
 to be exercised by this test's cases.
 
 Before Subliminal executes each test case, it initializes a fresh instance
 of this class [with the test case](-[SLTestCaseViewController initWithTestCaseWithSelector:]) 
 and pushes it onto the target's navigation stack.
 
 @return The name of the SLTestCaseViewController subclass whose view 
 contains the elements to be exercised by this test's cases.
 */
+ (NSString *)testCaseViewControllerClassName;

@end
