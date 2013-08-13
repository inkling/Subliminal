//
//  SLTextView.m
//  Subliminal
//
//  Created by Jeffrey Wear on 7/29/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTextView.h"
#import "SLUIAElement+Subclassing.h"
#import "SLKeyboard.h"

@implementation SLTextView

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    // Tap to show the keyboard (if the field doesn't already have keyboard focus,
    // because in that case a real user would probably not tap again before typing)
    if (![self hasKeyboardFocus]) {
        [self tap];
    }
    
    [[SLKeyboard keyboard] typeString:text];
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UITextView class]];
}

@end


@implementation SLWebTextView
// `SLWebTextView` does not inherit from `SLTextView`
// because the elements it matches, web text views, are not instances of `UITextView`
// but rather a private type of accessibility element.

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    // Tap to show the keyboard (if the field doesn't already have keyboard focus,
    // because in that case a real user would probably not tap again before typing)
    if (![self hasKeyboardFocus]) {
        [self tap];
    }

    [[SLKeyboard keyboard] typeString:text];
}

@end
