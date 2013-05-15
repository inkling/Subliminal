//
//  SLTextField.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTextField.h"
#import "SLElement+Subclassing.h"

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


#pragma mark - SLSearchBar

@implementation SLSearchBar

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
