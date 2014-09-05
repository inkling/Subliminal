//
//  SLAlertTestViewController.m
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

@interface SLTerminalTestViewController : SLTestCaseViewController

@end

@implementation SLTerminalTestViewController {
    UIView *_testView;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // We don't need any particular view for the most of the test cases,
    // as they simply assess the terminal's functioning.
    // We can repurpose the placeholder view for the remaining test cases
    // (the "waiting on..." cases).
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = [UIColor whiteColor];

    UIFont *nothingToShowHereFont = [UIFont systemFontOfSize:18.0f];
    NSString *nothingToShowHereText = @"Nothing to show here.";
    CGRect nothingToShowHereBounds = CGRectIntegral((CGRect){ .size = [nothingToShowHereText sizeWithFont:nothingToShowHereFont
                                                                                        constrainedToSize:CGSizeMake(3 * CGRectGetWidth(view.bounds) / 4.0f, CGFLOAT_MAX)] });
    UILabel *nothingToShowHereLabel = [[UILabel alloc] initWithFrame:nothingToShowHereBounds];
    nothingToShowHereLabel.backgroundColor = view.backgroundColor;
    nothingToShowHereLabel.font = nothingToShowHereFont;
    nothingToShowHereLabel.numberOfLines = 0;
    nothingToShowHereLabel.text = nothingToShowHereText;
    nothingToShowHereLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [view addSubview:nothingToShowHereLabel];
    nothingToShowHereLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));

    _testView = nothingToShowHereLabel;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([NSStringFromSelector(self.testCase) hasPrefix:@"testWait"] &&
        self.testCase != @selector(testWaitUntilTrueReturnsYESImmediatelyWhenConditionIsTrueUponWait)) {
        _testView.hidden = YES;
    }
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showTestViewAfterInterval:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showTestView {
    _testView.hidden = NO;
}

- (void)showTestViewAfterInterval:(NSNumber *)interval {
    [self performSelector:@selector(showTestView) withObject:nil afterDelay:[interval doubleValue]];
}

@end
