//
//  SLAlertTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface SLAlertTestViewController : SLTestCaseViewController <UIAlertViewDelegate>

@end

@implementation SLAlertTestViewController {
    UIAlertView *_activeAlertView;
    NSString *_titleOfLastButtonClicked;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing UIAlertViews in this test,
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
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showAlertWithTitle:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showAlertWithInfo:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(dismissActiveAlert)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(titleOfLastButtonClicked)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showAlertWithTitle:(NSString *)title {
    [self showAlertWithInfo:@{ @"title": title, @"cancel": @"Ok" }];
}

- (void)showAlertWithInfo:(NSDictionary *)info {
    _activeAlertView = [[UIAlertView alloc] initWithTitle:info[@"title"]
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:info[@"cancel"]
                                        otherButtonTitles:info[@"other"], nil];
    [_activeAlertView show];
}

- (void)dismissActiveAlert {
    if (_activeAlertView.numberOfButtons == 0) {
        // the alert shown by testDismissThrowsAbsentBothCancelAndDefaultButtons has no buttons
        // it appears that it can be dismissed with dismissWithClickedButtonIndex:0 even so,
        // but just to be safe...
        [_activeAlertView addButtonWithTitle:@"Dismiss"];
    }
    [_activeAlertView dismissWithClickedButtonIndex:0 animated:YES];
    _activeAlertView = nil;
}

- (NSString *)titleOfLastButtonClicked {
    return _titleOfLastButtonClicked;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _titleOfLastButtonClicked = [alertView buttonTitleAtIndex:buttonIndex];
    _activeAlertView = nil;
}

@end
