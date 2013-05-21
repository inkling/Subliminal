//
//  SLControl.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLControl.h"
#import "SLElement+Subclassing.h"

@implementation SLControl

- (BOOL)isEnabled {
    return [[self waitUntilTappable:NO thenSendMessage:@"isEnabled()"] boolValue];
}

@end
