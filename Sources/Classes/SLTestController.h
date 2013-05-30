//
//  SLTestController.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 `SLTestController` coordinates test execution. Its singleton instance
 is the primary interface between the application and the tests.
 */
@interface SLTestController : NSObject

/// -------------------------------------------
/// @name Configuring the Default Timeout
/// -------------------------------------------

/**
 Subliminal's timeout.
 
 Various classes within Subliminal use this timeout to control operations that 
 involve waiting. In particular, this timeout is used to wait for interface elements
 to become valid and/or tappable, as required by the tests. 
 See `+[SLUIAElement defaultTimeout]`.
 
 The default value is 5 seconds.
 */
@property (nonatomic) NSTimeInterval defaultTimeout;

/// -------------------------------------------
/// @name Getting the Shared Test Controller
/// -------------------------------------------

/**
 Returns the test controller.
 
 @return The shared `SLTestController` instance.
 */
+ (instancetype)sharedTestController;

/// -------------------------------------------
/// @name Running Tests
/// -------------------------------------------

/**
 Run the specified tests.
 
 Tests are run on a background queue, in indeterminate order.
 Tests must [support the current platform](+[SLTest supportsCurrentPlatform]) 
 in order to be run.
 If any tests [are focused](+[SLTest isFocused]), only those tests will be run.
 
 When all tests have finished, the completion block (if provided)
 will be executed on the main queue. The test controller will then signal 
 UIAutomation to finish executing commands.
 
 @warning The shared `SLLogger` must be [set](+[SLLogger setSharedLogger:]) before 
 tests can be run.

 @param tests The set of tests to run.
 @param completionBlock An optional block to execute once testing has finished. 
 */
- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock;

@end
