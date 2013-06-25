//
//  SLTestsViewController.m
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

#import "SLTestsViewController.h"
#import "SLTestViewController.h"

#import <Subliminal/Subliminal.h>

NSString *const SLTestNameKey = @"SLTestNameKey";
NSString *const SLTestCasesKey = @"SLTestCasesKey";

@interface SLTestsViewController () <UINavigationControllerDelegate>
@end

@implementation SLTestsViewController {
    NSArray *_tests;
    NSDictionary *_pendingTestInfo;
    NSDictionary *_currentTestInfo;
}

- (instancetype)initWithTests:(NSArray *)tests {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _tests = [tests copy];
    }
    return self;
}

- (NSString *)title {
    return @"Tests";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    SLTestController *testController = [SLTestController sharedTestController];
    [testController registerTarget:self forAction:@selector(presentTestWithInfo:)];
    [testController registerTarget:self forAction:@selector(currentTest)];
    [testController registerTarget:self forAction:@selector(dismissCurrentTest)];
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
    return [_tests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class testClass = [_tests objectAtIndex:indexPath.row];

    static NSString *TestCellIdentifier = @"SLTestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TestCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TestCellIdentifier];
    }

    cell.textLabel.text = NSStringFromClass(testClass);
    
    return cell;
}

#pragma mark - Test controller presentation and dismissal

- (void)presentTestWithInfo:(NSDictionary *)testInfo {
    _pendingTestInfo = [testInfo copy];

    Class test = NSClassFromString(_pendingTestInfo[SLTestNameKey]);
    NSUInteger indexOfTest = [_tests indexOfObject:test];
    NSAssert(indexOfTest != NSNotFound, @"Cannot present test: not found in list.");

    // first select the row and scroll it to visible
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfTest inSection:0];
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
        // now that the row for the pending test has been scrolled to visible,
        // present its test cases
        SLTestViewController *testViewController = [[SLTestViewController alloc] initWithTest:test testCases:_pendingTestInfo[SLTestCasesKey]];

        // ensure that we'll receive the callback
        self.navigationController.delegate = self;
        [self.navigationController pushViewController:testViewController animated:YES];
    });
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        // We just dismissed a test.
        _currentTestInfo = nil;
    } else {
        // signal that the test has been fully presented by setting currentTest
        // the if condition allows for additional controllers to be pushed,
        // beyond the test controller
        if (_pendingTestInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _currentTestInfo = _pendingTestInfo;
                _pendingTestInfo = nil;
            });
        }
    }
}

- (NSString *)currentTest {
    return _currentTestInfo[SLTestNameKey];
}

- (void)dismissCurrentTest {
    // ensure that we'll receive the callback
    self.navigationController.delegate = self;
    [self.navigationController popToViewController:self animated:YES];
}

@end
