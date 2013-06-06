//
//  SLTextField.m
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

#import "SLTextField.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLTextField

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    // If this matches a UITextField with clearsOnBeginEditing set to YES,
    // we must tap the field before attempting to set the text to avoid a race condition
    // between UIKit trying to clear the text and UIAutomation trying to set the text
    __block BOOL waitBeforeSettingText = NO;
    [self examineMatchingObject:^(NSObject *object) {
        if ([object isKindOfClass:[UITextField class]]) {
            waitBeforeSettingText = ((UITextField *)object).clearsOnBeginEditing;
        }
    }];
    if (waitBeforeSettingText) {
        [self tap];
    }
    [self waitUntilTappable:YES thenSendMessage:@"setValue('%@')", [text slStringByEscapingForJavaScriptLiteral]];
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UITextField class]];
}

@end


#pragma mark - SLSearchField

@implementation SLSearchField

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label {
    SLLog(@"An %@ can't be matched by accessibility properties--see the comments on its @interface. \
          Returning +anyElement.", NSStringFromClass(self));
    return [self anyElement];
}

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    SLLog(@"An %@ can't be matched by accessibility properties--see the comments on its @interface. \
          Returning +anyElement.", NSStringFromClass(self));
    return [self anyElement];
}

+ (instancetype)elementWithAccessibilityIdentifier:(NSString *)identifier {
    SLLog(@"An %@ can't be matched by accessibility properties--see the comments on its @interface. \
          Returning +anyElement.", NSStringFromClass(self));
    return [self anyElement];
}

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object] && ([object accessibilityTraits] & UIAccessibilityTraitSearchField));
}

@end


static const NSTimeInterval kWebviewTextfieldDelay = 1;

@implementation SLWebTextField
// SLWebTextField does not inherit from SLTextField
// because the elements it matches, web text fields, are not instances of UITextField
// but rather a private type of accessibility element.

- (NSString *)text {
    return [self value];
}

// Experimentation has shown that SLTextFields within a webview must be tapped, and
// a waiting period is necessary, before setValue() will have any effect. A wait period
// after setting the value is also necessary, otherwise it seems as if regardless of
// correct matching, the next actions sent to UIAutomation will be applied incorrectly
// to this webview textfield.
- (void)setText:(NSString *)text {
    [self tap];
    [NSThread sleepForTimeInterval:kWebviewTextfieldDelay];
    [self waitUntilTappable:YES thenSendMessage:@"setValue('%@')", [text slStringByEscapingForJavaScriptLiteral]];
    [NSThread sleepForTimeInterval:kWebviewTextfieldDelay];
}

@end
