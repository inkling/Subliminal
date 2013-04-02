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

#import <UIKit/UIKit.h>


#pragma mark SLAccessibilityPath Interface

@interface SLAccessibilityPath ()

/**
 Creates and returns an array containing only those objects from
 the specified view path that appear in the accessibility hierarchy
 as understood by UIAutomation.

 These do not comprise only those views that are accessibility elements
 according to -[NSObject isAccessibilityElement].

 @param viewPath The predominantly-UIView path to sanitize.
 @return A path containing only those views that appear in
 the accessibility hierarchy as understood by UIAutomation.
 */
+ (NSArray *)sanitizeViewPath:(NSArray *)viewPath;

/**
Creates and returns an array containing only those objects from
the specified accessibility element path that should appear in the accessibility
hierarchy as understood by UIAutomation.

These objects corresponds closely, but not entirely, to the views that should appear
in the accessibility hierarchy.

@param accessibilityElementPath The predominantly-UIAccessibilityElement path to sanitize.
@param viewPath A predominantly-UIView path corresponding to accessibilityElementPath,
to be used to sanitize accessibilityElementPath.
*/
+ (NSArray *)sanitizeAccessibilityElementPath:(NSArray *)accessibilityElementPath
                                usingViewPath:(NSArray *)viewPath;

/**
 Initializes and returns a newly allocated accessibility path
 with the specified component paths.
 
 The accessibility element path should prioritize paths along UIAccessibilityElements
 to a matching object, while the view path should prioritize paths comprising 
 UIViews. If this is done, every view in the accessibility element path will exist 
 in the view path, and each object in the accessibility element path that mocks 
 a view, will mock a view from the view path.

 It is the accessibility element path that (when [serialized](-UIARepresentation))
 matches the path that UIAutomation would use to identify the accessibility
 path's referent. The view path is be used to set the accessibility identifiers 
 of mock views in the accessibility element accessibility path, during 
 [binding](-bindPath:).

 @warning The accessibility path sanitizes the component paths in the process of 
 initialization. If, after sanitization, either path is empty, the accessibility 
 path will be released and this method will return nil.
 
 @param accessibilityElementPath A path that predominantly traverses 
 UIAccessibilityElements.
 @param viewPath A path that predominantly traverse UIViews.
 @return An initialized accessibility path, or `nil` if the object couldn't be created.
 */
- (instancetype)initWithAccessibilityElementPath:(NSArray *)accessibilityElementPath
                                        viewPath:(NSArray *)viewPath;

@end


#pragma mark - NSObject (SLAccessibility_Internal)

/**
 The methods in the NSObject (SLAccessibility_Internal) category are used 
 by SLAccessibilityPath in the process of constructing, sanitizing, binding, 
 and serializing paths.
 */
@interface NSObject (SLAccessibility_Internal)

/// ----------------------------------------
/// @name Constructing paths
/// ----------------------------------------

/**
 Creates and returns an array of objects that form a path through an accessibility 
 hierarchy between the receiver and the object [matching](-[SLElement matchesObject:]) 
 the specified element.

 If favoringUISubviews is YES, the method will construct a path that is, as much 
 as is possible, comprised of UIViews; otherwise, it will construct a path that is,
 as much as is possible, comprised of UIAccessibilityElements. These paths 
 correspond to the view and accessibility element paths used to initialize an SLAccessibilityPath.
 
 @param element The element to which corresponds the object that is to be
 the terminus of the path.
 @param favoringUISubviews YES if the search for a path should favor UIViews;
 otherwise, the search should favor UIAccessibilityElements.
 @return A path between the receiver and the object matching element,
 or `nil` if an object matching element is not found within the accessibility hierarchy
 rooted in the receiver.
 */
- (NSArray *)accessibilityPathToElement:(SLElement *)element favoringUISubviews:(BOOL)favoringUISubviews;

/**
 Creates and returns an array of objects that are child accessibility elements of this object.

 This method is mostly a wrapper around the UIAccessibilityContainer protocol but
 also includes subviews if the object is a UIView. It attempts to represent the
 accessibility hierarchy used by the system.

 @param favoringUISubViews Whether subviews should be placed before or after
 UIAccessibilityElements in the returned array

 @return An array of objects that are child accessibility elements of this object.
 */
- (NSArray *)slChildAccessibilityElementsFavoringUISubviews:(BOOL)favoringUISubviews;

/// ----------------------------------------
/// @name Sanitizing paths
/// ----------------------------------------

// This method is meant to provide an inverse to slChildAccessibilityElementsFavoringUISubviews:
// not as an inverse of UIAutomation's accessibility hierarchy. Objects returned from this method
// come with no guarantee regarding their accessibility identification or existence in the
// accessibility hierarchy.
- (NSObject *)accessibilityParent;

// If an object fulfills these requirements it will appear in the accessibility hierarchy,
// regardless of any other factors.
- (BOOL)shouldAppearInAccessibilityHierarchy;

// This method defines the conditions a UIView must meet in order to appear directly
// in the accessibility hierarchy
- (BOOL)shouldAppearInUIViewAccessibilityHierarchy;

// This method defines the conditions a UIView must meet in order for an object mocking
// it to appear directly in the accessibility hierarchy
- (BOOL)elementMockingSelfShouldAppearInAccessibilityHierarchy;

// Elements matching these accessibility traits have been shown to exist in
// UIAutomation's accessibility hierarchy by trial and error.
- (BOOL)accessibilityTraitsForcePresenceInAccessibilityHierarchy;

// This method determines whether or not the object is descendent from any class within
// a set of classes that will always appear in the accessibility hierarchy, regardless of
// their accessibility identification.
- (BOOL)classForcesPresenceInAccessibilityHierarchy;

// This method determines whether or not the object is descendent from any class within
// a set of classes whose mock views will always appear in the accessibility hierarchy
// regardless of their accessibility identification
- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy;

// Determines whether or not potentialMockElement is mocking viewPathObject
- (BOOL)element:(id)potentialMockElement isMockingViewPathObject:(id)viewPathObject;

/// ----------------------------------------
/// @name Binding and serializing paths
/// ----------------------------------------

/** Sets a unique identifier as the accessibilityIdentifier **/
- (void)setAccessibilityIdentifierWithStandardReplacement;

/** The string that should be used to uniquely identify this object to UIAutomation **/
- (NSString *)standardAccessibilityIdentifierReplacement;

/** 
 Resets the receiver's accessibilityIdentifier and accessibilityLabel to their 
 appropriate values, unless their values have been changed again since they were 
 replaced with the standardAccessibilityIdentifierReplacement.

 @param previousIdentifier The accessibilityIdentifier's value before it was set to
 standardAccessibilityIdentifierReplacement.
 @param previousLabel The accessibilityLabel's value before it was set to
 standardAccessibilityIdentifierReplacement.
 **/
- (void)resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:(NSString *)previousIdentifier
                                                  previousLabel:(NSString *)previousLabel;

@end


@implementation NSObject (SLAccessibility)

#pragma mark - Public NSObject (SLAccessibility) methods

- (NSString *)slAccessibilityName {
    if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *identifier = [self performSelector:@selector(accessibilityIdentifier)];
        if ([identifier length] > 0) {
            return identifier;
        }
    }
    
    return self.accessibilityLabel;
}

- (SLAccessibilityPath *)slAccessibilityPathToElement:(SLElement *)element {
    NSArray *accessibilityElementPath = [self accessibilityPathToElement:element favoringUISubviews:NO];
    NSArray *viewPath = [self accessibilityPathToElement:element favoringUISubviews:YES];

    return [[SLAccessibilityPath alloc] initWithAccessibilityElementPath:accessibilityElementPath
                                                                viewPath:viewPath];
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

#pragma mark - Private NSObject (SLAccessibility) methods

- (NSArray *)accessibilityPathToElement:(SLElement *)element favoringUISubviews:(BOOL)favoringUISubviews {
    if ([element matchesObject:self]) {
        return [NSArray arrayWithObject:self];
    }

    for (NSObject *child in [self slChildAccessibilityElementsFavoringUISubviews:favoringUISubviews]) {
        NSArray *path = [child accessibilityPathToElement:element favoringUISubviews:favoringUISubviews];
        if (path) {
            NSMutableArray *pathWithSelf = [path mutableCopy];
            [pathWithSelf insertObject:self atIndex:0];
            return pathWithSelf;
        }
    }
    return nil;
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

- (NSObject *)accessibilityParent {
    if ([self isKindOfClass:[UIView class]]) {
        return [(UIView *)self superview];
    } else if ([self isKindOfClass:[UIAccessibilityElement class]]) {
        return [(UIAccessibilityElement *)self accessibilityContainer];
    } else {
        return nil;
    }
}

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

- (BOOL)accessibilityTraitsForcePresenceInAccessibilityHierarchy {
    UIAccessibilityTraits traits = self.accessibilityTraits;
    return ((traits & UIAccessibilityTraitButton) ||
            (traits & UIAccessibilityTraitLink) ||
            (traits & UIAccessibilityTraitImage) ||
            (traits & UIAccessibilityTraitKeyboardKey) ||
            (traits & UIAccessibilityTraitStaticText));
}

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

- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy {
    return NO;
}

- (BOOL)element:(id)potentialMockElement isMockingViewPathObject:(id)viewPathObject {
    if (![viewPathObject isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *view = (UIView *)viewPathObject;
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


#pragma mark - NSObject (SLAccessibility) Overrides

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
    if ([self.accessibilityIdentifier length] > 0) {
        return self.accessibilityIdentifier;
    }

    return self.accessibilityLabel;
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


#pragma mark - SLAccessibilityPath Implementation

@implementation SLAccessibilityPath {
    NSArray *_accessibilityElementPath, *_viewPath;
}

+ (NSArray *)sanitizeViewPath:(NSArray *)viewPath {
    NSMutableArray *trimmedAccessibilityPath = [[NSMutableArray alloc] init];
    [viewPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // We will need the UIView accessibility path to contain any views that will
        // be directly in the accessibility hierarchy, as well as any elements that are
        // mocked by elements that will be directly in the accessibility hierarchy
        if ([obj shouldAppearInUIViewAccessibilityHierarchy] || [obj elementMockingSelfShouldAppearInAccessibilityHierarchy]) {
            [trimmedAccessibilityPath addObject:obj];
        }
    }];
    return trimmedAccessibilityPath;
}

+ (NSArray *)sanitizeAccessibilityElementPath:(NSArray *)accessibilityElementPath
                                usingViewPath:(NSArray *)viewPath {
    NSMutableArray *sanitizedArray = [[NSMutableArray alloc] init];

    /* 
     Iterate through the objects of the accessibilityElementPath
     to determine if they should be included in the accessibility hierarchy:

         * Each view in the path will be included in the accessibility hierarchy
         if it returns YES from shouldAppearInUIViewAccessibilityHierarchy.

         * Each UIAccessibilityElement that mocks a view will be included in the
         accessibility hierachy if the view that it mocks returns YES from
         elementMockingSelfShouldAppearInAccessibilityHierarchy.

         * Each UIAccessibilityElement that does not mock a view may yet be
         included in the accessibility hierarchy if it returns YES from
         shouldAppearInAccessibilityHierarchy.

     */

    __block int viewPathIndex = 0;
    [accessibilityElementPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id objectFromAccessibilityElementPath = obj;
        id currentViewPathObject =  ([viewPath count] > viewPathIndex ?
                                        [viewPath objectAtIndex:viewPathIndex] : nil);

        // For each objectFromAccessibilityElementPath, if it mocks a view,
        // that view will be in viewAccessibilityPath. Elements from the
        // accessibilityElementPath that do not mock views (i.e. user-created
        // accessibility elements) will exist at the end of accessibilityElementPath,
        // and will also exist at the end of viewAccessibilityPath.
        if (![objectFromAccessibilityElementPath isKindOfClass:[UIView class]]) {
            while (![self element:objectFromAccessibilityElementPath isMockingViewPathObject:currentViewPathObject] && currentViewPathObject) {
                viewPathIndex++;
                currentViewPathObject = ([viewPath count] > viewPathIndex ?
                                            [viewPath objectAtIndex:viewPathIndex] : nil);
            }
        }

        if ([objectFromAccessibilityElementPath isKindOfClass:[UIView class]]) {
            viewPathIndex++;
            if ([objectFromAccessibilityElementPath shouldAppearInUIViewAccessibilityHierarchy]) {
                [sanitizedArray addObject:obj];
            }
            
        } else if ([self element:objectFromAccessibilityElementPath isMockingViewPathObject:currentViewPathObject]) {
            viewPathIndex++;
            if ([currentViewPathObject elementMockingSelfShouldAppearInAccessibilityHierarchy]) {
                [sanitizedArray addObject:objectFromAccessibilityElementPath];
            }

            // If the currentViewPathObject is nil or a UIAccessibilityElement,
            // then objectFromAccessibilityElementPath does not mock a view
        } else if ((![currentViewPathObject isKindOfClass:[UIView class]] &&
                    [objectFromAccessibilityElementPath shouldAppearInAccessibilityHierarchy])){
            [sanitizedArray addObject:objectFromAccessibilityElementPath];
        }
    }];
    return sanitizedArray;
}

- (instancetype)initWithAccessibilityElementPath:(NSArray *)accessibilityElementPath viewPath:(NSArray *)viewPath {
    self = [super init];
    if (self) {
        _accessibilityElementPath = [[self class] sanitizeAccessibilityElementPath:accessibilityElementPath
                                                                     usingViewPath:viewPath];
        _viewPath = [[self class] sanitizeViewPath:viewPath];

        if (![_accessibilityElementPath count] || ![_viewPath count]) {
            self = nil;
            return self;
        }
    }
    return self;
}

- (void)examineLastPathComponent:(void (^)(NSObject *lastPathComponent))block {
    // examine the last object in the mock view path because that's the path
    // actually used by UIAutomation
    dispatch_sync(dispatch_get_main_queue(), ^{
        block([_accessibilityElementPath lastObject]);
    });
}

// To bind the path to a unique destination, unique identifiers are set on
// the objects in the view path. This ensures that the identifiers are set
// successfully (because some mock views' identifiers cannot be set directly,
// but rather track the identifiers on their corresponding views)
// and that the path does not contain any extra elements.
//
// After the block has been executed, the accessibilityLabels and
// accessibilityIdentifiers on each element in the view matching chain are reset.

- (void)bindPath:(void (^)(SLAccessibilityPath *boundPath))block {
    __block NSMutableArray *previousAccessorPathIdentifiers = [[NSMutableArray alloc] init];
    __block NSMutableArray *previousAccessorPathLabels = [[NSMutableArray alloc] init];

    // Unique the elements' identifiers
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Previous accessibility identifiers and labels are stored in a separate loop,
        // before they are reassigned. This is because for some elements, these
        // values depend on their parent elements' values, and will change
        // when the parent elements' values are updated.
        for (NSObject *obj in _viewPath) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the view path must conform to UIAccessibilityIdentification");

            NSObject *previousIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if (previousIdentifier == nil) {
                previousIdentifier = [NSNull null];
            }
            [previousAccessorPathIdentifiers addObject:previousIdentifier];

            NSObject *previousLabel = [obj accessibilityLabel];
            if (previousLabel == nil) {
                previousLabel = [NSNull null];
            }
            [previousAccessorPathLabels addObject:previousLabel];
        }

        // The path's elements' accessibility information is updated in reverse order,
        // because of the issue described in the above note.
        for (NSObject *obj in [_viewPath reverseObjectEnumerator]) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the view path must conform to UIAccessibilityIdentification");
            [obj setAccessibilityIdentifierWithStandardReplacement];

            // Even some view objects will not allow their accessibilityIdentifier to be modified.
            // In these cases, if the accessibilityIdentifer is empty,
            // we can uniquely identify the object with its label.
            if ([[obj performSelector:@selector(accessibilityIdentifier)] length] == 0) {
                obj.accessibilityLabel = [obj standardAccessibilityIdentifierReplacement];
            }
        }
    });

    block(self);

    // Reset the elements' identifiers
    dispatch_sync(dispatch_get_main_queue(), ^{
        // The path's elements' accessibility information is updated in reverse order,
        // because of the issue listed in the above note.
        [_viewPath enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSObject *identifierObj = [previousAccessorPathIdentifiers objectAtIndex:idx];
            NSString *identifier = ([identifierObj isEqual:[NSNull null]] ? nil : (NSString *)identifierObj);
            NSObject *labelObj = [previousAccessorPathLabels objectAtIndex:idx];
            NSString *label = ([labelObj isEqual:[NSNull null]] ? nil : (NSString *)labelObj);
            
            [obj resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:identifier previousLabel:label];
        }];
    });
}

- (NSString *)UIARepresentation {
    __block NSMutableString *uiaRepresentation = [@"UIATarget.localTarget().frontMostApp().mainWindow()" mutableCopy];
    dispatch_sync(dispatch_get_main_queue(), ^{
        // The representation must be generated from the accessibility information
        // on the elements of the mock view path instead of the view path because
        // the mock view path contains the actual elements UIAutomation will
        // interact with, and it may be shorter than the view path.
        for (NSObject *obj in _accessibilityElementPath) {
            NSAssert([obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the mock view path must conform to UIAccessibilityIdentification");

            // Elements must be identified by their accessibility identifier
            // as long as one exists. The accessibility identifier may be nil
            // for some classes on which you cannot set an accessibility identifer
            // e.g. UISegmentedControl. In these cases the element can
            // be identified by its label.
            NSString *currentIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if (![currentIdentifier length]) {
                currentIdentifier = obj.accessibilityLabel;
            }
            [uiaRepresentation appendFormat:@".elements()['%@']",
             [currentIdentifier slStringByEscapingForJavaScriptLiteral]];
        }
    });
    return uiaRepresentation;
}

@end
