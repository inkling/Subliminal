//
//  SLAccessibility.m
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//


#import "SLAccessibility.h"

#import "SLElement.h"
#import "NSString+SLJavaScript.h"


@implementation NSObject (SLAccessibility)

- (NSString *)slAccessibilityName {
    return self.accessibilityLabel;
}

- (NSArray *)slChildAccessibilityElements {
    NSMutableArray *children = [NSMutableArray array];
    NSInteger count = [self accessibilityElementCount];
    if (count != NSNotFound && count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            [children addObject:[self accessibilityElementAtIndex:i]];
        }
    }
    return children;
}

- (NSArray *)slAccessibilityChainToElement:(SLElement *)element {
    if ([element matchesObject:self]) {
        return [NSArray arrayWithObject:self];
    }
    
    for (NSObject *child in self.slChildAccessibilityElements) {
        NSArray *chain = [child slAccessibilityChainToElement:element];
        if (chain) {
            NSMutableArray *chainWithSelf = [chain mutableCopy];
            [chainWithSelf insertObject:self atIndex:0];
            return chainWithSelf;
        }
    }
    return nil;
}

- (NSString *)slAccessibilityDescription {
    NSInteger count = [self accessibilityElementCount];
    if (![self isAccessibilityElement] && (count == NSNotFound || count == 0) && ![self respondsToSelector:@selector(accessibilityIdentifier)]) {
        return [NSString stringWithFormat:@"<%@: %p; (not accessible)>", NSStringFromClass([self class]), self];
    }
    
    // Build a semicolon separated list of properties
    NSMutableArray *properties = [NSMutableArray array];
    
    [properties addObject:[NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self]];
    CGRect frame = [self accessibilityFrame];
    [properties addObject:[NSString stringWithFormat:@"frame = (%g %g; %g %g)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]];
    if ([self.accessibilityLabel length]) {
        [properties addObject:[NSString stringWithFormat:@"label = '%@'", [self.accessibilityLabel slStringByEscapingForJavaScriptLiteral]]];
    }
    if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *identifier = [(id)self accessibilityIdentifier];
        if ([identifier length]) {
            [properties addObject:[NSString stringWithFormat:@"id = '%@'", [identifier slStringByEscapingForJavaScriptLiteral]]];
        }
    }
    if ([self.accessibilityValue length]) {
        [properties addObject:[NSString stringWithFormat:@"value = '%@'", [self.accessibilityValue slStringByEscapingForJavaScriptLiteral]]];
    }
    if (self.isAccessibilityElement) {
        [properties addObject:@"accessibilityElement = YES"];
    }
    return [NSString stringWithFormat:@"<%@>", [properties componentsJoinedByString:@"; "]];
}

/**
 This method does not use [NSObject slChildAccessibilityElements] because it needs to visually
 differentiate between UIViews and UIAccessibilityContainers. However, it should display elements
 in the same order.
 */
- (NSString *)slRecursiveAccessibilityDescription {
    NSMutableString *recursiveDescription = [[self slAccessibilityDescription] mutableCopy];
    
    NSInteger count = [self accessibilityElementCount];
    if (count != NSNotFound && count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            id element = [self accessibilityElementAtIndex:i];
            NSString *description = [element slRecursiveAccessibilityDescription];
            [recursiveDescription appendFormat:@"\n  + %@", [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  + "]];
        }
    }
    
    if ([self isKindOfClass:[UIView class]]) {
        for (UIView *view in [(UIView *)self subviews]) {
            NSString *description = [view slRecursiveAccessibilityDescription];
            [recursiveDescription appendFormat:@"\n  | %@", [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  | "]];
        }
    }
    
    return recursiveDescription;
}

@end

#pragma mark -

@implementation SLElement (SLAccessibility)

- (BOOL)matchesObject:(NSObject *)object
{
    return [object.slAccessibilityName isEqualToString:self.label];
}

@end


#pragma mark -

@implementation UIAccessibilityElement (SLAccessibility)

- (NSString *)slAccessibilityName {
    if (self.accessibilityLabel) {
        return self.accessibilityLabel;
    }
    
    return self.accessibilityIdentifier;
}

@end


#pragma mark -

@implementation UIView (SLAccessibility)

- (NSString *)slAccessibilityName {
    // Prioritize identifiers over labels because some UIKit objects have transient labels.
    // For example: UIActivityIndicatorViews have label 'In progress' only while spinning.
    if (self.accessibilityIdentifier) {
        return self.accessibilityIdentifier;
    } else if (self.accessibilityLabel) {
        return self.accessibilityLabel;
    }
    
    // If any view doesn't have a name yet, create a unique one so this view can be used in an accessor chain
    self.accessibilityIdentifier = [NSString stringWithFormat:@"%@: %p", [self class], self];
    
    return self.accessibilityIdentifier;
}

- (NSArray *)slChildAccessibilityElements {
    NSMutableArray *children = [[super slChildAccessibilityElements] mutableCopy];
    
    for (UIView *view in [self.subviews reverseObjectEnumerator]) {
        [children addObject:view];
    }
    return children;
}

@end


#pragma mark -

@implementation UIButton (SLAccessibility)

- (NSString *)slAccessibilityName {
    if (self.accessibilityLabel) {
        return self.accessibilityLabel;
    }
    
    return [self titleForState:UIControlStateNormal];
}

@end


