//
//  SLTestController.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SLAlert;
@interface SLTestController : NSObject

@property (nonatomic) NSTimeInterval defaultTimeout;

/**
 If YES (the default) UIAutomation will attempt to dismiss any alert encountered during
 the execution of the tests by tapping the cancel button, if the button exists,
 then tapping the default button, if one is identifiable. If the alert is
 still not dismissed, the tests will abort.

 If NO it is the responsibility of the tests to dismiss alerts.

 @see -pushHandlerForAlert:
 */
@property (nonatomic) BOOL automaticallyDismissAlerts;

/**
 Prevents the next instance of the specified alert
 from being automatically dismissed.
 
 Tests may let the test controller automatically dismiss most alerts, 
 yet still handle relevant alerts manually, by overriding the default handler 
 on a per-alert basis.
 
     SLAlert *alert = [SLAlert alertWithTitle:@"foo];
     [[SLTestController sharedTestController] pushHandlerForAlert:alert];
    
     // cause an alert with title "foo" to appear
 
     [alert dismiss];
 
 Tests must push handlers _before_ the corresponding alerts are shown.

 A handler is popped after it handles an alert. Multiple handlers (even for the same
 alert) may be pushed simultaneously; when an alert is shown, they are checked 
 in FILO order, and the first one [to match the alert](-[SLAlert isEqualToUIAAlertPredicate]) 
 is removed.

 It is not necessary to use this method if automaticallyDismissAlerts is NO.

 @param alert An alert that will be manually dismissed by the tests.
 @see -automaticallyDismissAlerts
 */
- (void)pushHandlerForAlert:(SLAlert *)alert;

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
