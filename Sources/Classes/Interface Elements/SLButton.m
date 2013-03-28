//
//  SLButton.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLButton.h"
#import "SLElement+Subclassing.h"

@implementation SLButton

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object] && ([object accessibilityTraits] & UIAccessibilityTraitButton));
}

@end
