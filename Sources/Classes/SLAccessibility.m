//
//  SLAccessibility.m
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//


#import "SLAccessibility.h"

#import "SLElement.h"
#import "SLElement+Subclassing.h"
#import "NSString+SLJavaScript.h"

NSString * const SLMockViewAccessibilityChainKey = @"SLMockViewAccessibilityChainKey";
NSString * const SLUIViewAccessibilityChainKey = @"SLUIViewAccessibilityChainKey";

@implementation NSObject (SLAccessibility)

- (NSString *)slAccessibilityName {
    if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *identifier = [self performSelector:@selector(accessibilityIdentifier)];
        if ([identifier length] > 0) {
            return identifier;
        }
    }
    
    return self.accessibilityLabel;
}


// If an object fulfills these requirements it will appear in the accessibility hierarchy,
// regardless of any other factors.
- (BOOL)shouldAppearInAccessibilityHierarchy {
    NSObject *parent = [self accessibilityParent];
    if ([parent isAccessibilityElement]) {
        return NO;
    }
    
    NSString *accessibilityIdentifier;
    if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
        accessibilityIdentifier = [self performSelector:@selector(accessibilityIdentifier)];
    }
    BOOL isAccessibilityElement = [self isAccessibilityElement];
    
    // In the standard case, an element will appear in the accessibility hierarchy if it returns YES
    // to isAccessibilityElement or has an accessibility identifier.
    if (isAccessibilityElement || [accessibilityIdentifier length] > 0) {
        return YES;
    }

    if ([self accessibilityTraitsForcePresenceInAccessibilityHierarchy]) {
        return YES;
    }
    
    return NO;
}


// This method defines the conditions a UIView must meet in order to appear directly
// in the accessibility hierarchy
- (BOOL)shouldAppearInUIViewAccessibilityHierarchy {
    BOOL shouldAppear = [self shouldAppearInAccessibilityHierarchy];
    if (shouldAppear) {
        return YES;
    }
    
    if ([self classForcesPresenceInAccessibilityHierarchy]) {
        return YES;
    }
    
    return NO;
}


// This method defines the conditions a UIView must meet in order for an object mocking
// it to appear directly in the accessibility hierarchy
- (BOOL)elementMockingSelfShouldAppearInAccessibilityHierarchy {
    BOOL shouldAppear = [self shouldAppearInAccessibilityHierarchy];
    if (shouldAppear) {
        return YES;
    }
    
    if ([self classForcesPresenceOfMockingViewsInAccessibilityHierarchy]) {
        return YES;
    }
    
    return NO;
}


// Elements matching these accessibility traits have been shown to exist in
// UIAutomation's accessibility hierarchy by trial and error.
- (BOOL)accessibilityTraitsForcePresenceInAccessibilityHierarchy {
    UIAccessibilityTraits traits = self.accessibilityTraits;
    return ((traits & UIAccessibilityTraitButton) ||
            (traits & UIAccessibilityTraitLink) ||
            (traits & UIAccessibilityTraitImage) ||
            (traits & UIAccessibilityTraitKeyboardKey) ||
            (traits & UIAccessibilityTraitStaticText));
}


// This method determines whether or not the object is descendent from any class within
// a set of classes that will always appear in the accessibility hierarchy, regardless of
// their accessibility identification.
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    // UIWebBrowserView is a private api class that appears to be a special case, they will
    // always exist in the accessibility hierarchy. We identify them by their superviews and
    // by the non UIAccessibilityElement objects they vend from elementAtAccessibilityIndex:
    // to avoid accessing private api's.
    BOOL isWebBrowserView = NO;
    if([[[self accessibilityParent] accessibilityParent] isKindOfClass:[UIWebView class]]) {
        for (int i = 0; i < [self accessibilityElementCount]; i++) {
            id accessibilityObject = [self accessibilityElementAtIndex:i];
            if (![accessibilityObject isKindOfClass:[UIAccessibilityElement class]]) {
                isWebBrowserView = YES;
                break;
            }
        }
    }
    
    // _UIPopoverView is another private api special case. It will always exist in the accessibility
    // hierarchy, and is identified by its parent's label to avoid accessing private apis.
    NSObject *parent = [self accessibilityParent];
    BOOL isPopover = [[parent accessibilityLabel] isEqualToString:@"dismiss popup"];
    return (isWebBrowserView || isPopover);
}


// This method determines whether or not the object is descendent from any class within
// a set of classes whose mock objects will always appear in the accessibility hierarchy
// regardless of their accessibility identification
- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy {
    return NO;
}

             
- (NSArray *)slChildAccessibilityElementsFavoringUISubviews:(BOOL)favoringUISubviews {
    NSMutableArray *children = [NSMutableArray array];
    NSInteger count = [self accessibilityElementCount];
    if (count != NSNotFound && count > 0) {
        for (NSInteger i = 0; i < count; i++) {
            [children addObject:[self accessibilityElementAtIndex:i]];
        }
    }
    return children;
}


// This method is meant to provide an inverse to slChildAccessibilityElementsFavoringUISubviews:
// not as an inverse of UIAutomation's accessibility hierarchy. Objects returned from this method
// come with no guarantee regarding their accessibility identification or existence in the
// accessibility hierarchy.
- (NSObject *)accessibilityParent {
    if ([self isKindOfClass:[UIView class]]) {
        return [(UIView *)self superview];
    } else if ([self isKindOfClass:[UIAccessibilityElement class]]) {
        return [(UIAccessibilityElement *)self accessibilityContainer];
    } else {
        return nil;
    }
}


- (NSArray *)fullSLAccessibilityChainToElement:(SLElement *)element favoringUISubviews:(BOOL)favoringUISubviews {
    if ([element matchesObject:self]) {
        return [NSArray arrayWithObject:self];
    }
    
    for (NSObject *child in [self slChildAccessibilityElementsFavoringUISubviews:favoringUISubviews]) {
        NSArray *chain = [child fullSLAccessibilityChainToElement:element favoringUISubviews:favoringUISubviews];
        if (chain) {
            NSMutableArray *chainWithSelf = [chain mutableCopy];
            [chainWithSelf insertObject:self atIndex:0];
            return chainWithSelf;
        }
    }
    return nil;
}


- (NSDictionary *)slAccessibilityChainsToElement:(SLElement *)element {
    NSArray *uiViewAccessibilityChain = [self fullSLAccessibilityChainToElement:element favoringUISubviews:YES];
    
    NSArray *mockViewAccessibilityChain = [self fullSLAccessibilityChainToElement:element favoringUISubviews:NO];
    mockViewAccessibilityChain = [self sanitizeMockViewAccessibilityChain:mockViewAccessibilityChain usingUIViewAccessibilityChain:uiViewAccessibilityChain];

    uiViewAccessibilityChain = [self sanitizeUIViewAccessibilityChain:uiViewAccessibilityChain];
    
    if (!mockViewAccessibilityChain || !uiViewAccessibilityChain) {
        return nil;
    } else {
        return @{SLMockViewAccessibilityChainKey:mockViewAccessibilityChain, SLUIViewAccessibilityChainKey:uiViewAccessibilityChain};
    }
}


- (NSArray *)sanitizeUIViewAccessibilityChain:(NSArray *)accessibilityChain {
    NSMutableArray *trimmedAccessibilityChain = [[NSMutableArray alloc] init];
    [accessibilityChain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // We will need the UIView accessibility chain to contain any views that will
        // be directly in the accessibility hierarchy, as well as any elements that are
        // mocked by elements that will be directly in the accessibility hierarchy
        if ([obj shouldAppearInUIViewAccessibilityHierarchy] || [obj elementMockingSelfShouldAppearInAccessibilityHierarchy]) {
            [trimmedAccessibilityChain addObject:obj];
        }
    }];
    return trimmedAccessibilityChain;
}


- (NSArray *)sanitizeMockViewAccessibilityChain:(NSArray *)mockAccessibilityChain usingUIViewAccessibilityChain:(NSArray *)viewAccessibilityChain {
    NSMutableArray *sanitizedArray = [[NSMutableArray alloc] init];
    
    // Iterate through the elements of the mockAccessibilityChain. Each view in the chain will
    // be included in the accessibility hierarchy if it returns YES from shouldAppearInUIViewAccessibilityHierarchy.
    // Each UIAccessibilityElement that mocks a view will be included in the accessibility hierachy if the view
    // that it mocks returns YES from elementMockingSelfShouldAppearInAccessibilityHierarchy. Each UIAccessibility
    // element that does not mock a view will be included in the accessibility hierarchy if it returns YES from
    // shouldAppearInAccessibilityHierarchy.
    
    __block int viewAccessibilityChainIndex = 0;
    [mockAccessibilityChain enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id objectFromMockChain = obj;
        id currentViewChainObject =  ([viewAccessibilityChain count] > viewAccessibilityChainIndex ? [viewAccessibilityChain objectAtIndex:viewAccessibilityChainIndex] : nil);
        
        // For each objectFromMockChain, if it mocks a view, that view will be in viewAccessibilityChain. Elements from the mockAccessibilityChain that do not mock views will
        // exist at the end of the mockAccessibilityChain, and will also exist at the end of the viewAccessibilityChain.
        if (![objectFromMockChain isKindOfClass:[UIView class]]) {
            while (![self element:objectFromMockChain isMockingViewChainObject:currentViewChainObject] && currentViewChainObject) {
                viewAccessibilityChainIndex++;
                currentViewChainObject = ([viewAccessibilityChain count] > viewAccessibilityChainIndex ? [viewAccessibilityChain objectAtIndex:viewAccessibilityChainIndex] : nil);
            }
        }

        if ([objectFromMockChain isKindOfClass:[UIView class]]) {
            viewAccessibilityChainIndex++;
            if ([objectFromMockChain shouldAppearInUIViewAccessibilityHierarchy]) {
                [sanitizedArray addObject:obj];
            }
            
        } else if ([self element:objectFromMockChain isMockingViewChainObject:currentViewChainObject]) {
            viewAccessibilityChainIndex++;
            if ([currentViewChainObject elementMockingSelfShouldAppearInAccessibilityHierarchy]) {
                [sanitizedArray addObject:objectFromMockChain];
            }

        // If the currentViewChainObject is nil or a UIAccessibilityElement, then objectFromMockChain does not mock a view
        } else if ((![currentViewChainObject isKindOfClass:[UIView class]] && [objectFromMockChain shouldAppearInAccessibilityHierarchy])){
            [sanitizedArray addObject:objectFromMockChain];
        }
    }];
    return sanitizedArray;
}


// Determines whether or not the potentialMockElement is mocking the viewChainObject
- (BOOL)element:(id)potentialMockElement isMockingViewChainObject:(id)viewChainObject {
    if (![viewChainObject isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *view = (UIView *)viewChainObject;
    NSString *previousIdentifier = view.accessibilityIdentifier;
    [view setAccessibilityIdentifierWithStandardReplacement];
    
    BOOL isMocking = NO;
    if ([potentialMockElement respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *mockIdentifier = [potentialMockElement performSelector:@selector(accessibilityIdentifier)];
        isMocking = [mockIdentifier isEqualToString:view.accessibilityIdentifier];
    }
    
    view.accessibilityIdentifier = previousIdentifier;
    
    return isMocking;
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


- (void)setAccessibilityIdentifierWithStandardReplacement {
    if ([self respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
        [self performSelector:@selector(setAccessibilityIdentifier:) withObject:[self standardAccessibilityIdentifierReplacement]];
    }
}


- (NSString *)standardAccessibilityIdentifierReplacement {
    return [NSString stringWithFormat:@"%@: %p", [self class], self];
}


- (void)resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:(NSString *)previousIdentifier previousLabel:(NSString *)previousLabel {
    
    if ([self respondsToSelector:@selector(accessibilityIdentifier)] && [self respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
        NSString *currentIdentifier = [self performSelector:@selector(accessibilityIdentifier)];
        if ([currentIdentifier isEqualToString:[self standardAccessibilityIdentifierReplacement]]) {
            [self performSelector:@selector(setAccessibilityIdentifier:) withObject:previousIdentifier];
        }
    }
    
    if ([self.accessibilityLabel isEqualToString:[self standardAccessibilityIdentifierReplacement]]) {
        self.accessibilityLabel = previousLabel;
    }
}


@end


#pragma mark -

@implementation UIAccessibilityElement (SLAccessibility)

- (NSString *)slAccessibilityName {
    if ([self.accessibilityIdentifier length] > 0) {
        return self.accessibilityIdentifier;
    }
    
    return self.accessibilityLabel;
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

- (NSArray *)slChildAccessibilityElementsFavoringUISubviews:(BOOL)favoringUISubViews {
    if (favoringUISubViews) {
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (UIView *view in [self.subviews reverseObjectEnumerator]) {
            [children addObject:view];
        }
        [children addObjectsFromArray:[super slChildAccessibilityElementsFavoringUISubviews:NO]];
        return children;
    } else {
        NSMutableArray *children = [[super slChildAccessibilityElementsFavoringUISubviews:NO] mutableCopy];
        for (UIView *view in [self.subviews reverseObjectEnumerator]) {
            [children addObject:view];
        }
        return children;
    }
}

@end



#pragma mark -


@implementation UITableViewCell (SLAccessibility)
- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy {
    return YES;
}
@end
    
@implementation UIScrollView (SLAccessibility)
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    return YES;
}
@end

@implementation UIToolbar (SLAccessibility)
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    return YES;
}
@end

@implementation UINavigationBar (SLAccessibility)
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    return YES;
}
@end

@implementation UIControl (SLAccessibility)
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    return YES;
}
@end

@implementation UIAlertView (SLAccessibility)
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    return YES;
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
    
    return self.accessibilityLabel;
}


@end


