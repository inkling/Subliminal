//
//  SLTableViewCell.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/2/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTableViewCell.h"

@implementation SLTableViewCell

- (instancetype)initTableViewCellWithElement:(SLElement *)element
{
    return [self initContainerWithElement:element andContainerType:SLTableViewAccessibilityContainer];
}

+ (instancetype)tableViewCellWithElement:(SLElement *)element
{
    return [SLTableViewCell containerWithElement:element andContainerType:SLTableViewAccessibilityContainer];
}

+ (instancetype)tableViewCellWithIdentifier:(NSString *)identifer
{
    return [SLTableViewCell containerWithIdentifier:identifer andContainerType:SLTableViewAccessibilityContainer];
}
+ (instancetype)tableViewCellWithLabel:(NSString *)label
{
    return [SLTableViewCell containerWithLabel:label andContainerType:SLTableViewAccessibilityContainer];
}
+ (instancetype)tableViewCellWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits
{
    return [SLTableViewCell containerWithLabel:label value:value traits:traits andContainerType:SLTableViewAccessibilityContainer];
}
+ (id)childElementMatching:(SLElement *)childElement inContainerElement:(SLElement *)containerElement
{
    return [SLTableViewCell childElementMatching:childElement inContainerElement:containerElement ofContainerType:SLTableViewAccessibilityContainer];
}

@end
