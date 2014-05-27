//
//  SLStatusBarTestViewController.m
//  Subliminal
//
//  Created by Leon Jiang on 8/12/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLStatusBarTestViewController : SLTestCaseViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation SLStatusBarTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLStatusBarTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(contentOffsetY)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 2000.0);
}

#pragma mark - App Hooks

- (NSNumber *)contentOffsetY {
    return @(self.scrollView.contentOffset.y);
}

@end