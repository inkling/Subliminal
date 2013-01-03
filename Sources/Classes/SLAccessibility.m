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
            [self adjustAccessibilityNamesInAccessibilityChain:chainWithSelf];
            return chainWithSelf;
        }
    }
    return nil;
}


- (void)adjustAccessibilityNamesInAccessibilityChain:(NSArray *)chain {
    
    // UIWebViews contain a UIWebViewScrollView, which contains a UIWebBrowserView. Both of these classes will be
    // added to UIAutomation's accessibility hierarchy regardless of their lack of accessibility label, value, and name.
    // As a subclass of UIScrollView UIWebScrollView is added to our generated UIAPrefix because of its SLAccessibility
    // category. We do not want to create a category for UIWebBrowserView however, because it is a private class. Instead,
    // here we rely on what we know of UIWebView's internal structure to pull it from its location as the second object
    // below UIWebView in the accessorChain, and modify it to ensure it occurs in the UIAPrefix we generate.
    if ([self isKindOfClass:[UIWebView class]] && [chain count] > 2) {
        UIView *webBrowserView = [chain objectAtIndex:2];
        if ([[webBrowserView slAccessibilityName] length] == 0) {
            webBrowserView.accessibilityIdentifier = [NSString stringWithFormat:@"%@: %p", [webBrowserView class], webBrowserView];
        }
    }
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
    
    UIAccessibilityTraits traits = self.accessibilityTraits;
    NSMutableArray *traitNames = [NSMutableArray array];
    if (traits & UIAccessibilityTraitButton)                  [traitNames addObject:@"Button"];
    if (traits & UIAccessibilityTraitLink)                    [traitNames addObject:@"Link"];
    if (traits & UIAccessibilityTraitHeader)                  [traitNames addObject:@"Header"];
    if (traits & UIAccessibilityTraitSearchField)             [traitNames addObject:@"Search Field"];
    if (traits & UIAccessibilityTraitImage)                   [traitNames addObject:@"Image"];
    if (traits & UIAccessibilityTraitSelected)                [traitNames addObject:@"Selected"];
    if (traits & UIAccessibilityTraitPlaysSound)              [traitNames addObject:@"Plays Sound"];
    if (traits & UIAccessibilityTraitKeyboardKey)             [traitNames addObject:@"Keyboard Key"];
    if (traits & UIAccessibilityTraitStaticText)              [traitNames addObject:@"Static Text"];
    if (traits & UIAccessibilityTraitSummaryElement)          [traitNames addObject:@"Summary Element"];
    if (traits & UIAccessibilityTraitNotEnabled)              [traitNames addObject:@"Not Enabled"];
    if (traits & UIAccessibilityTraitUpdatesFrequently)       [traitNames addObject:@"Updates Frequently"];
    if (traits & UIAccessibilityTraitStartsMediaSession)      [traitNames addObject:@"Starts Media Session"];
    if (traits & UIAccessibilityTraitAdjustable)              [traitNames addObject:@"Adjustable"];
    if (traits & UIAccessibilityTraitAllowsDirectInteraction) [traitNames addObject:@"Allows Direct Interaction"];
    if (traits & UIAccessibilityTraitCausesPageTurn)          [traitNames addObject:@"Causes Page Turn"];
    
    if ([traitNames count]) {
        [properties addObject:[NSString stringWithFormat:@"traits = (%@)", [traitNames componentsJoinedByString:@", "]]];
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
    } else {
        return self.accessibilityLabel;
    }
}

/*
    Used by certain UIView subclasses that must be included in the accessibility chain in order for UIAutomation to
    function correctly.  UIViews that must be included in the accessibility chain should call this method and return
    the result from slAccessibilityName.

    slAccessibilityNameWithStandardIdentifierReplacement assigns a unique string, based on the class and address of the
    object to the object's accessibilityIdentifier if the object does not already have an accessibility identifier or
    accessibility name.
*/
- (NSString *)slAccessibilityNameWithStandardIdentifierReplacement {
    NSString *accessibilityName = [super slAccessibilityName];
    if ([accessibilityName length] == 0) {
        self.accessibilityIdentifier = [NSString stringWithFormat:@"%@: %p", [self class], self];
        return self.accessibilityIdentifier;
    } else {
        return accessibilityName;
    }
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
#pragma mark UIView subclasses that must have a non-nil slAccessibilityName

@implementation UIScrollView (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end

@implementation UIImageView (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end

@implementation UIToolbar (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end

@implementation UINavigationBar (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end

@implementation UIControl (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end

@implementation UIAlertView (SLAccessibility)
- (NSString *)slAccessibilityName {
    return [self slAccessibilityNameWithStandardIdentifierReplacement];
}
@end


#pragma mark -
#pragma mark UITableView custom slAccessibilityName

@implementation UITableView (SLAccessibility)

- (NSString *)slAccessibilityName {
    NSString *accessibilityName = [super slAccessibilityName];
    // Replace the accessibilityIdentifier with a unique string if the accessibilityName is empty *or* equal to the default 'Empty list'
    // because the 'Empty list' label that UIKit assigns is not useful for (uniquely) identifying UITableViews in the accessibility hierarchy.
    if ([accessibilityName length] == 0 || [accessibilityName isEqualToString:@"Empty list"]) {
        self.accessibilityIdentifier = [NSString stringWithFormat:@"%@: %p", [self class], self];
        return self.accessibilityIdentifier;
    } else {
        return accessibilityName;
    }
}

@end


#pragma mark -
#pragma mark UIButton custom slAccessibilityName

@implementation UIButton (SLAccessibility)

- (NSString *)slAccessibilityName {
    if (self.accessibilityIdentifier) {
        return self.accessibilityIdentifier;
    }

    if (self.accessibilityLabel) {
        return self.accessibilityLabel;
    }
    
    return [self titleForState:UIControlStateNormal];
}

@end


