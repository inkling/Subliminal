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
    return [SLWindow elementMatching:^BOOL(NSObject *obj) {
        return YES;
    } withDescription:@"Main Window"];
}


- (NSString *)staticUIASelf {
    return @"UIATarget.localTarget().frontMostApp().mainWindow()";
}

@end
