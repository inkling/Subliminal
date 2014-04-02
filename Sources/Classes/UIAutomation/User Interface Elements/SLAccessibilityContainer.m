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

- (instancetype)initContainerWithElement:(SLElement *)element andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    self = [super init];
    if (self) {
        _containerElement = element;
        _containerType = accessibilityContainerType;
    }
    return self;
}

+ (instancetype)containerWithElement:(SLElement *)element andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    return [[self alloc] initContainerWithElement:element andContainerType:accessibilityContainerType];
}

+ (instancetype)containerWithIdentifier:(NSString *)identifer andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    return [[self alloc] initContainerWithElement:[SLElement elementWithAccessibilityIdentifier:identifer] andContainerType:accessibilityContainerType];
}
+ (instancetype)containerWithLabel:(NSString *)label andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    return [[self alloc] initContainerWithElement:[SLElement elementWithAccessibilityLabel:label] andContainerType:accessibilityContainerType];
}
+ (instancetype)containerWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits andContainerType:(SLAccessibilityContainerType)accessibilityContainerType
{
    return [[self alloc] initContainerWithElement:[SLElement elementWithAccessibilityLabel:label value:value traits:traits] andContainerType:accessibilityContainerType];
}

- (id)childElementMatching:(SLElement *)childElement
{
    return [SLElement elementMatching:^BOOL(NSObject *obj) {
        // first match child element
        if ([childElement matchesObject:obj]) {

            id accessibilityParent = [obj slAccessibilityParent];

            //SLLogAsync(@"starting: accessibilityParent is %@", accessibilityParent);
            // then look for child element having matching parent
            while (accessibilityParent && ![_containerElement matchesObject:accessibilityParent]) {

                accessibilityParent = [accessibilityParent slAccessibilityParent];
                //SLLogAsync(@"get accessibilityParent that is now %@", accessibilityParent);

            }


            id doubleAccessibilityParent = [accessibilityParent slAccessibilityParent];

            Class compareClass;
            switch (_containerType) {
                case SLTableViewAccessibilityContainer:
                    compareClass = [UITableView class];
                    break;
                case SLCollectionViewAccessibilityContainer:
                    compareClass = [UICollectionView class];
                    break;
                    
                default:
                    compareClass = [UIView class];
                    break;
            }

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
