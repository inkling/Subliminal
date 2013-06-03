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
    return [[self alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().keyboard()"];
}

- (void)typeString:(NSString *)string { 
    [self waitUntilTappable:YES
            thenSendMessage:@"typeString('%@')", [string slStringByEscapingForJavaScriptLiteral]];
}

@end


@implementation SLKeyboardKey {
    NSString *_keyLabel;
}

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label
{
    return [[self alloc] initWithAccessibilityLabel:label];
}

- (instancetype)initWithAccessibilityLabel:(NSString *)label {
    NSParameterAssert([label length]);
    
    NSString *UIARepresentation = [NSString stringWithFormat:@"UIATarget.localTarget().frontMostApp().keyboard().elements()['%@']", label];
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        _keyLabel = [label copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label:\"%@\">", NSStringFromClass([self class]), _keyLabel];
}

@end
