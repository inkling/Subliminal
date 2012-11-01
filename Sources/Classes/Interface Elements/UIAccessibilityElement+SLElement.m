//
//  UIAccessibilityElement+SLElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "UIAccessibilityElement+SLElement.h"
#import "SLElement.h"

#import <objc/runtime.h>


#pragma mark - UIAccessibiltyElement (SLElement)

@implementation UIAccessibilityElement (SLElement)

- (NSString *)slAccessibilityName {
    return ([self.accessibilityIdentifier length] ? self.accessibilityIdentifier : self.accessibilityLabel);
}

- (BOOL)matchesSLElement:(SLElement *)element {
    return [self.accessibilityLabel isEqualToString:element.label];
}

@end


#pragma mark - UIApplication (SLElement)

@implementation UIApplication (SLElement)

- (UIAccessibilityElement *)accessibilityElementMatchingSLElement:(SLElement *)slElement {
    // Go through the array of windows in reverse order to process the frontmost window first.
    // When several elements with the same traits are present the one in front will be picked.
    for (UIWindow *window in [[self windows] reverseObjectEnumerator]) {
        UIAccessibilityElement *matchingElement = [window accessibilityElementMatchingSLElement:slElement];
        if (matchingElement) {
            return matchingElement;
        }
    }

    return nil;
}

@end


#pragma mark - UIView (SLElement)

@implementation UIView (SLElement)

- (NSString *)slAccessibilityName {
    NSString *accessibilityName = ([self.accessibilityIdentifier length] ? self.accessibilityIdentifier : self.accessibilityLabel);
    if (![accessibilityName length]) {
        // Subliminal has requested an name by which to identify this element
        // none has been defined, so we provide one
        accessibilityName = [NSString stringWithFormat:@"%@: %p", [self class], self];

        // Buttons are implicitly identified by their title, in the absence of other information set.
        // We make sure not to overwrite that here.
        if ([self isKindOfClass:[UIButton class]]) {
            accessibilityName = [(UIButton *)self titleForState:UIControlStateNormal];
        }

        // register the name with UIAccessibility
        self.accessibilityIdentifier = accessibilityName;
    }
    return accessibilityName;
}

- (BOOL)matchesSLElement:(SLElement *)element {
    return ([[self slAccessibilityName] isEqualToString:element.label]);
}

// This is modelled after the similar method from KIF. It may be overly naive,
// but I don't want to jump straight to including everything that KIF does.
- (UIAccessibilityElement *)accessibilityElementMatchingSLElement:(SLElement *)slElement {
    // check the view itself
    if ([self matchesSLElement:slElement]) {
        // TODO: Need to assert that this (and below usage, in search through accessibility elements) is safe
        return (UIAccessibilityElement *)self;
    }

    // check its subviews
    for (UIView *view in [self.subviews reverseObjectEnumerator]) {
        UIAccessibilityElement *matchingElement = [view accessibilityElementMatchingSLElement:slElement];
        if (matchingElement) return matchingElement;
    }

    // If the view is an accessibility container, and we didn't find a matching subview,
    // then check the actual accessibility elements
    NSMutableArray *elementStack = [NSMutableArray arrayWithObject:self];
    while ([elementStack count]) {
        UIAccessibilityElement *element = [elementStack objectAtIndex:0];
        [elementStack removeObjectAtIndex:0];

        if ([element matchesSLElement:slElement]) return element;

        NSInteger accessibilityElementCount = element.accessibilityElementCount;
        if (accessibilityElementCount != NSNotFound && accessibilityElementCount > 0) {
            for (NSInteger accessibilityElementIndex = 0; accessibilityElementIndex < accessibilityElementCount; accessibilityElementIndex++) {
                UIAccessibilityElement *subElement = [element accessibilityElementAtIndex:accessibilityElementIndex];
                [elementStack addObject:subElement];
            }
        }
    }

    return nil;
}

@end


#pragma mark - NSObject (SLElement)

@implementation NSObject (SLElement)

- (BOOL)matchesSLElement:(SLElement *)element {
    return NO;
}

@end
