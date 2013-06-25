//
//  SLStaticElementTestViewController.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLStaticElementTestViewController : SLTestCaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation SLStaticElementTestViewController {
    UIButton *_button;
    BOOL _buttonWasTapped;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName = nil;
    if (testCase == @selector(testStaticElementsDoNotWaitUntilTappableIfIsScrollViewIsYESAndIsIPad5_x)) {
        nibName = @"SLStaticElementTestScrollView";
    }
    return nibName;
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

    self.scrollView.accessibilityIdentifier = @"scroll view";
    self.scrollView.backgroundColor = [UIColor blueColor];
    self.scrollView.hidden = YES;
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
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hideScrollView)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showScrollViewAfterInterval:)];
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

- (void)hideScrollView {
    self.scrollView.hidden = YES;
}

- (void)showScrollView {
    self.scrollView.hidden = NO;
}

- (void)showScrollViewAfterInterval:(NSNumber *)intervalNumber {
    NSTimeInterval delay = [intervalNumber doubleValue];
    if (!delay) {
        [self showScrollView];
    } else {
        [self performSelector:@selector(showScrollView) withObject:nil afterDelay:delay];
    }
}

@end
