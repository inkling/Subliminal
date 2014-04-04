//
//  SLTableViewCell.h
//  Subliminal
//
//  Created by Jordan Zucker on 4/2/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLAccessibilityContainer.h"

@interface SLTableViewCell : SLAccessibilityContainer


+ (instancetype)tableViewCellWithElement:(SLElement *)element;

+ (instancetype)tableViewCellWithIdentifier:(NSString *)identifer;
+ (instancetype)tableViewCellWithLabel:(NSString *)label;
+ (instancetype)tableViewCellWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

//+ (instancetype)tableViewCellAtIndexPath:(NSIndexPath *)indexPath;

//- (id)childElementMatching:(SLElement *)childElement;
+ (id)childElementMatching:(SLElement *)childElement inContainerElement:(SLElement *)containerElement;

@end
