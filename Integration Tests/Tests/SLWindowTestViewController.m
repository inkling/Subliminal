//
//  SLWindowTestViewController.m
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

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLWindowTestViewController : SLTestCaseViewController

@end

@implementation SLWindowTestViewController

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing the window in this test,
    // we don't need any particular view.
    [self loadGenericView];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(setKeyWindowValue:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSString *)setKeyWindowValue:(NSString *)value {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSString *previousValue = keyWindow.accessibilityValue;
    keyWindow.accessibilityValue = value;
    return previousValue;
}

@end
