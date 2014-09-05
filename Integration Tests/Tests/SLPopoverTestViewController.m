//
//  SLPopoverTestViewController.m
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

@interface SLPopoverTestViewController : SLTestCaseViewController

@end

@implementation SLPopoverTestViewController {
    UILabel *_label;
    UIPopoverController *_popoverController;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing popovers in this test,
    // we don't need any particular view.
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(320.0f, 480.0f)}];
    view.backgroundColor = [UIColor whiteColor];

    UIFont *nothingToShowHereFont = [UIFont systemFontOfSize:18.0f];
    NSString *nothingToShowHereText = @"Nothing to show here.";
    CGRect nothingToShowHereBounds = CGRectIntegral((CGRect){ .size = [nothingToShowHereText sizeWithFont:nothingToShowHereFont
                                                                                        constrainedToSize:CGSizeMake(3 * CGRectGetWidth(view.bounds) / 4.0f, CGFLOAT_MAX)] });
    _label = [[UILabel alloc] initWithFrame:nothingToShowHereBounds];
    _label.backgroundColor = view.backgroundColor;
    _label.font = nothingToShowHereFont;
    _label.numberOfLines = 0;
    _label.text = nothingToShowHereText;
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [view addSubview:_label];
    _label.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));

    self.view = view;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showPopover)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showPopover {
    // Inception!
    SLPopoverTestViewController *contentViewController = [[SLPopoverTestViewController alloc] initWithTestCaseWithSelector:self.testCase];

    _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    _popoverController.popoverContentSize = CGSizeMake(320.0f, 480.0f);
    [_popoverController presentPopoverFromRect:_label.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];

    // register these here vs. in init so the controller we just presented doesn't steal them
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(isPopoverVisible)];
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hidePopover)];
}

- (NSNumber *)isPopoverVisible {
    return @([_popoverController isPopoverVisible]);
}

- (void)hidePopover {
    [_popoverController dismissPopoverAnimated:NO];
}

@end
