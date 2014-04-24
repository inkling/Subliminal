//
//  SLNavigationBar.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/24/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLNavigationBar.h"
#import "NSObject+SLAccessibilityHierarchy.h"

@implementation SLNavigationBar

- (BOOL)matchesObject:(NSObject *)object
{
    return [super matchesObject:object] && [object isKindOfClass:[UINavigationBar class]];
}

- (id)childElementMatching:(SLElement *)childElement
{
    return [SLElement elementMatching:^BOOL(NSObject *obj) {
        if ([childElement matchesObject:obj]) {
            id accessibilityParent = [obj slAccessibilityParent];
            return [self matchesObject:accessibilityParent];
        }
        return NO;
    } withDescription:@"nav bar child"];
}

@end
