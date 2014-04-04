//
//  SLTableViewCell.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/2/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTableViewCell.h"
#import "SLUIAElement+Subclassing.h"
#import "NSObject+SLAccessibilityHierarchy.h"

@implementation SLTableViewCell

+ (instancetype)cellWithElement:(SLElement *)element
{
    return [SLTableViewCell containerWithElement:element andContainerType:SLTableViewAccessibilityContainer];
}

+ (instancetype)cellWithIdentifier:(NSString *)identifer
{
    return [SLTableViewCell containerWithIdentifier:identifer andContainerType:SLTableViewAccessibilityContainer];
}
+ (instancetype)cellWithLabel:(NSString *)label
{
    return [SLTableViewCell containerWithLabel:label andContainerType:SLTableViewAccessibilityContainer];
}
+ (instancetype)cellWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits
{
    return [SLTableViewCell containerWithLabel:label value:value traits:traits andContainerType:SLTableViewAccessibilityContainer];
}
+ (id)childElementMatching:(SLElement *)childElement inContainerElement:(SLElement *)containerElement
{
    return [SLTableViewCell childElementMatching:childElement inContainerElement:containerElement ofContainerType:SLTableViewAccessibilityContainer];
}

//+ (id)tableViewCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    SLTableViewCell *cell = [SLTableViewCell elementMatching:^BOOL(NSObject *obj) {
//        id accessibilityParent = [obj slAccessibilityParent];
//
//        // then look for child element having matching parent
//        while (accessibilityParent && ![accessibilityParent isKindOfClass:[UITableView class]]) {
//
//            accessibilityParent = [accessibilityParent slAccessibilityParent];
//
//        }
//        if ([accessibilityParent isKindOfClass:[UITableView class]]) {
//            //NSIndexPath *
//            NSLog(@"----------------------------------------------- Properties for object %@", self);
//
//            @autoreleasepool {
//                unsigned int numberOfProperties = 0;
//                objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
//                for (NSUInteger i = 0; i < numberOfProperties; i++) {
//                    objc_property_t property = propertyArray[i];
//                    NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
//                    NSLog(@"Property %@ Value: %@", name, [self valueForKey:name]);
//                    SLLogAsync(@"Property %@ Value: %@", name, [self valueForKey:name]);
//                }
//                free(propertyArray);
//            }    
//            NSLog(@"-----------------------------------------------");
//            return NO;
//            //return [indexPath compare:[]];
//        }
//        return NO;
//    } withDescription:@"container"];
//    cell.containerType = SLTableViewAccessibilityContainer;
//    return cell;
//}

@end
