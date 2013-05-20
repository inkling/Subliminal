//
//  SLKeyboard.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLKeyboard.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLKeyboard

+ (SLKeyboard *)keyboard {
    return [SLKeyboard anyElement];
}

- (NSString *)staticUIARepresentation {
    return @"UIATarget.localTarget().frontMostApp().keyboard()";
}

@end

@implementation SLKeyboardKey {
    NSString *_keyLabel;
}

+ (id)elementWithAccessibilityLabel:(NSString *)label
{
    SLKeyboardKey *key = [SLKeyboardKey elementMatching:^BOOL(NSObject *obj) {
        return YES;
    } withDescription:[NSString stringWithFormat:@"Keyboard Key: %@", label]];
    key->_keyLabel = label;
    return key;
}

- (NSString *)staticUIARepresentation {
    return [NSString stringWithFormat:@"UIATarget.localTarget().frontMostApp().keyboard().elements()['%@']", _keyLabel];
}

@end
