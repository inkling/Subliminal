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
    [self tap]; // become first responder
    [[SLKeyboard keyboard] typeString:text];
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UITextView class]];
}

@end
