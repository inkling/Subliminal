//
//  UIAccessibilityElement+SLElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLElement;


#pragma mark - UIAccessibilityElement (SLElement)

@interface UIAccessibilityElement (SLElement)

- (NSString *)slAccessibilityName;

- (BOOL)matchesSLElement:(SLElement *)element;

@end


#pragma mark - UIApplication (SLElement)

@interface UIApplication (SLElement)

- (UIAccessibilityElement *)accessibilityElementMatchingSLElement:(SLElement *)slElement;

@end


#pragma mark - UIView (SLElement)

@interface UIView (SLElement)

- (NSString *)slAccessibilityName;

- (UIAccessibilityElement *)accessibilityElementMatchingSLElement:(SLElement *)slElement;

@end
