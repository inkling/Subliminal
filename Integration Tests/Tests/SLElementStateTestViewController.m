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

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *coveringView;

@end


@implementation SLElementStateTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName = nil;
    if (testCase == @selector(testHitpointReturnsAlternatePointIfRectMidpointIsCovered)) {
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
        testCase == @selector(testHitpointReturnsRectMidpointByDefault) ||
        testCase == @selector(testRect)) {
        UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        view.backgroundColor = [UIColor whiteColor];

        _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [view addSubview:_button];
        _button.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 50.0f)};
        _button.center = view.center;

        self.view = view;
    }
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
        [testController registerTarget:self forAction:@selector(elementLabel)];
        [testController registerTarget:self forAction:@selector(elementValue)];
        [testController registerTarget:self forAction:@selector(uncoverTestView)];
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

- (void)uncoverTestView {
    _coveringView.hidden = YES;
}

- (NSValue *)elementRect {
    return [NSValue valueWithCGRect:_button.accessibilityFrame];
}

@end
