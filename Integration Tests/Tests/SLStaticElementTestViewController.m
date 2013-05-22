//
//  SLStaticElementTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface SLStaticElementTestViewController : SLTestCaseViewController

@end

@implementation SLStaticElementTestViewController {
    UIButton *_button;
    BOOL _buttonWasTapped;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [view addSubview:_button];

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _button.accessibilityIdentifier = @"SLTestStaticElement";
    _button.accessibilityValue = @"elementValue";
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _button.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)};
    _button.center = self.view.center;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(removeButtonFromSuperview)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(addButtonToViewAfterInterval:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showButton)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showButtonAfterInterval:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hideButton)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(buttonWasTapped)];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)removeButtonFromSuperview {
    [_button removeFromSuperview];
}

- (void)addButtonToView {
    [self.view addSubview:_button];
}

- (void)addButtonToViewAfterInterval:(NSNumber *)intervalNumber {
    [self performSelector:@selector(addButtonToView) withObject:nil afterDelay:[intervalNumber doubleValue]];
}

- (void)showButton {
    _button.hidden = NO;
}

- (void)showButtonAfterInterval:(NSNumber *)intervalNumber {
    [self performSelector:@selector(showButton) withObject:nil afterDelay:[intervalNumber doubleValue]];
}

- (void)hideButton {
    _button.hidden = YES;
}

- (NSNumber *)buttonWasTapped {
    return @(_buttonWasTapped);
}

- (void)buttonTapped:(id)sender {
    _buttonWasTapped = YES;
}

@end
