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

/**
 If YES, UIAutomation will attempt to dismiss any alert encountered during
 the execution of the tests by tapping the cancel button, if the button exists,
 then tapping the default button, if one is identifiable. If the alert is
 still not dismissed, the tests will abort.

 If NO (the default) it is the responsibility of the tests to dismiss alerts.
 */
@property (nonatomic) BOOL automaticallyDismissAlerts;

+ (id)sharedTestController;

/**
 Run the specified tests.
 
 Tests are run on a background queue, in indeterminate order.
 Tests must support the current platform in order to be run.
 If any tests are focused, only those tests will be run.
 
 When all tests have finished, the completion block (if provided)
 will be executed on the main queue. The test controller will then signal 
 UIAutomation to finish executing commands.
 
 @param tests The set of tests to run.
 @param block The block to execute once testing has finished.
 
 @see +[SLTest supportsCurrentPlatform]
 @see +[SLTest isFocused]
 */
- (void)runTests:(NSSet *)tests withCompletionBlock:(void (^)())completionBlock;

@end
