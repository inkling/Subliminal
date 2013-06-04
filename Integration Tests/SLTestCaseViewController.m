//
//  SLTestCaseViewController.m
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

#import "SLTestCaseViewController.h"

@implementation SLTestCaseViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return nil;
}

- (void)loadViewForTestCase:(SEL)testCase {
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithNibName:[[self class] nibNameForTestCase:testCase] bundle:nil];
    if (self) {
        _testCase = testCase;
    }
    return self;
}

- (NSString *)title {
    return NSStringFromSelector(self.testCase);
}

- (void)loadView {
    // if we have a nib, load it
    if (self.nibName) {
        [super loadView];
    } else {
        // otherwise load the view programmatically
        [self loadViewForTestCase:self.testCase];
        NSAssert([self isViewLoaded], @"Concrete subclasses of %@ must override -%@ if they do not override +%@.",
                NSStringFromClass([SLTestCaseViewController class]),
                 NSStringFromSelector(@selector(loadViewForTestCase:)), NSStringFromSelector(@selector(nibNameForTestCase:)));
    }
}

@end
