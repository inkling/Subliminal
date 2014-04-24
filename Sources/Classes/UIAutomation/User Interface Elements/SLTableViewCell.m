//
//  SLTableViewCell.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/24/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTableViewCell.h"
#import "NSObject+SLAccessibilityHierarchy.h"

@implementation SLTableViewCell

- (BOOL)matchesObject:(NSObject *)object
{
    id accessibilityParent = [object slAccessibilityParent];
    id objectSuperview = nil;
    if ([object respondsToSelector:@selector(superview)]) {
        objectSuperview = [object performSelector:@selector(superview)];
    }
    id doubleSuperview = nil;
    if ([objectSuperview respondsToSelector:@selector(superview)]) {
        doubleSuperview = [objectSuperview performSelector:@selector(superview)];
    }
    id doubleAccessibilityParent = [accessibilityParent slAccessibilityParent];
    if (![super matchesObject:object]) {
        return NO;
    }
    if ([accessibilityParent isKindOfClass:[UITableView class]] && (objectSuperview == nil)) {
        return YES;
    }
    if ([doubleAccessibilityParent isKindOfClass:[UITableView class]] && ([doubleSuperview isKindOfClass:[UITableView class]])) {
        return YES;
    }
    return NO;
}

- (id)childElementMatching:(SLElement *)childElement
{
    return [SLElement elementMatching:^BOOL(NSObject *obj) {
        if ([childElement matchesObject:obj]) {
            id objAccessibilityParent = [obj slAccessibilityParent];
            id objDoubleAccessibilityParent = [objAccessibilityParent slAccessibilityParent];
            // ax element is direct child
            if ([self matchesObject:objAccessibilityParent]) {
                return YES;
            }
            // real view is two layers deep because of content view
            if ([self matchesObject:objDoubleAccessibilityParent]) {
                return YES;
            }
            return NO;
        }
        return NO;
    } withDescription:@"container child"];
}

@end
