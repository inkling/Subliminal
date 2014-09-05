//
//  SLAlertTestViewController.m
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

@interface SLAlertTestViewController : SLTestCaseViewController <UIAlertViewDelegate>

@end

@implementation SLAlertTestViewController {
    UIAlertView *_activeAlertView;
    NSString *_titleOfLastButtonClicked;
    NSString *_textEnteredIntoLastTextFieldAtIndex0, *_textEnteredIntoLastTextFieldAtIndex1;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing UIAlertViews in this test,
    // we don't need any particular view.
    [self loadGenericView];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(showAlertWithTitle:)];
        [testController registerTarget:self forAction:@selector(showAlertWithInfo:)];
        [testController registerTarget:self forAction:@selector(dismissActiveAlertAndClearTitleOfLastButtonClicked)];
        [testController registerTarget:self forAction:@selector(isAlertActive)];
        [testController registerTarget:self forAction:@selector(titleOfLastButtonClicked)];
        [testController registerTarget:self forAction:@selector(textEnteredIntoLastTextFieldAtIndex:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showAlertWithTitle:(NSString *)title {
    [self showAlertWithInfo:@{ @"title": title, @"cancel": @"Ok" }];
}

- (void)showAlertWithInfo:(NSDictionary *)info {
    _activeAlertView = [[UIAlertView alloc] initWithTitle:info[@"title"]
                                                  message:info[@"message"]
                                                 delegate:self
                                        cancelButtonTitle:info[@"cancel"]
                                        otherButtonTitles:info[@"other"], nil];
    NSNumber *styleNumber = info[@"style"];
    if (styleNumber) {
        UIAlertViewStyle style;
        [styleNumber getValue:&style];
        _activeAlertView.alertViewStyle = style;
    }
    [_activeAlertView show];
}

- (void)dismissActiveAlertAndClearTitleOfLastButtonClicked {
    if (_activeAlertView.numberOfButtons == 0) {
        // the alert shown by testDismissThrowsAbsentBothCancelAndDefaultButtons has no buttons
        // it appears that it can be dismissed with dismissWithClickedButtonIndex:0 even so,
        // but just to be safe...
        [_activeAlertView addButtonWithTitle:@"Dismiss"];
    }
    [_activeAlertView dismissWithClickedButtonIndex:0 animated:YES];
    _activeAlertView = nil;
    _titleOfLastButtonClicked = nil;
}

- (NSNumber *)isAlertActive {
    return @(_activeAlertView != nil);
}

- (NSString *)titleOfLastButtonClicked {
    return _titleOfLastButtonClicked;
}

- (NSString *)textEnteredIntoLastTextFieldAtIndex:(NSNumber *)index {
    switch ([index unsignedIntegerValue]) {
        case 0:
            return _textEnteredIntoLastTextFieldAtIndex0;
            break;
        case 1:
            return _textEnteredIntoLastTextFieldAtIndex1;
            break;
        default:
            [NSException raise:NSRangeException format:@"UIAlertViews have at max 2 text fields!"];
            return nil;
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _titleOfLastButtonClicked = [alertView buttonTitleAtIndex:buttonIndex];

    switch (alertView.alertViewStyle) {
        case UIAlertViewStyleSecureTextInput:
        case UIAlertViewStylePlainTextInput:
            _textEnteredIntoLastTextFieldAtIndex0 = [[alertView textFieldAtIndex:0] text];
            _textEnteredIntoLastTextFieldAtIndex1 = nil;
            break;
        case UIAlertViewStyleLoginAndPasswordInput:
            _textEnteredIntoLastTextFieldAtIndex0 = [[alertView textFieldAtIndex:0] text];
            _textEnteredIntoLastTextFieldAtIndex1 = [[alertView textFieldAtIndex:1] text];
            break;
        default:
            _textEnteredIntoLastTextFieldAtIndex0 = nil;
            _textEnteredIntoLastTextFieldAtIndex1 = nil;
            break;
    }

    _activeAlertView = nil;
}

@end
