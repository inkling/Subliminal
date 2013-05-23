//
//  SLWindowTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/16/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLWindowTestViewController : SLTestCaseViewController

@end

@implementation SLWindowTestViewController

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing the window in this test,
    // we don't need any particular view.
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = [UIColor whiteColor];

    UIFont *nothingToShowHereFont = [UIFont systemFontOfSize:18.0f];
    NSString *nothingToShowHereText = @"Nothing to show here.";
    CGSize nothingToShowHereSize = [nothingToShowHereText sizeWithFont:nothingToShowHereFont
                                                     constrainedToSize:CGSizeMake(3 * CGRectGetWidth(view.bounds) / 4.0f, CGFLOAT_MAX)];
    UILabel *nothingToShowHereLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, nothingToShowHereSize}];
    nothingToShowHereLabel.backgroundColor = view.backgroundColor;
    nothingToShowHereLabel.font = nothingToShowHereFont;
    nothingToShowHereLabel.numberOfLines = 0;
    nothingToShowHereLabel.text = nothingToShowHereText;
    nothingToShowHereLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [view addSubview:nothingToShowHereLabel];
    nothingToShowHereLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));

    self.view = view;
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
