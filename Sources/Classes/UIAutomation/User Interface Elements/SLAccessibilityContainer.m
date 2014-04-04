//
//  SLAccessibilityContainer.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/2/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLAccessibilityContainer.h"
#import "SLUIAElement+Subclassing.h"
#import "NSObject+SLAccessibilityHierarchy.h"

@implementation SLAccessibilityContainer

+ (instancetype)containerWithElement:(SLElement *)element andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    SLAccessibilityContainer *container = [SLAccessibilityContainer elementMatching:^BOOL(NSObject *obj) {
        return [element matchesObject:obj];
    } withDescription:@"container"];
    container.containerType = accessibilityContainerType;
    return container;
}

+ (instancetype)containerWithIdentifier:(NSString *)identifer andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    SLAccessibilityContainer *container = [SLAccessibilityContainer elementMatching:^BOOL(NSObject *obj) {
        return [[SLElement elementWithAccessibilityIdentifier:identifer] matchesObject:obj];
    } withDescription:@"container"];
    container.containerType = accessibilityContainerType;
    return container;
}
+ (instancetype)containerWithLabel:(NSString *)label andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    SLAccessibilityContainer *container = [SLAccessibilityContainer elementMatching:^BOOL(NSObject *obj) {
        return [[SLElement elementWithAccessibilityLabel:label] matchesObject:obj];
    } withDescription:@"container"];
    container.containerType = accessibilityContainerType;
    return container;
}
+ (instancetype)containerWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    SLAccessibilityContainer *container = [SLAccessibilityContainer elementMatching:^BOOL(NSObject *obj) {
        return [[SLElement elementWithAccessibilityLabel:label value:value traits:traits] matchesObject:obj];
    } withDescription:@"container"];
    container.containerType = accessibilityContainerType;
    return container;
}

- (id)childElementMatching:(SLElement *)childElement
{
    return [SLElement elementMatching:^BOOL(NSObject *obj) {
        // first match child element
        if ([childElement matchesObject:obj]) {

            id accessibilityParent = [obj slAccessibilityParent];

            // then look for child element having matching parent
            while (accessibilityParent && ![self matchesObject:accessibilityParent]) {

                accessibilityParent = [accessibilityParent slAccessibilityParent];

            }
            Class compareClass;
            switch (_containerType) {
                case SLTableViewAccessibilityContainer:
                    compareClass = [UITableView class];
                    break;
                case SLCollectionViewAccessibilityContainer:
                    compareClass = [UICollectionView class];
                    break;
                case SLNavigationBarContainer:
                    compareClass = [UINavigationBar class];
                    break;
                case SLTabBarContainer:
                    compareClass = [UITabBar class];
                    break;
                case SLToolbarContainer:
                    compareClass = [UIToolbar class];
                    break;

                default:
                    compareClass = [UIView class];
                    break;
            }
            if ((_containerType == SLNavigationBarContainer) || (_containerType == SLTabBarContainer) || (_containerType == SLToolbarContainer)) {
                return [accessibilityParent isKindOfClass:compareClass];
            }


            id doubleAccessibilityParent = [accessibilityParent slAccessibilityParent];

            while (doubleAccessibilityParent && ![doubleAccessibilityParent isKindOfClass:compareClass]) {
                doubleAccessibilityParent = [doubleAccessibilityParent slAccessibilityParent];
            }

            if (doubleAccessibilityParent) {
                return YES;
            }
            else {
                return NO;
            }
            
            
        }
        
        return NO;
    } withDescription:@"searching for child element"];
}
+ (id)childElementMatching:(SLElement *)childElement inContainerElement:(SLElement *)containerElement ofContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    SLAccessibilityContainer *container = [SLAccessibilityContainer containerWithElement:containerElement andContainerType:accessibilityContainerType];
    return [container childElementMatching:childElement];
}

@end
