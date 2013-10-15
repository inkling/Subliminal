//
//  SLElementVisibilityTestViewController.m
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


@interface SLElementVisibilityTestViewController : SLTestCaseViewController <UITableViewDataSource, UITableViewDelegate>
@end

@interface CircleView : UIView
@end

@implementation CircleView
- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] set];
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0, 0.0, 75.0, 75.0));
}
@end

@interface SLElementVisibilityTestElementContainerView : UIView
@property (nonatomic) BOOL coverTestElement;
@end

@implementation SLElementVisibilityTestElementContainerView {
    NSArray *_accessibilityElements;
    UIAccessibilityElement *_testElement, *_otherElement;
}

- (void)commonInit {
    self.backgroundColor = [UIColor blueColor];

    _testElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    _testElement.accessibilityLabel = @"test";

    _otherElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    _otherElement.accessibilityLabel = @"other";

    // _otherElement being first in the array
    // means that _testElement is behind it in terms of z-ordering
    _accessibilityElements = @[ _otherElement, _testElement ];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
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

// The view is added to the tableview cell and completely laid out
// before the tableview cell is added to the window.
// We need to update the accessibility frames when it moves to the window.
- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setNeedsLayout];
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


@interface SLElementVisibilityTestCell : UITableViewCell

+ (CGFloat)rowHeight;

@property (nonatomic, readonly, strong) UIView *testView;

@end

@implementation SLElementVisibilityTestCell

+ (CGFloat)rowHeight {
    return 200.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;

        Class testViewClass = Nil;
        BOOL hideView = NO;
        SEL testCase = NSSelectorFromString([[reuseIdentifier componentsSeparatedByString:@"_"] lastObject]);
        if (testCase == @selector(testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell)) {
            testViewClass = [UIView class];
        } else if (testCase == @selector(testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell)) {
            testViewClass = [SLElementVisibilityTestElementContainerView class];
            hideView = YES;
        } else {
            NSAssert(NO, @"%@ reuse identifier was not of expected format: '%@_<%@ test case>'.",
                     NSStringFromClass([self class]), NSStringFromClass([self class]), NSStringFromClass([SLElementVisibilityTestViewController class]));
        }
        _testView = [[testViewClass alloc] initWithFrame:(CGRect){CGPointZero, {100.0f, 100.0f}}];
        _testView.backgroundColor = [UIColor blueColor];
        _testView.hidden = hideView;
        [self.contentView addSubview:_testView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _testView.center = self.center;
}

@end


@interface SLElementVisibilityTestViewController () <UIWebViewDelegate>
// testView is purposely strong so that we can hold onto it
// while it's removed from the view hierarchy
@property (strong, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIView *otherView;
@end

@implementation SLElementVisibilityTestViewController {
    NSString *_testTableViewCellIdentifier;

    UIWebView *_webView;
    BOOL _webViewDidFinishLoad;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName;
    if (testCase == @selector(testViewIsNotVisibleIfItIsHidden)) {
        nibName = @"SLElementVisibilityTestHidden";
    } else if (testCase == @selector(testViewIsNotVisibleIfSuperviewIsHidden)) {
        nibName = @"SLElementVisibilityTestSuperviewHidden";
    } else if (testCase == @selector(testViewIsVisibleIfDescendantIsVisible)) {
        nibName = @"SLElementVisibilityTestSuperviewWithVisibleSubview";
    } else if (testCase == @selector(testViewIsVisibleEvenIfUserInteractionIsDisabled)) {
        nibName = @"SLElementVisibilityTestUserInteractionDisabled";
    } else if (testCase == @selector(testViewIsNotVisibleIfItHasAlphaBelow0_01)) {
        nibName = @"SLElementVisibilityTestLowAlpha";
    } else if (testCase == @selector(testViewIsNotVisibleIfItIsOffscreen)) {
        nibName = @"SLElementVisibilityTestOffscreen";
    } else if (testCase == @selector(testViewIsNotVisibleIfCenterAndAnyCornerAreCovered)) {
        nibName = @"SLElementVisibilityTestCovered";
    } else if (testCase == @selector(testViewIsVisibleIfItsCenterIsCoveredByClearRegion)) {
        nibName = @"SLElementVisibilityTestCoveredByClearRegion";
    } else if (testCase == @selector(testAccessibilityElementIsNotVisibleIfContainerIsHidden)) {
        nibName = @"SLElementVisibilityTestElementContainerHidden";
    } else if (testCase == @selector(testAccessibilityElementIsVisibleEvenIfHidden)) {
        nibName = @"SLElementVisibilityTestElementHidden";
    } else if (testCase == @selector(testAccessibilityElementIsNotVisibleIfItIsOffscreen)) {
        nibName = @"SLElementVisibilityTestElementOffscreen";
    } else if (testCase == @selector(testAccessibilityElementCannotBeOccludedByPeerSubview)) {
        nibName = @"SLElementVisibilityWithSubviews";
    } else if ((testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView)) ||
               (testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement)))  {
        nibName = @"SLElementVisibilityTestElementCovered";
    } else if ((testCase == @selector(testIsValidAndVisibleDoesNotThrowIfElementIsInvalid)) ||
               (testCase == @selector(testIsValidAndVisibleReturnsYESIfElementIsBothValidAndVisible)) ||
               (testCase == @selector(testIsInvalidOrInvisibleDoesNotThrowIfElementIsInvalid)) ||
               (testCase == @selector(testIsInvalidOrInvisibleReturnsYESIfElementIsInvalidOrInvisible))) {
        nibName = @"SLElementVisibilityTestHidden";
    }
    return nibName;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(showTestView)];
        [testController registerTarget:self forAction:@selector(showTestViewSuperview)];
        [testController registerTarget:self forAction:@selector(makeOtherViewAccessible)];
        [testController registerTarget:self forAction:@selector(increaseTestViewAlpha)];
        [testController registerTarget:self forAction:@selector(moveTestViewOnscreen)];
        [testController registerTarget:self forAction:@selector(showOtherViewWithTag:)];
        [testController registerTarget:self forAction:@selector(hideOtherViewWithTag:)];
        [testController registerTarget:self forAction:@selector(uncoverTestElement)];
        [testController registerTarget:self forAction:@selector(hideTestView)];
        [testController registerTarget:self forAction:@selector(removeTestViewFromSuperview)];
        [testController registerTarget:self forAction:@selector(addTestViewToView)];
        [testController registerTarget:self forAction:@selector(webViewDidFinishLoad)];
        [testController registerTarget:self forAction:@selector(showTestText)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)loadViewForTestCase:(SEL)testCase {
    if (testCase == @selector(testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell) ||
        testCase == @selector(testAccessibilityElementIsNotVisibleIfContainerIsHiddenEvenInTableViewCell)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor whiteColor];

        UITableView *tableView = [[UITableView alloc] initWithFrame:view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = [SLElementVisibilityTestCell rowHeight];
        [view addSubview:tableView];

        self.view = view;
    } else if (testCase == @selector(testCanDetermineVisibilityOfWebAccessibilityElements)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        _webView = [[UIWebView alloc] initWithFrame:view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:_webView];
        self.view = view;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *testCaseName = NSStringFromSelector(self.testCase);
    if ([testCaseName hasPrefix:@"testView"] ||
        [testCaseName hasPrefix:@"testIsValidAndVisible"] ||
        [testCaseName hasPrefix:@"testIsInvalidOrInvisible"]) {
        self.testView.isAccessibilityElement = YES;
        self.testView.accessibilityLabel = @"test";

        if ([testCaseName isEqualToString:@"testViewIsVisibleEvenIfUserInteractionIsDisabled"]) {
            self.testView.userInteractionEnabled = NO;
        }
    } else if ([testCaseName hasPrefix:@"testAccessibilityElement"]) {
        if (self.testCase == @selector(testAccessibilityElementIsVisibleEvenIfHidden)) {
            self.testView.accessibilityElementsHidden = YES;
        } else if (self.testCase == @selector(testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement)) {
            NSAssert([self.testView isKindOfClass:[SLElementVisibilityTestElementContainerView class]],
                     @"self.testView must be an SLElementVisibilityTestElementContainerView");

            // the test element will be hidden not by self.otherView but by self.testView->_otherElement
            self.otherView.hidden = YES;
            ((SLElementVisibilityTestElementContainerView *)self.testView).coverTestElement = YES;
        }
    } else if ([testCaseName isEqualToString:@"testCanDetermineVisibilityOfWebAccessibilityElements"]) {
        NSString *webViewHTMLPath = [[NSBundle mainBundle] pathForResource:@"SLElementVisibilityTest" ofType:@"html"];
        NSURL *webViewHTMLURL = [NSURL fileURLWithPath:webViewHTMLPath];
        NSURLRequest *webViewRequest = [NSURLRequest requestWithURL:webViewHTMLURL];
        _webView.delegate = self;
        [_webView loadRequest:webViewRequest];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewDidFinishLoad = YES;
}

#pragma mark - UITableView datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_testTableViewCellIdentifier) {
        _testTableViewCellIdentifier = [NSString stringWithFormat:@"%@_%@",
                                        NSStringFromClass([SLElementVisibilityTestCell class]), NSStringFromSelector(self.testCase)];
    }

    SLElementVisibilityTestCell *cell = (SLElementVisibilityTestCell *)[tableView dequeueReusableCellWithIdentifier:_testTableViewCellIdentifier];
    if (!cell) {
        cell = [[SLElementVisibilityTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_testTableViewCellIdentifier];
    }

    if (self.testCase == @selector(testViewIsNotVisibleIfItIsHiddenEvenInTableViewCell)) {
        cell.testView.isAccessibilityElement = YES;
        cell.testView.accessibilityLabel = @"test";
    }
    self.testView = cell.testView;

    return cell;
}

#pragma mark - App Hooks

- (void)showTestView {
    self.testView.hidden = NO;
}

- (void)showTestViewSuperview {
    self.otherView.hidden = NO;
}

- (void)makeOtherViewAccessible {
    self.otherView.isAccessibilityElement = YES;
    self.otherView.accessibilityLabel = @"other";
}

- (void)increaseTestViewAlpha {
    self.testView.alpha = 1.0f;
}

- (void)moveTestViewOnscreen {
    self.testView.center = self.view.center;
}

- (void)showOtherViewWithTag:(NSNumber *)tag {
    [self.view viewWithTag:[tag integerValue]].hidden = NO;
}

- (void)hideOtherViewWithTag:(NSNumber *)tag {
    [self.view viewWithTag:[tag integerValue]].hidden = YES;
}

- (void)uncoverTestElement {
    ((SLElementVisibilityTestElementContainerView *)self.testView).coverTestElement = NO;
}

- (void)hideTestView {
    self.testView.hidden = YES;
}

- (void)removeTestViewFromSuperview {
    [self.testView removeFromSuperview];
}

- (void)addTestViewToView {
    [self.view addSubview:self.testView];
}

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

- (void)showTestText {
    (void)[_webView stringByEvaluatingJavaScriptFromString:@"showTestText()"];
}

@end
