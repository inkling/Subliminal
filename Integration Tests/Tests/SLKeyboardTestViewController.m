//
//  SLKeyboardTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/16/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

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
