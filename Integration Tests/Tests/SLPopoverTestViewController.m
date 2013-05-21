//
//  SLPopoverTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

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
    CGSize nothingToShowHereSize = [nothingToShowHereText sizeWithFont:nothingToShowHereFont
                                                     constrainedToSize:CGSizeMake(3 * CGRectGetWidth(view.bounds) / 4.0f, CGFLOAT_MAX)];
    _label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, nothingToShowHereSize}];
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
