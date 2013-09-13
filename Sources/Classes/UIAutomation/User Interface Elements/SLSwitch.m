//
//  SLSwitch.m
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLSwitch.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLSwitch

- (BOOL)isOn
{
    return [[self value] boolValue];
}

- (void)setValue:(BOOL)value
{
    NSString *valueString = value ? @"true" : @"false";
    [self waitUntilTappable:NO thenSendMessage:@"setValue(%@)", valueString];
}

@end
