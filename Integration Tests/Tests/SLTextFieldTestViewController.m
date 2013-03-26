//
//  SLTextFieldTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/25/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>
#import <QuartzCore/QuartzCore.h>

@interface SLTextFieldTestViewController : SLTestCaseViewController
@property (nonatomic, strong) UITextField *textField;
@end

@implementation SLTextFieldTestViewController

- (void)loadViewForTestCase:(SEL)testCase {
    if (testCase == @selector(testSetText) || testCase == @selector(testGetText)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        _textField = [[UITextField alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)}];
        [view addSubview:_textField];
        self.view = view;
    }
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(text)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _textField.accessibilityLabel = @"test element";
    _textField.borderStyle = UITextBorderStyleRoundedRect;

    if (self.testCase == @selector(testGetText)) {
        _textField.text = @"foo";
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _textField.center = self.view.center;
}

#pragma mark - App hooks

- (NSString *)text {
    return _textField.text;
}

@end
