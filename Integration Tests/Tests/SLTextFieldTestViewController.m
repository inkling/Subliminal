//
//  SLTextFieldTestViewController.m
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
        testCase == @selector(testSetTextOfSecureTextField) ||
        testCase == @selector(testGetText) ||
        testCase == @selector(testUIAutomationCannotGetTextTypedIntoSecureTextField) ||
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
    } else if (self.testCase == @selector(testSetTextOfSecureTextField) ||
               self.testCase == @selector(testUIAutomationCannotGetTextTypedIntoSecureTextField)) {
        _textField.secureTextEntry = YES;
    }

    if (self.testCase != @selector(testSetText) &&
        self.testCase != @selector(testSetTextWhenFieldClearsOnBeginEditing) &&
        self.testCase != @selector(testSetTextOfSecureTextField) &&
        self.testCase != @selector(testUIAutomationCannotGetTextTypedIntoSecureTextField)) {
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

    // move the textfield above the keyboard
    static const CGFloat kTextFieldVerticalOffset = -40.0f;

    CGPoint textFieldCenter = CGPointMake(self.view.center.x, self.view.center.y + kTextFieldVerticalOffset);
    _textField.center = textFieldCenter;
    if (_textField) {
        _searchBar.center = CGPointMake(_textField.center.x, _textField.center.y - 50.0f);
    } else {
        _searchBar.center = textFieldCenter;
    }
}

#pragma mark - App hooks

- (NSString *)text {
    NSString *text;
    if (self.testCase == @selector(testSetText) ||
        self.testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        self.testCase == @selector(testSetTextOfSecureTextField) ||
        self.testCase == @selector(testGetText) ||
        self.testCase == @selector(testUIAutomationCannotGetTextTypedIntoSecureTextField)) {
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

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

@end
