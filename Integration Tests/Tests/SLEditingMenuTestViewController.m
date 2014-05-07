//
//  SLEditingMenuTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/11/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>


@interface SLEditingMenuTestWebView : UIWebView
@property (nonatomic, readonly) BOOL copyItemWasTapped;
@property (nonatomic) BOOL standardMenuItemsDisabled;
@end

@implementation SLEditingMenuTestWebView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.standardMenuItemsDisabled) return NO;

    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender {
    _copyItemWasTapped = YES;
    [super copy:sender];
}

@end


@interface SLEditingMenuTestViewController : SLTestCaseViewController <UIWebViewDelegate>
@property (nonatomic) BOOL standardMenuItemsDisabled;
@end

@implementation SLEditingMenuTestViewController {
    SLEditingMenuTestWebView *_webView;
    BOOL _webViewDidFinishLoad;

    NSArray *_preexistingCustomMenuItems;
    UIMenuItem *_customMenuItem;
    BOOL _customMenuItemWasTapped;
}

- (void)loadViewForTestCase:(SEL)testCase {
    _webView = [[SLEditingMenuTestWebView alloc] initWithFrame:CGRectZero];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *webArchiveURL = [[NSBundle mainBundle] URLForResource:@"Inklings~iPhone" withExtension:@"webarchive"];
    NSURLRequest *webArchiveRequest = [NSURLRequest requestWithURL:webArchiveURL];
    _webView.delegate = self;
    [_webView loadRequest:webArchiveRequest];

    _webView.accessibilityLabel = @"foo";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        _preexistingCustomMenuItems = [[[UIMenuController sharedMenuController] menuItems] copy];

        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(webViewDidFinishLoad)];
        [testController registerTarget:self forAction:@selector(menuItemWasTapped)];
        [testController registerTarget:self forAction:@selector(installCustomMenuItemWithTitle:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];

    [[UIMenuController sharedMenuController] setMenuItems:_preexistingCustomMenuItems];
}

#pragma mark - Editing menu

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.standardMenuItemsDisabled) {
        return action == _customMenuItem.action;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)slCopy:(id)sender {
    [_webView copy:sender];
}

- (void)setStandardMenuItemsDisabled:(BOOL)standardMenuItemsDisabled {
    _standardMenuItemsDisabled = standardMenuItemsDisabled;
    _webView.standardMenuItemsDisabled = standardMenuItemsDisabled;
}

- (void)installCustomMenuItemWithTitle:(NSString *)title {
    self.standardMenuItemsDisabled = YES;

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    // the title is for the test, to recognize and tap the item;
    // the action is for the view controller, to track whether the item was tapped
    _customMenuItem = [[UIMenuItem alloc] initWithTitle:title action:@selector(slCopy:)];
    menuController.menuItems = @[ _customMenuItem ];
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewDidFinishLoad = YES;
}

#pragma mark - App hooks

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

- (NSNumber *)menuItemWasTapped {
    return @(_webView.copyItemWasTapped);
}

@end
