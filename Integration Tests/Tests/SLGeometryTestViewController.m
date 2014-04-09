//
//  SLGeometryTestViewController.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"
#import "SLLogger.h"
#import "SLTestController.h"
#import "SLTestController+AppHooks.h"

@interface SLGeometryTestViewController : SLTestCaseViewController

@property (nonatomic, strong) UIView *rectView;

@end

@implementation SLGeometryTestViewController

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase
{
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(navigationBarFrameValue)];
    }
    return self;
}

- (NSValue *)navigationBarFrameValue
{
    return [NSValue valueWithCGRect:self.navigationController.navigationBar.frame];
}

- (void)loadViewForTestCase:(SEL)testCase
{
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

- (void)dealloc
{
    [[SLTestController sharedTestController] deregisterTarget:self];
}

@end
