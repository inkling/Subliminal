//
//  SLWebView.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLWebView.h"
#import "SLElement+Subclassing.h"

@implementation SLWebView

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UIWebView class]];
}

@end
