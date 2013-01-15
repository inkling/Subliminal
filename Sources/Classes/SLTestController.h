//
//  SLTestController.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SLTestController : NSObject

@property (nonatomic) NSTimeInterval defaultTimeout;

+ (id)sharedTestController;

/**
 Run the specified tests.
 
 Tests are run on a background queue, in indeterminate order
 (except for the startup test, if it is included in the test set--it will be run first).
 If any tests are focused, only those tests will be run.
 
 When all tests have finished, the completion block (if provided)
 will be executed on the main queue. The test controller will then signal 
 UIAutomation to finish executing commands.
 
 @param tests The set of tests to run.
 @param block The block to execute once testing has finished.
 
 @see +[SLTest isStartupTest]
 @see +[SLTest isFocused]
 */
- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock;

@end
