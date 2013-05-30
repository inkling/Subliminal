//
//  SLElementMatchingTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>


@interface SLElementMatchingTestViewController : SLTestCaseViewController
@end


@interface SLElementMatchingTestCell : UITableViewCell

- (void)configureAccessibility;

@end

@implementation SLElementMatchingTestCell {
    SEL _testCase;
    UISwitch *_switch;
    UILabel *_weatherCity, *_weatherTemp;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _testCase = NSSelectorFromString([[reuseIdentifier componentsSeparatedByString:@"_"] lastObject]);
        if (_testCase == @selector(testMatchingNonLabelTableViewCellChildElement)) {
            _switch = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.accessoryView = _switch;
        } else if ((_testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
                   (_testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell))){
            _weatherCity = [[UILabel alloc] initWithFrame:CGRectZero];
            _weatherCity.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_weatherCity];
            
            _weatherTemp = [[UILabel alloc] initWithFrame:CGRectZero];
            _weatherTemp.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_weatherTemp];
        } else {
            NSAssert(NO, @"%@ reuse identifier was not of expected format: '%@_<%@ test case>'.",
                     NSStringFromClass([self class]), NSStringFromClass([self class]), NSStringFromClass([SLElementMatchingTestViewController class]));
        }
    }
    return self;
}

- (void)configureAccessibility {
    _switch.accessibilityLabel = @"fooSwitch";

    // recreating Apple's example from the "Enhancing the Accessibility of Table View Cells" document
    // http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html#//apple_ref/doc/uid/TP40008785-CH102-SW3
    // we have child elements that are individually accessible
    // (UILabels are, by default, accessibility elements,
    // with accessibility labels derived from their text)
    // and the cell itself is not accessible
    // but uses a combination of its children's labels as its label
    _weatherCity.text = @"city";
    _weatherTemp.text = @"temp";
}

- (NSString *)accessibilityLabel {
    if (_testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) {
        return [NSString stringWithFormat:@"%@, %@", _weatherCity.accessibilityLabel, _weatherTemp.accessibilityLabel];
    }
    return [super accessibilityLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = CGRectInset(self.contentView.bounds, 20.0f, 0.0f);
    CGFloat halfWidth = CGRectGetWidth(contentRect) / 2.0;
    CGSize halfSize = CGSizeMake(halfWidth, CGRectGetHeight(contentRect));
    _weatherCity.frame = (CGRect){
        contentRect.origin,
        halfSize
    };
    _weatherTemp.frame = (CGRect){
        CGPointMake(CGRectGetMinX(contentRect) + halfWidth, CGRectGetMinY(contentRect)),
        halfSize
    };
}

@end


@interface SLElementMatchingTestViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

// fooButton is purposely strong so that we can hold onto it
// while it's removed from the view hierarchy in testElementsWaitToMatchValidObjects
@property (strong, nonatomic) IBOutlet UIButton *fooButton;

@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SLElementMatchingTestViewController {
    UIView *_parentView, *_childView;
    UIWebView *_webView;
    BOOL _webViewDidFinishLoad;

    UIPopoverController *_popoverController;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    if ((testCase == @selector(testElementsDoNotCaptureTheirMatches)) ||
        (testCase == @selector(testElementsCanMatchTheSameObjectTwice)) ||
        (testCase == @selector(testElementsWaitToMatchValidObjects)) ||
        (testCase == @selector(testElementsThrowIfNoValidObjectIsFoundAtEndOfTimeout)) ||
        (testCase == @selector(testElementWithAccessibilityLabel)) ||
        (testCase == @selector(testElementWithAccessibilityLabelValueTraits)) ||
        (testCase == @selector(testElementWithAccessibilityIdentifier)) ||
        (testCase == @selector(testElementMatchingPredicate)) ||
        (testCase == @selector(testAnyElement)) ||
        (testCase == @selector(testSubliminalOnlyReplacesAccessibilityIdentifiersOfElementsInvolvedInMatch)) ||
        (testCase == @selector(testSubliminalRestoresAccessibilityIdentifiersAfterMatching)) ||
        (testCase == @selector(testSubliminalRestoresAccessibilityIdentifiersAfterMatchingEvenIfActionThrows)) ||
        (testCase == @selector(testMatchingPopoverChildElement_iPad))) {
        return @"SLElementMatchingTestViewController";
    } else if ((testCase == @selector(testMatchingTableViewCellTextLabel)) ||
               (testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
               (testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell)) ||
               (testCase == @selector(testMatchingNonLabelTableViewCellChildElement)) ||
               (testCase == @selector(testMatchingTableViewHeader)) ||
               (testCase == @selector(testMatchingTableViewHeaderChildElements))) {
        return @"SLTableViewChildElementMatchingTestViewController";
    } else {
        return nil;
    }
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(swapButtons)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(applyUniqueTraitToFooButton)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(fooButtonIdentifier)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(removeFooButtonFromSuperview)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(addFooButtonToViewAfterInterval:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(barButtonIdentifier)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(webViewDidFinishLoad)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showPopover)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)loadViewForTestCase:(SEL)testCase {
    if (testCase == @selector(testMatchingWebViewChildElements_iPhone)) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view = _webView;
    } else if (testCase == @selector(testCannotMatchDescendantOfAccessibleElement)) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _parentView = [[UIView alloc] initWithFrame:CGRectMake(10, 200, 200, 100)];
        _parentView.backgroundColor = [UIColor redColor];

        _childView = [[UIView alloc] initWithFrame:_parentView.bounds];
        _childView.backgroundColor = [UIColor blueColor];
        [_parentView addSubview:_childView];

        [view addSubview:_parentView];
        self.view = view;
    }
}

static NSString *TestCellIdentifier = nil;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.text = @"barText";

    self.fooButton.accessibilityIdentifier = @"fooId";
    self.fooButton.accessibilityLabel = @"foo";
    self.fooButton.accessibilityValue = @"fooValue";
    self.fooButton.accessibilityHint = @"fooHint";

    self.barButton.accessibilityIdentifier = @"barId";
    self.barButton.accessibilityLabel = @"bar";

    _parentView.isAccessibilityElement = YES;
    _parentView.accessibilityLabel = @"parentView";

    _childView.isAccessibilityElement = YES;
    _childView.accessibilityLabel = @"childView";

    if (self.tableView) {
        Class testCellClass;
        if ((self.testCase == @selector(testMatchingTableViewCellTextLabel)) ||
            (self.testCase == @selector(testMatchingTableViewHeader)) ||
            (self.testCase == @selector(testMatchingTableViewHeaderChildElements))) {
            testCellClass = [UITableViewCell class];
        } else if ((self.testCase == @selector(testMatchingNonLabelTableViewCellChildElement)) ||
                   (self.testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
                   (self.testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell))) {
            testCellClass = [SLElementMatchingTestCell class];
        } else {
            NSAssert(NO, @"Table view loaded for unexpected test case: %@.", NSStringFromSelector(self.testCase));
        }
        TestCellIdentifier = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(testCellClass), NSStringFromSelector(self.testCase)];
        [self.tableView registerClass:testCellClass forCellReuseIdentifier:TestCellIdentifier];
    }

    if (_webView) {
        NSURL *webArchiveURL = [[NSBundle mainBundle] URLForResource:@"Inklings~iPhone" withExtension:@"webarchive"];
        NSURLRequest *webArchiveRequest = [NSURLRequest requestWithURL:webArchiveURL];
        _webView.delegate = self;
        [_webView loadRequest:webArchiveRequest];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TestCellIdentifier forIndexPath:indexPath];

    if ((self.testCase == @selector(testMatchingTableViewCellTextLabel)) ||
        (self.testCase == @selector(testMatchingTableViewHeader)) ||
        (self.testCase == @selector(testMatchingTableViewHeaderChildElements))) {
        cell.textLabel.text = @"fooLabel";
    } else {
        NSAssert([cell isKindOfClass:[SLElementMatchingTestCell class]],
                 @"Unexpected table view cell class for test case: %@.", NSStringFromSelector(self.testCase));
        [(SLElementMatchingTestCell *)cell configureAccessibility];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;

    if (self.testCase == @selector(testMatchingTableViewHeader)) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = @"fooHeader";
        [label sizeToFit];
        headerView = label;
    } else if (self.testCase == @selector(testMatchingTableViewHeaderChildElements)) {
        CGFloat headerHeight = [self tableView:tableView heightForHeaderInSection:section];
        CGRect headerRect = (CGRect){
            CGPointZero,
            CGSizeMake(CGRectGetWidth(tableView.frame), headerHeight)
        };
        headerView = [[UIView alloc] initWithFrame:headerRect];
        CGRect contentRect = CGRectInset(headerRect, 20.0f, 0.0f);
        CGFloat halfWidth = CGRectGetWidth(contentRect) / 2.0;
        CGSize halfSize = CGSizeMake(halfWidth, CGRectGetHeight(contentRect));

        UILabel *labelLeft = [[UILabel alloc] initWithFrame:(CGRect){
            contentRect.origin,
            halfSize
        }];
        labelLeft.textAlignment = NSTextAlignmentLeft;
        labelLeft.text = @"left";
        [headerView addSubview:labelLeft];

        UILabel *labelRight = [[UILabel alloc] initWithFrame:(CGRect){
            CGPointMake(CGRectGetMinX(contentRect) + halfWidth, CGRectGetMinY(contentRect)),
            halfSize
        }];
        labelRight.textAlignment = NSTextAlignmentRight;
        labelRight.text = @"right";
        [headerView addSubview:labelRight];
    }

    return headerView;
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewDidFinishLoad = YES;
}

#pragma mark - App hooks

- (void)swapButtons {
    CGRect buttonFrame = self.fooButton.frame;
    NSString *buttonLabel = self.fooButton.accessibilityLabel;
    [self.fooButton removeFromSuperview];

    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newButton.frame = buttonFrame;
    newButton.accessibilityLabel = buttonLabel;
    newButton.accessibilityValue = @"foo2Value";
    [self.view addSubview:newButton];
    self.fooButton = newButton;
}

- (void)applyUniqueTraitToFooButton {
    // `UIAccessibilityTraitUpdatesFrequently` is not appropriate for the button
    // but it is a rare trait, useful in testing
    self.fooButton.accessibilityTraits = (self.fooButton.accessibilityTraits | UIAccessibilityTraitUpdatesFrequently);
}

- (NSString *)fooButtonIdentifier {
    return self.fooButton.accessibilityIdentifier;
}

- (void)removeFooButtonFromSuperview {
    [self.fooButton removeFromSuperview];
}

- (void)addFooButtonToView {
    [self.view addSubview:self.fooButton];
}

- (void)addFooButtonToViewAfterInterval:(NSNumber *)intervalNumber {
    [self performSelector:@selector(addFooButtonToView) withObject:nil afterDelay:[intervalNumber doubleValue]];
}

- (NSString *)barButtonIdentifier {
    return self.barButton.accessibilityIdentifier;
}

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

- (void)showPopover {
    // Inception!
    SLElementMatchingTestViewController *contentViewController = [[SLElementMatchingTestViewController alloc] initWithTestCaseWithSelector:self.testCase];

    _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    _popoverController.popoverContentSize = CGSizeMake(320.0f, 480.0f);
    [_popoverController presentPopoverFromRect:self.fooButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];

    // we must rename the button after the view has loaded
    contentViewController.fooButton.accessibilityLabel = @"fooInPopover";

    // register this here vs. in init so the controller we just presented doesn't steal it
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hidePopover)];
}

- (void)hidePopover {
    [_popoverController dismissPopoverAnimated:NO];
}

@end
