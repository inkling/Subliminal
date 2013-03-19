//
//  SLElementStateTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface SLElementStateTestViewController : SLTestCaseViewController

@end

@implementation SLElementStateTestViewController {
    UIButton *_button;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = [UIColor whiteColor];

    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:_button];
    _button.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 50.0f)};
    _button.center = view.center;

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _button.accessibilityLabel = @"Test Element";
    _button.accessibilityValue = @"Foo";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(elementValue)];
    }
    return self;
}

#pragma mark - App hooks

- (NSString *)elementValue {
    return _button.accessibilityValue;
}

@end
