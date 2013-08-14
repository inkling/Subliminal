//
//  SLTextViewTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 7/29/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLTextViewTestViewController : SLTestCaseViewController

@end

@interface SLTextViewTestViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation SLTextViewTestViewController {
    UIWebView *_webView;
    BOOL _webViewDidFinishLoad;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    NSString *nibName = nil;
    if ((testCase == @selector(testSetText)) ||
        (testCase == @selector(testSetTextClearsCurrentText)) ||
        (testCase == @selector(testGetText)) ||
        (testCase == @selector(testDoNotMatchEditorAccessibilityObjects))) {
        nibName = @"SLTextViewTestViewController";
    }
    return nibName;
}

- (void)loadViewForTestCase:(SEL)testCase {
    if ((testCase == @selector(testMatchesWebTextView)) ||
        (testCase == @selector(testSetWebTextViewText)) ||
        (testCase == @selector(testSetWebTextViewTextClearsCurrentText)) ||
        (testCase == @selector(testGetWebTextViewText))) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

        _webView = [[UIWebView alloc] initWithFrame:view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:_webView];

        self.view = view;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _textView.accessibilityLabel = @"test element";

    NSString *webViewHTMLPath = [[NSBundle mainBundle] pathForResource:@"SLWebTextView" ofType:@"html"];
    NSURL *webViewHTMLURL = [NSURL fileURLWithPath:webViewHTMLPath];
    NSURLRequest *webViewRequest = [NSURLRequest requestWithURL:webViewHTMLURL];
    _webView.delegate = self;
    [_webView loadRequest:webViewRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewDidFinishLoad = YES;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(text)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(setText:)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(webViewDidFinishLoad)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSString *)text {
    NSString *text;
    if ((self.testCase == @selector(testSetText)) ||
        (self.testCase == @selector(testSetTextClearsCurrentText)) ||
        (self.testCase == @selector(testGetText)) ||
        (self.testCase == @selector(testDoNotMatchEditorAccessibilityObjects))) {
        text = self.textView.text;
    } else if ((self.testCase == @selector(testMatchesWebTextView)) ||
               (self.testCase == @selector(testSetWebTextViewText)) ||
               (self.testCase == @selector(testSetWebTextViewTextClearsCurrentText)) ||
               (self.testCase == @selector(testGetWebTextViewText))) {
        text = [_webView stringByEvaluatingJavaScriptFromString:@"getText()"];
    }
    return text;
}

- (void)setText:(NSString *)text {
    if ((self.testCase == @selector(testSetText)) ||
        (self.testCase == @selector(testSetTextClearsCurrentText)) ||
        (self.testCase == @selector(testGetText)) ||
        (self.testCase == @selector(testDoNotMatchEditorAccessibilityObjects))) {
        self.textView.text = text;
    } else if ((self.testCase == @selector(testMatchesWebTextView)) ||
               (self.testCase == @selector(testSetWebTextViewText)) ||
               (self.testCase == @selector(testSetWebTextViewTextClearsCurrentText)) ||
               (self.testCase == @selector(testGetWebTextViewText))) {
        NSString *setTextString = [NSString stringWithFormat:@"setText('%@')", [text slStringByEscapingForJavaScriptLiteral]];
        (void)[_webView stringByEvaluatingJavaScriptFromString:setTextString];
    }
}

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

@end
