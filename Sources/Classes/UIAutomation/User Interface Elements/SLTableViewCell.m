//
//  SLTableViewCell.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/24/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTableViewCell.h"
#import "NSObject+SLAccessibilityHierarchy.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLTableViewCell

- (BOOL)matchesObject:(NSObject *)object
{
    if (![super matchesObject:object]) {
        return NO;
    }
    // When we are matching for corresponding `UITableViewCell` instances for
    // isVisible checking and such, we need to take iOS version into account.
    // On iOS 6 `UITableViewCell` is a direct descendant of `UITableView`.
    // On iOS 7, there is a `UITableViewWrapperView` between `UITableView`
    // and `UITableViewCell`.
    id accessibilityParent = [object slAccessibilityParent];
    if (accessibilityParent && [accessibilityParent isKindOfClass:[UITableView class]]) {
        return YES;
    }
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
        id doubleAccessibilityParent = [accessibilityParent slAccessibilityParent];
        return [doubleAccessibilityParent isKindOfClass:[UITableView class]];
    }

    return NO;
}

- (id)childElementMatching:(SLElement *)childElement
{
    return [SLElement elementMatching:^BOOL(NSObject *obj) {
        if ([childElement matchesObject:obj]) {
            id objAccessibilityParent = [obj slAccessibilityParent];
            // On iOS 6, views and accessibility mock views are
            // direct children of `UITableViewCell`.
            // On iOS 7, there is a `UITableViewCellScrollView` that is
            // a child of `UITableViewCell` and all views contained therein
            // are children of that `UITableViewCellScrollView`, which is
            // a hidden class
            if ([self matchesObject:objAccessibilityParent]) {
                return YES;
            }
            if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) {
                // UITableViewCellScrollView
                id doubleAccessibilityParent = [objAccessibilityParent slAccessibilityParent];
                return [self matchesObject:doubleAccessibilityParent];
            }
            return NO;
        }
        return NO;
    } withDescription:@"container child"];
}

@end
