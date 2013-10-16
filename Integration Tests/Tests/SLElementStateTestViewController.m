//
//  SLElementStateTestViewController.m
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


@interface SLElementStateTestViewController : SLTestCaseViewController

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *coveringView;

@end


@implementation SLElementStateTestViewController {
    UIView *_testView;
    UITextField *_textField;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName = nil;
    if (testCase == @selector(testHitpointReturnsAlternatePointIfDefaultIsCovered)) {
        nibName = @"SLElementStateTestMidpointCovered";
    } else if (testCase == @selector(testHitpointReturnsNullPointIfElementIsCovered) ||
               testCase == @selector(testElementIsTappableIfItHasANonNullHitpoint) ||
               testCase == @selector(testCanRetrieveLabelEvenIfNotTappable)) {
        nibName = @"SLElementStateTestCompletelyCovered";
    }
    return nibName;
}

- (void)loadViewForTestCase:(SEL)testCase {
    if (testCase == @selector(testLabel) ||
        testCase == @selector(testValue) ||
        testCase == @selector(testIsEnabledMirrorsUIControlIsEnabledWhenMatchingObjectIsUIControl) ||
        testCase == @selector(testHitpointDefault) ||
        testCase == @selector(testHitpointDefaultIsNotAccessibilityActivationPointBelowIOS7) ||
        testCase == @selector(testRect)) {
        UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        view.backgroundColor = [UIColor whiteColor];

        _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [view addSubview:_button];
        _button.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 50.0f)};
        _button.center = view.center;

        self.view = view;
    } else if (testCase == @selector(testIsEnabledReturnsYESByDefault)) {
        UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        view.backgroundColor = [UIColor whiteColor];

        _testView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(100.0f, 50.0f)}];
        _testView.backgroundColor = [UIColor blueColor];
        _testView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [view addSubview:_testView];
        _testView.center = view.center;

        self.view = view;
    } else  if (testCase == @selector(testHasKeyboardFocus)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

        _textField = [[UITextField alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)}];
        [view addSubview:_textField];

        self.view = view;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(!(_button && _testView), @"Only one test element should have been initialized.");
    
    _button.accessibilityLabel = @"Test Element";
    _button.accessibilityValue = @"Foo";

    _testView.isAccessibilityElement = YES;
    _testView.accessibilityLabel = @"Test Element";

    _textField.accessibilityLabel = @"Test Element";
    _textField.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // move the textfield above the keyboard
    static const CGFloat kTextFieldVerticalOffset = -40.0f;
    CGPoint textFieldCenter = CGPointMake(self.view.center.x, self.view.center.y + kTextFieldVerticalOffset);
    _textField.center = textFieldCenter;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(elementLabel)];
        [testController registerTarget:self forAction:@selector(elementValue)];
        [testController registerTarget:self forAction:@selector(disableElement)];
        [testController registerTarget:self forAction:@selector(enableElement)];
        [testController registerTarget:self forAction:@selector(modifyActivationPoint)];
        [testController registerTarget:self forAction:@selector(activationPoint)];
        [testController registerTarget:self forAction:@selector(uncoverTestView)];
        [testController registerTarget:self forAction:@selector(makeTextFieldFirstResponder)];
        [testController registerTarget:self forAction:@selector(elementRect)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSString *)elementLabel {
    return _button.accessibilityLabel;
}

- (NSString *)elementValue {
    return _button.accessibilityValue;
}

- (void)disableElement {
    _button.enabled = NO;
}

- (void)enableElement {
    _button.enabled = YES;
}

- (void)modifyActivationPoint {
    _button.accessibilityActivationPoint = (CGPoint){
        .x = _button.accessibilityActivationPoint.x - 15.0f,
        .y = _button.accessibilityActivationPoint.y - 15.0f
    };
}

- (NSValue *)activationPoint {
    return [NSValue valueWithCGPoint:_button.accessibilityActivationPoint];
}

- (void)uncoverTestView {
    _coveringView.hidden = YES;
}

- (void)makeTextFieldFirstResponder {
    [_textField becomeFirstResponder];
}

- (NSValue *)elementRect {
    return [NSValue valueWithCGRect:_button.accessibilityFrame];
}

@end
