//
//  SLTextFieldTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/25/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>
#import <QuartzCore/QuartzCore.h>

@interface SLTextFieldTestViewController : SLTestCaseViewController <UIWebViewDelegate>
@end

@implementation SLTextFieldTestViewController {
    UITextField *_textField;
    UISearchBar *_searchBar;
    UIWebView *_webView;
    BOOL _webViewDidFinishLoad;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    const CGRect kTextFieldFrame = (CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)};
    if (testCase == @selector(testSetText) ||
        testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        testCase == @selector(testCanSetTextOnlyWhenTappable) ||
        testCase == @selector(testGetText) ||
        // we'll test that we match the searchBar *and not* the textField
        testCase == @selector(testMatchesSearchBarTextField)) {
        
        _textField = [[UITextField alloc] initWithFrame:kTextFieldFrame];
        [view addSubview:_textField];

        if (testCase == @selector(testMatchesSearchBarTextField)) {
            _searchBar = [[UISearchBar alloc] initWithFrame:kTextFieldFrame];
            [view addSubview:_searchBar];
        }
    } else if (testCase == @selector(testSetSearchBarText) ||
               testCase == @selector(testGetSearchBarText)) {
        _searchBar = [[UISearchBar alloc] initWithFrame:kTextFieldFrame];
        [view addSubview:_searchBar];
    } else if (testCase == @selector(testMatchesWebTextField) ||
               testCase == @selector(testSetWebTextFieldText) ||
               testCase == @selector(testGetWebTextFieldText)) {
        _webView = [[UIWebView alloc] initWithFrame:view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:_webView];
    }
    self.view = view;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(text)];
        [testController registerTarget:self forAction:@selector(showTextField)];
        [testController registerTarget:self forAction:@selector(webViewDidFinishLoad)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _textField.accessibilityLabel = @"test element";
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    if (self.testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing)) {
        _textField.clearsOnBeginEditing = YES;
    }
    if (self.testCase == @selector(testCanSetTextOnlyWhenTappable)) {
        _textField.hidden = YES;
    }

    if (self.testCase != @selector(testSetText) &&
        self.testCase != @selector(testSetTextWhenFieldClearsOnBeginEditing) &&
        self.testCase != @selector(testCanSetTextOnlyWhenTappable)) {
        _textField.text = @"foo";
    }

    // note that it's not useful to set the accessibility label of the search bar,
    // as we actually match the (private) textfield inside the search bar

    if (self.testCase != @selector(testSetSearchBarText)) {
        _searchBar.text = @"bar";
    }

    NSString *webViewHTMLPath = [[NSBundle mainBundle] pathForResource:@"SLWebTextField" ofType:@"html"];
    NSURL *webViewHTMLURL = [NSURL fileURLWithPath:webViewHTMLPath];
    NSURLRequest *webViewRequest = [NSURLRequest requestWithURL:webViewHTMLURL];
    _webView.delegate = self;
    [_webView loadRequest:webViewRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *setTestCaseJS = [NSString stringWithFormat:@"setTestCase(\"%@\")", NSStringFromSelector(self.testCase)];
    [_webView stringByEvaluatingJavaScriptFromString:setTestCaseJS];
    _webViewDidFinishLoad = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _textField.center = self.view.center;
    if (_textField) {
        _searchBar.center = CGPointMake(_textField.center.x, _textField.center.y - 50.0f);
    } else {
        _searchBar.center = self.view.center;
    }
}

#pragma mark - App hooks

- (NSString *)text {
    NSString *text;
    if (self.testCase == @selector(testSetText) ||
        self.testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        self.testCase == @selector(testCanSetTextOnlyWhenTappable) ||
        self.testCase == @selector(testGetText)) {
        text = _textField.text;
    } else if (self.testCase == @selector(testMatchesSearchBarTextField) ||
               self.testCase == @selector(testSetSearchBarText) ||
               self.testCase == @selector(testGetSearchBarText)) {
        text = _searchBar.text;
    } else if (self.testCase == @selector(testMatchesWebTextField) ||
               self.testCase == @selector(testSetWebTextFieldText) ||
               self.testCase == @selector(testGetWebTextFieldText)) {
        text = [_webView stringByEvaluatingJavaScriptFromString:@"getText()"];
    }
    return text;
}

- (void)showTextField {
    _textField.hidden = NO;
}

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

@end
