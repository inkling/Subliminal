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
    __block BOOL isEnabled = NO;
    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        isEnabled = [[[SLTerminal sharedTerminal] evalWithFormat:@"(%@.isEnabled() ? 'YES' : 'NO')", uiaSelf] boolValue];
    }];
    return isEnabled;
}

@end
