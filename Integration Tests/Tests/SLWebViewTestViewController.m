//
//  SLWebViewTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/11/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLWebViewTestViewController : SLTestCaseViewController <UIWebViewDelegate>

@end

@implementation SLWebViewTestViewController {
    UIWebView *_webView;
    BOOL _webViewDidFinishLoad;
}

- (void)loadViewForTestCase:(SEL)testCase {
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
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
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(webViewDidFinishLoad)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(webViewLabel)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewDidFinishLoad = YES;
}

#pragma mark - App hooks

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

- (NSString *)webViewLabel {
    return _webView.accessibilityLabel;
}

@end
