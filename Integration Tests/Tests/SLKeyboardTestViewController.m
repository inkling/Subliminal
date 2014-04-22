//
//  SLKeyboardTestViewController.m
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

@interface SLKeyboardTestViewController : SLTestCaseViewController

@end

@implementation SLKeyboardTestViewController {
    UITextField *_textField;
    NSDictionary *_keyboardInfo;
}

- (void)loadViewForTestCase:(SEL)testCase {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

    _textField = [[UITextField alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(100.0f, 30.0f)}];
    [view addSubview:_textField];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _textField.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _textField.center = self.view.center;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showKeyboard)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hideKeyboard)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(keyboardInfo)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(text)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showKeyboard {
    [_textField becomeFirstResponder];
}

- (void)hideKeyboard {
    [_textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _keyboardInfo = [notification userInfo];
}

- (NSDictionary *)keyboardInfo {
    return _keyboardInfo;
}

- (NSString *)text {
    return _textField.text;
}

@end
