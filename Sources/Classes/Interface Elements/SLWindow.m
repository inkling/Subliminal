//
//  SLWindow.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLWindow.h"
#import "SLElement+Subclassing.h"

@implementation SLWindow

+ (SLWindow *)mainWindow {
    return [self elementMatching:^BOOL(NSObject *obj) {
        return (obj == [[UIApplication sharedApplication] keyWindow]);
    } withDescription:@"Main Window"];
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UIWindow class]];
}

@end
