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
    // Since we're just testing the geometry functions,
    // we don't require any particular view.
    [self loadGenericView];
}

- (void)dealloc
{
    [[SLTestController sharedTestController] deregisterTarget:self];
}

@end
