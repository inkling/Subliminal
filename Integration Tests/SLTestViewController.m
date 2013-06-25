//
//  SLTestViewController.m
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

#import "SLTestViewController.h"
#import "SLTestCaseViewController.h"

#import <Subliminal/Subliminal.h>

NSString *const SLTestCaseKey = @"SLTestCaseKey";
NSString *const SLTestCaseViewControllerClassNameKey = @"SLTestCaseViewControllerClassNameKey";

@interface SLTestViewController () <UINavigationControllerDelegate>
@end

@implementation SLTestViewController {
    Class _test;
    NSArray *_testCases;
    NSDictionary *_pendingTestCaseInfo;
    NSDictionary *_currentTestCaseInfo;
}

- (instancetype)initWithTest:(Class)test testCases:(NSSet *)testCases {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _test = test;
        _testCases = [testCases allObjects];
    }
    return self;
}

- (NSString *)title {
    return NSStringFromClass(_test);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    SLTestController *testController = [SLTestController sharedTestController];
    [testController registerTarget:self forAction:@selector(presentTestCaseWithInfo:)];
    [testController registerTarget:self forAction:@selector(currentTestCase)];
    [testController registerTarget:self forAction:@selector(dismissCurrentTestCase)];
}

// note that we do not deregister this controller in viewWillDisappear:,
// the reason being that it needs to dismiss test view controllers while hidden

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_testCases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *testCaseName = [_testCases objectAtIndex:indexPath.row];

    static NSString *TestCaseCellIdentifier = @"SLTestCaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TestCaseCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TestCaseCellIdentifier];
    }

    cell.textLabel.text = testCaseName;

    return cell;
}

#pragma mark - Test case controller presentation and dismissal

- (void)presentTestCaseWithInfo:(NSDictionary *)testCaseInfo {
    _pendingTestCaseInfo = [testCaseInfo copy];

    NSString *testCase = _pendingTestCaseInfo[SLTestCaseKey];
    NSUInteger indexOfTestCase = [_testCases indexOfObject:testCase];
    NSAssert(indexOfTestCase != NSNotFound, @"Cannot present test: not found in list.");

    // first select the row and scroll it to visible
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfTestCase inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];

    // wait until any scrolling animation might have concluded--they're of uniform duration
    double scrollingDelayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(scrollingDelayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // now that the row for the pending test case has been scrolled to visible,
        // present its view controller
        NSString *testCaseViewControllerClassName = _pendingTestCaseInfo[SLTestCaseViewControllerClassNameKey];
        Class testCaseViewControllerClass = NSClassFromString(testCaseViewControllerClassName);
        NSAssert(testCaseViewControllerClass, @"Test case view controller class '%@' not found.", testCaseViewControllerClassName);
        SLTestCaseViewController *testCaseViewController = [[testCaseViewControllerClass alloc] initWithTestCaseWithSelector:NSSelectorFromString(testCase)];

        // ensure that we'll receive the callback
        self.navigationController.delegate = self;
        [self.navigationController pushViewController:testCaseViewController animated:YES];
    });
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        // We just dismissed a test case view controller.
        _currentTestCaseInfo = nil;
    } else {
        // signal that the test case has been fully presented by setting currentTestCase
        // the if condition allows for additional controllers to be pushed,
        // beyond the test case view controller
        if (_pendingTestCaseInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _currentTestCaseInfo = _pendingTestCaseInfo;
                _pendingTestCaseInfo = nil;
            });
        }
    }
}

- (NSString *)currentTestCase {
    return _currentTestCaseInfo[SLTestCaseKey];
}

- (void)dismissCurrentTestCase {
    // ensure that we'll receive the callback
    self.navigationController.delegate = self;
    [self.navigationController popToViewController:self animated:YES];
}

@end
