//
//  SLIntegrationTestsAppDelegate.m
//  Integration Tests
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

#import "SLIntegrationTestsAppDelegate.h"
#import "SLTestsViewController.h"
#import "SLTestCaseViewController.h"

#import <Subliminal/Subliminal.h>
#import <Subliminal/SLTerminal.h>
#import "SLTestController+Internal.h"

// If you wish to explore a particular test case view controller with UIAutomation attached,
// to verify that it is configured properly for testing,
// set DEBUG_TEST_CASE_VIEW_CONTROLLER to the view controller's class,
// and DEBUG_TEST_CASE to the test case selector with which to initialize the view controller.
#define DEBUG_TEST_CASE_VIEW_CONTROLLER_CLASS NSClassFromString(@"")
#define DEBUG_TEST_CASE @selector(testCase)

@interface SLIntegrationTestsAppDelegate () <UIAlertViewDelegate>
@end

@implementation SLIntegrationTestsAppDelegate {
    NSSet *_tests;
    NSString *_terminalStartupResult;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // Initialize root view controller
    UIViewController *rootViewController = nil;
    if (DEBUG_TEST_CASE_VIEW_CONTROLLER_CLASS) {
        rootViewController = [[DEBUG_TEST_CASE_VIEW_CONTROLLER_CLASS alloc] initWithTestCaseWithSelector:DEBUG_TEST_CASE];
    } else {
        // Filter the tests for the SLTestController
        // so that the SLTestsViewController only displays appropriate tests
        _tests = [SLTestController testsToRun:[SLTest allTests] withFocus:NULL];
        rootViewController = [[SLTestsViewController alloc] initWithTests:[_tests allObjects]];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navController;

    [self.window makeKeyAndVisible];

    // Begin testing
    if (!DEBUG_TEST_CASE_VIEW_CONTROLLER_CLASS) {
        // Verify that we can talk to the terminal
        // (This is like "test 0", but can't be an actual SLTest
        // because we can't rely upon the logging infrastructure if the terminal doesn't work)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _terminalStartupResult = [[SLTerminal sharedTerminal] eval:@"'Hello' + ' ' + 'world'"];
        });
        // If UIAutomation is unresponsive, the eval: call above will block indefinitely;
        // verifying the startup result on the main thread lets us timeout.
        // We can't block this method's return, so we verify the result after a delay.
        [self performSelector:@selector(verifyTerminalConnectionAndRunTests) withObject:nil afterDelay:0.1];
    }

    return YES;
}

- (void)verifyTerminalConnectionAndRunTests {
    // Wait for UIAutomation to evaluate our command
    NSTimeInterval startupTimeout = 5.0;
    NSDate *startDate = [NSDate date];
    while (![_terminalStartupResult isEqualToString:@"Hello world"]
           && [[NSDate date] timeIntervalSinceDate:startDate] < startupTimeout) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    // If UIAutomation is unresponsive, show an alert and abort the application
    if (![_terminalStartupResult isEqualToString:@"Hello world"]) {
        NSTimeInterval abortTimeout = 5.0;
        NSString *abortMessage = [NSString stringWithFormat:@"UIAutomation appears unresponsive. The application will abort in %g seconds.", abortTimeout];
        [[[UIAlertView alloc] initWithTitle:@"Cannot Reach UIAutomation"
                                    message:abortMessage
                                   delegate:self
                          cancelButtonTitle:@"Abort"
                          otherButtonTitles:nil] show];
        [NSTimer scheduledTimerWithTimeInterval:abortTimeout target:self selector:@selector(abort) userInfo:nil repeats:NO];
    }

    // Otherwise, run the tests
    [[SLTestController sharedTestController] runTests:_tests withCompletionBlock:nil];
}

// Called both by the UIAlertView callback below and the NSTimer above
- (void)abort {
    abort();
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self abort];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
