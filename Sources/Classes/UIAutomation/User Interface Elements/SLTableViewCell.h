//
//  SLTableViewCell.h
//  Subliminal
//
//  Created by Jordan Zucker on 4/2/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLAccessibilityContainer.h"

@interface SLTableViewCell : SLAccessibilityContainer


+ (instancetype)cellWithElement:(SLElement *)element;
//+ (instancetype)cellWithElement:(SLElement *)element inTableViewWithIdentifier:(NSString *)identifier;

+ (instancetype)cellWithIdentifier:(NSString *)identifer;
+ (instancetype)cellWithLabel:(NSString *)label;
+ (instancetype)cellWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

//+ (instancetype)tableViewCellAtIndexPath:(NSIndexPath *)indexPath;

//- (id)childElementMatching:(SLElement *)childElement;
+ (id)childElementMatching:(SLElement *)childElement inContainerElement:(SLElement *)containerElement;

@end
