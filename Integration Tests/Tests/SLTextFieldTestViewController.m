//
//  SLTextFieldTestViewController.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

@interface SLTextFieldTestViewController : SLTestCaseViewController <UIWebViewDelegate,UITableViewDataSource,UICollectionViewDataSource>
@end

@implementation SLTextFieldTestViewController {
    UITextField *_textField;
    UISearchBar *_searchBar;
    UIWebView *_webView;
    UITableView *_tableView;
    UICollectionView *_collectionView;
    BOOL _webViewDidFinishLoad;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    const CGRect kTextFieldFrame = (CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)};

    if (testCase == @selector(testSetText) ||
        testCase == @selector(testSetTextWithinTableViewCell) ||
        testCase == @selector(testSetTextWithinCollectionViewCell) ||
        testCase == @selector(testSetTextCanHandleTapHoldCharacters) ||
        testCase == @selector(testSetTextClearsCurrentText) ||
        testCase == @selector(testSetTextClearsCurrentTextWithinTableViewCell) ||
        testCase == @selector(testSetTextClearsCurrentTextWithinCollectionViewCell) ||
        testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        testCase == @selector(testGetText) ||
        testCase == @selector(testDoNotMatchEditorAccessibilityObjects) ||
        testCase == @selector(testClearTextButton) ||
        // we'll test that we match the searchBar *and not* the textField
        testCase == @selector(testMatchesSearchBarTextField)) {
        
        _textField = [[UITextField alloc] initWithFrame:kTextFieldFrame];

        if (testCase == @selector(testSetTextWithinTableViewCell) ||
            testCase == @selector(testSetTextClearsCurrentTextWithinTableViewCell)) {
            _tableView = [[UITableView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(320.0f, 44.0f)}];
            _tableView.dataSource = self;
            [view addSubview:_tableView];
        } else if (testCase == @selector(testSetTextWithinCollectionViewCell) ||
                   testCase == @selector(testSetTextClearsCurrentTextWithinCollectionViewCell)) {
            _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(320.0f, 44.0f)} collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
            [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TestCell"];
            _collectionView.dataSource = self;
            [view addSubview:_collectionView];
        } else {
            [view addSubview:_textField];
        }

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
               testCase == @selector(testSetWebTextFieldTextClearsCurrentText) ||
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
    if (self.testCase == @selector(testClearTextButton)) {
        _textField.clearButtonMode = UITextFieldViewModeAlways;
    } else if (self.testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing)) {
        _textField.clearsOnBeginEditing = YES;
    }

    if (self.testCase != @selector(testSetText) &&
        self.testCase != @selector(testSetTextWithinTableViewCell) &&
        self.testCase != @selector(testSetTextWithinCollectionViewCell) &&
        self.testCase != @selector(testSetTextClearsCurrentText) &&
        self.testCase != @selector(testSetTextClearsCurrentTextWithinTableViewCell) &&
        self.testCase != @selector(testSetTextClearsCurrentTextWithinCollectionViewCell) &&
        self.testCase != @selector(testSetTextWhenFieldClearsOnBeginEditing) &&
        self.testCase != @selector(testDoNotMatchEditorAccessibilityObjects)) {
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

    if ((_tableView != nil) || (_collectionView != nil))
        return;

    // move the textfield above the keyboard
    static const CGFloat kTextFieldVerticalOffset = -80.0f;

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
        self.testCase == @selector(testSetTextWithinTableViewCell) ||
        self.testCase == @selector(testSetTextWithinCollectionViewCell) ||
        self.testCase == @selector(testSetTextCanHandleTapHoldCharacters) ||
        self.testCase == @selector(testSetTextClearsCurrentText) ||
        self.testCase == @selector(testSetTextClearsCurrentTextWithinTableViewCell) ||
        self.testCase == @selector(testSetTextClearsCurrentTextWithinCollectionViewCell) ||
        self.testCase == @selector(testSetTextWhenFieldClearsOnBeginEditing) ||
        self.testCase == @selector(testGetText) ||
        self.testCase == @selector(testDoNotMatchEditorAccessibilityObjects) ||
        self.testCase == @selector(testClearTextButton)) {
        text = _textField.text;
    } else if (self.testCase == @selector(testMatchesSearchBarTextField) ||
               self.testCase == @selector(testSetSearchBarText) ||
               self.testCase == @selector(testGetSearchBarText)) {
        text = _searchBar.text;
    } else if (self.testCase == @selector(testMatchesWebTextField) ||
               self.testCase == @selector(testSetWebTextFieldText) ||
               self.testCase == @selector(testSetWebTextFieldTextClearsCurrentText) ||
               self.testCase == @selector(testGetWebTextFieldText)) {
        text = [_webView stringByEvaluatingJavaScriptFromString:@"getText()"];
    }
    return text;
}

- (NSNumber *)webViewDidFinishLoad {
    return @(_webViewDidFinishLoad);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(320.0f, 44.0f)}];
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableViewCell.contentView.backgroundColor = [UIColor lightGrayColor];

    _textField.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)};
    _textField.textColor = [UIColor blackColor];
    [_textField becomeFirstResponder];

    [tableViewCell.contentView addSubview:_textField];

    return tableViewCell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TestCell" forIndexPath:indexPath];
    collectionViewCell.frame = CGRectMake(0, 0, 320.0f, 44.0f);
    collectionViewCell.contentView.backgroundColor = [UIColor lightGrayColor];

    _textField.frame = (CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)};
    _textField.textColor = [UIColor blackColor];
    [_textField becomeFirstResponder];

    [collectionViewCell.contentView addSubview:_textField];

    return collectionViewCell;
}

@end
