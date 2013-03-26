//
//  SLElementVisibilityTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>


@interface SLElementVisibilityTestElementContainerView : UIView
@property (nonatomic) BOOL coverTestElement;
@end

@implementation SLElementVisibilityTestElementContainerView {
    NSArray *_accessibilityElements;
    UIAccessibilityElement *_testElement, *_otherElement;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _testElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        _testElement.accessibilityLabel = @"test";

        _otherElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        _otherElement.accessibilityLabel = @"other";

        // _otherElement being first in the array
        // means that _testElement is behind it in terms of z-ordering
        _accessibilityElements = @[ _otherElement, _testElement ];
    }
    return self;
}

- (NSInteger)accessibilityElementCount {
    return [_accessibilityElements count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return [_accessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [_accessibilityElements indexOfObject:element];
}

- (void)setCoverTestElement:(BOOL)coverTestElement {
    if (coverTestElement != _coverTestElement) {
        _coverTestElement = coverTestElement;
        [self setNeedsLayout];
    }
}

- (void)setCenter:(CGPoint)center {
    if (!CGPointEqualToPoint(center, self.center)) {
        [super setCenter:center];
        // re-centering (without the frame's size changing) does not automatically force relayout
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect testElementFrameInOurBounds = CGRectMake(0, 0,
                                                    CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _testElement.accessibilityFrame = [self.window convertRect:[self convertRect:testElementFrameInOurBounds toView:nil] toWindow:nil];
    if (self.coverTestElement) {
        _otherElement.accessibilityFrame = _testElement.accessibilityFrame;
    } else {
        CGRect otherElementFrameInOurBounds = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds),
                                                         CGRectGetWidth(self.bounds) / 2.0f, CGRectGetHeight(self.bounds) / 2.0f);
        _otherElement.accessibilityFrame = [self.window convertRect:[self convertRect:otherElementFrameInOurBounds toView:nil] toWindow:nil];
    }
}

@end


@interface SLElementVisibilityTestViewController : SLTestCaseViewController

@end

@interface SLElementVisibilityTestViewController ()
// Connect IBOutlets here.
@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIView *otherView;
@end

@implementation SLElementVisibilityTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName;
    if (testCase == @selector(testViewIsNotVisibleIfItIsHidden)) {
        nibName = @"SLElementVisibilityTestHidden";
    } else if (testCase == @selector(testViewIsNotVisibleIfSuperviewIsHidden)) {
        nibName = @"SLElementVisibilityTestSuperviewHidden";
    } else if (testCase == @selector(testViewIsNotVisibleIfItHasAlphaBelow0_01)) {
        nibName = @"SLElementVisibilityTestLowAlpha";
    } else if (testCase == @selector(testViewIsNotVisibleIfItIsOffscreen)) {
        nibName = @"SLElementVisibilityTestOffscreen";
    } else if (testCase == @selector(testViewIsNotVisibleIfItsCenterIsCovered)) {
        nibName = @"SLElementVisibilityTestCovered";
    } else if (testCase == @selector(testAccessibilityElementIsNotVisibleIfContainerIsHidden)) {
        nibName = @"SLElementVisibilityTestElementContainerHidden";
    } else if (testCase == @selector(testAccessibilityElementIsNotVisibleIfItIsOffscreen)) {
        nibName = @"SLElementVisibilityTestElementOffscreen";
    } else if ((testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView)) || (testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement)))  {
        nibName = @"SLElementVisibilityTestElementCovered";
    }
    return nibName;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(showTestView)];
        [testController registerTarget:self forAction:@selector(showTestViewSuperview)];
        [testController registerTarget:self forAction:@selector(increaseTestViewAlpha)];
        [testController registerTarget:self forAction:@selector(moveTestViewOnscreen)];
        [testController registerTarget:self forAction:@selector(uncoverTestView)];
        [testController registerTarget:self forAction:@selector(uncoverTestElement)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *testCaseName = NSStringFromSelector(self.testCase);
    if ([testCaseName hasPrefix:@"testView"]) {
        self.testView.isAccessibilityElement = YES;
        self.testView.accessibilityLabel = @"test";
    } else if ([testCaseName hasPrefix:@"testAccessibilityElement"]) {
        NSAssert([self.testView isKindOfClass:[SLElementVisibilityTestElementContainerView class]],
                 @"For the purposes of 'testElement...' test cases, self.testView must be an SLElementVisibilityTestElementContainerView");
        if (self.testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement)) {
            // the test element will be hidden not by self.otherView but by self.testView->_otherElement
            self.otherView.hidden = YES;
            ((SLElementVisibilityTestElementContainerView *)self.testView).coverTestElement = YES;
        }
    }
}

#pragma mark - App Hooks

- (void)showTestView {
    self.testView.hidden = NO;
}

- (void)showTestViewSuperview {
    self.otherView.hidden = NO;
}

- (void)increaseTestViewAlpha {
    self.testView.alpha = 1.0f;
}

- (void)moveTestViewOnscreen {
    self.testView.center = self.view.center;
}

- (void)uncoverTestView {
    self.otherView.frame = CGRectOffset(self.otherView.frame, -50.0f, -50.0f);
}

- (void)uncoverTestElement {
    ((SLElementVisibilityTestElementContainerView *)self.testView).coverTestElement = NO;
}

@end
