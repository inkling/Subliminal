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


/**
 The methods in the `SLTestController (DebugSettings)` category may be useful 
 in debugging tests.
 */
@interface SLTestController (DebugSettings)

/// -------------------------------------------
/// @name Debugging tests
/// -------------------------------------------

/**
 Determines whether the controller should wait, after `-runTests:withCompletionBlock:` 
 is invoked, to start testing.
 
 If this is YES, the test controller will show an alert after 
 `runTests:withCompletionBlock:` is invoked and will not begin testing until 
 the developer has dismissed that alert.
 
 This allows the developer time to attach the debugger to the tests. That is done 
 by launching the tests, then clicking the following menu items, in Xcode:
 
    Product -> Attach to Process -> <name of testing target, at top>
 
 This setting will only take effect if the target is built in the "Debug"
 configuration (with the `DEBUG` preprocessor macro set). This is to prevent the 
 alert from showing when built (in "Release") for an unattended, continuous 
 integration run; and to ensure that debug information will be available to the 
 debugger (whereas the Release configuration may optimize that information away).
 
 To build the tests in Debug, click the the "Scheme" dropdown in the upper
 left-hand corner, then the following menu items:
    
    <Manage Scheme> -> (double-click) <name of your "Integration Tests" scheme> -> 
    "Profile" (in the left side-bar)
 
 and change the "Build Configuration" to "Debug". 
 */
@property (nonatomic) BOOL shouldWaitToStartTesting;

@end
