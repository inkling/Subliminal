//
//  SLElementTapTestViewController.m
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
#import "SLElement.h"

@interface SLElementTapTestViewController : SLTestCaseViewController <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *scrollViewButton;
@end

@implementation SLElementTapTestViewController {
    UIView *_testView;
    UITapGestureRecognizer *_tapRecognizer, *_doubleTapRecognizer;
    CGPoint _tapPoint, _doubleTapPoint;

    BOOL _scrollViewButtonWasTapped;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName = nil;
    if ((testCase == @selector(testCannotTapScrollViewsOnIPad5_x)) ||
        (testCase == @selector(testCanTapChildElementsOfScrollViewsEvenOnIPad5_x))) {
        nibName = @"SLElementTapTestScrollViewCases";
    }
    return nibName;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];

    _testView = [[UIView alloc] initWithFrame:(CGRect){ .size = {100.0f, 100.0f} }];
    [view addSubview:_testView];

    self.view = view;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(tapPoint)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(doubleTapPoint)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(modifyActivationPoint)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(activationPoint)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(scrollViewButtonWasTapped)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(resetTapRecognition)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hideTestView)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showTestView)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showTestViewAfterInterval:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidLoad {
    _testView.backgroundColor = [UIColor blueColor];
    _testView.isAccessibilityElement = YES;
    _testView.accessibilityLabel = @"test";

    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.numberOfTouchesRequired = 1;
    _tapRecognizer.delegate = self;
    if (self.testCase == @selector(testCannotTapScrollViewsOnIPad5_x)) {
        [self.scrollView addGestureRecognizer:_tapRecognizer];
    } else {
        [_testView addGestureRecognizer:_tapRecognizer];
    }

    _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    _doubleTapRecognizer.numberOfTouchesRequired = 1;
    _doubleTapRecognizer.delegate = self;
    [_testView addGestureRecognizer:_doubleTapRecognizer];

    // we can't make the scroll view accessible in `testCanTapChildElementsOfScrollViewsEvenOnIPad5_x`
    // because that will prevent its child element from appearing in the accessibility hierarchy
    if (self.testCase == @selector(testCannotTapScrollViewsOnIPad5_x)) {
        self.scrollView.accessibilityIdentifier = @"scroll view";
    }
    [self.scrollViewButton addTarget:self action:@selector(scrollViewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _testView.center = self.view.center;
}

#pragma mark - Gesture recognition

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // doesn't matter if taps and double taps recognize simultaneously
    return YES;
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    // convert the point to screen coordinates (the system used by accessibility)
    CGPoint tapPointInWindowCoordinates = [recognizer locationInView:nil];
    _tapPoint = [self.view.window convertPoint:tapPointInWindowCoordinates toWindow:nil];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    // convert the point to screen coordinates (the system used by accessibility)
    CGPoint doubleTapPointInWindowCoordinates = [recognizer locationInView:nil];
    _doubleTapPoint = [self.view.window convertPoint:doubleTapPointInWindowCoordinates toWindow:nil];
}

- (void)scrollViewButtonTapped {
    _scrollViewButtonWasTapped = YES;
}

#pragma mark - App hooks

- (NSValue *)tapPoint {
    if (SLCGPointIsNull(_tapPoint)) return nil;
    else return [NSValue valueWithCGPoint:_tapPoint];
}

- (NSValue *)doubleTapPoint {
    if (SLCGPointIsNull(_doubleTapPoint)) return nil;
    else return [NSValue valueWithCGPoint:_doubleTapPoint];
}

- (void)modifyActivationPoint {
    _testView.accessibilityActivationPoint = (CGPoint){
        .x = _testView.accessibilityActivationPoint.x - 25.0f,
        .y = _testView.accessibilityActivationPoint.y - 25.0f
    };
}

- (NSValue *)activationPoint {
    return [NSValue valueWithCGPoint:_testView.accessibilityActivationPoint];
}

- (NSNumber *)scrollViewButtonWasTapped {
    return @(_scrollViewButtonWasTapped);
}

- (void)resetTapRecognition {
    _tapPoint = SLCGPointNull, _doubleTapPoint = SLCGPointNull;
    _scrollViewButtonWasTapped = NO;
}

- (void)hideTestView {
    _testView.hidden = YES;
}

- (void)showTestView {
    _testView.hidden = NO;
}

- (void)showTestViewAfterInterval:(NSNumber *)intervalNumber {
    [self performSelector:@selector(showTestView) withObject:nil afterDelay:[intervalNumber doubleValue]];
}

@end
