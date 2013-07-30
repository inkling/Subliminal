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
#import "SLKeyboard.h"

@implementation SLTextField

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    // Normally we want to tap on the view that backs this SLTextField before
    // attempting to edit the field.  That way we can be confident that the
    // view will be first responder.  The only exception is when the backing
    // view is a UITextField and is *already* editing, because in that case
    // the view is already first responder and a real user would probably not
    // tap again before typing.
    __block BOOL tapBeforeSettingText;
    [self examineMatchingObject:^(NSObject *object) {
        tapBeforeSettingText = !([object isKindOfClass:[UITextField class]] && [(UITextField *)object isEditing]);
    }];
    if (tapBeforeSettingText) {
        [self tap];
    }
    [[SLKeyboard keyboard] typeString:text];
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


@implementation SLWebTextField
// SLWebTextField does not inherit from SLTextField
// because the elements it matches, web text fields, are not instances of UITextField
// but rather a private type of accessibility element.

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    [self tap];
    [[SLKeyboard keyboard] typeString:text];
}

@end
