//
//  SLGeometryTestViewController.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLGeometryTestViewController : SLTestCaseViewController

@end

@implementation SLGeometryTestViewController

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase
{
    return [super initWithTestCaseWithSelector:testCase];
}

- (void)loadViewForTestCase:(SEL)testCase
{
    // Since we're just testing the geometry functions,
    // we don't require any particular view.
    [self loadGenericView];
}

@end
