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
#import "SLStringUtilities.h"
#import "SLMainThreadRef.h"

#import <UIKit/UIKit.h>


#pragma mark SLAccessibilityPath interface

@interface SLAccessibilityPath ()

/**
 Creates and returns an array containing only those objects from
 the specified accessibility element path that should appear in the accessibility
 hierarchy as understood by UIAutomation.

 These objects corresponds closely, but not entirely, to the views that should appear
 in the accessibility hierarchy.

 @param accessibilityElementPath The predominantly-UIAccessibilityElement path to filter.
 @param viewPath A predominantly-UIView path corresponding to accessibilityElementPath,
 to be used to filter accessibilityElementPath.
 @return A path that contains only those elements that appear in the accessibility 
 hierarchy as understood by UIAutomation.
 */
+ (NSArray *)filterRawAccessibilityElementPath:(NSArray *)accessibilityElementPath
                              usingRawViewPath:(NSArray *)viewPath;

/**
 Creates and returns an array containing only those objects from
 the specified view path that appear in the accessibility hierarchy
 as understood by UIAutomation.

 These do not comprise only those views that are accessibility elements
 according to -[NSObject isAccessibilityElement].

 @param viewPath The predominantly-UIView path to filter.
 @return A path containing only those views that appear in
 the accessibility hierarchy as understood by UIAutomation.
 */
+ (NSArray *)filterRawViewPath:(NSArray *)viewPath;

/**
 Creates and returns an array comprised of the components from the specified 
 path, wrapped in SLMainThreadRefs.
 
 The path returned will weakly reference the original components 
 and so can be safely retained on a background thread
 
 @param path A path to map using SLMainThreadRefs.
 @return An array comprised of the components from path, wrapped in SLMainThreadRefs.
 */
+ (NSArray *)mapPathToBackgroundThread:(NSArray *)path;

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

 @warning The accessibility path filters the component paths in the process of
 initialization. If, after filtering, either path is empty, the accessibility
 path will be released and this method will return nil.
 
 @param accessibilityElementPath A path that predominantly traverses 
 UIAccessibilityElements.
 @param viewPath A path that predominantly traverse UIViews.
 @return An initialized accessibility path, or `nil` if the object couldn't be created.
 */
- (instancetype)initWithRawAccessibilityElementPath:(NSArray *)accessibilityElementPath
                                        rawViewPath:(NSArray *)viewPath;

@end


#pragma mark - SLAccessibility internal interfaces

/**
 The methods in the NSObject (SLAccessibility_SLAccessibilityPath) category are used
 by SLAccessibilityPath in the process of constructing, sanitizing, binding, 
 and serializing paths.
 */
@interface NSObject (SLAccessibility_SLAccessibilityPath)

/// ----------------------------------------
/// @name Constructing paths
/// ----------------------------------------

/**
 Creates and returns an array of objects that form a path through an accessibility 
 hierarchy between the receiver and the object [matching](-[SLElement matchesObject:]) 
 the specified element.

 If favoringUISubviews is YES, the method will construct a path that is, as much 
 as is possible, comprised of UIViews; otherwise, it will construct a path that is,
 as much as is possible, comprised of UIAccessibilityElements.
 
 These paths may contain more objects than exist in the accessibility hierarchy 
 recognized by UIAutomation; they correspond to the "raw" view and accessibility 
 element paths used to initialize an SLAccessibilityPath.
 
 @param element The element to which corresponds the object that is to be
 the terminus of the path.
 @param favoringUISubviews YES if the search for a path should favor UIViews;
 otherwise, the search should favor UIAccessibilityElements.
 @return A path between the receiver and the object matching element,
 or `nil` if an object matching element is not found within the accessibility hierarchy
 rooted in the receiver.
 */
- (NSArray *)rawAccessibilityPathToElement:(SLElement *)element favoringUISubviews:(BOOL)favoringUISubviews;

/**
 Creates and returns an array of objects that are child accessibility elements 
 of this object.

 This method is mostly a wrapper around the UIAccessibilityContainer protocol but
 also includes subviews if the object is a UIView. It attempts to represent the
 accessibility hierarchy used by the system.

 @param favoringUISubViews If YES, subviews should be placed before
 UIAccessibilityElements in the returned array; otherwise, they will be placed 
 afterwards.

 @return An array of objects that are child accessibility elements of this object.
 */
- (NSArray *)slChildAccessibilityElementsFavoringUISubviews:(BOOL)favoringUISubviews;

/// ----------------------------------------
/// @name Filtering paths
/// ----------------------------------------

/**
 Returns the SLAccessibility-specific accessibility container of the receiver.

 This method is the inverse of slChildAccessibilityElementsFavoringUISubviews:,
 and not necessarily the inverse of UIAutomation's accessibility hierarchy.
 Objects returned from this method come with no guarantee regarding their 
 accessibility identification or existence in the accessibility hierarchy.
 
 @return The object's superview, if it is a view; otherwise its accessibilityContainer,
 if it is an accessibility element; otherwise `nil`.
 */
- (NSObject *)slAccessibilityParent;

/**
 Returns a Boolean value that indicates whether the receiver should appear
 in an accessibility hierarchy.
 
 Experimentation reveals that an object will appear in UIAutomation's 
 accessibility hierarchy if: 

 * its [parent](-slAccessibilityParent) is not [an accessibility element](-[NSObject
 isAccessibilityElement]), and
 * it is [an accessibility element](-[NSObject isAccessibilityElement]), or
 * it has a non-empty accessibility identifier, or
 * it has accessibility traits that [force its presence in the accessibility
 hierarchy](-accessibilityTraitsForcePresenceInAccessibilityHierarchy), or
 * it is an instance of one of a [certain set
 of classes](-classForcesPresenceInAccessibilityHierarchy).

 @return YES if the receiver should appear in an accessibility hierarchy,
 otherwise NO.
 */
- (BOOL)shouldAppearInAccessibilityHierarchy;

/**
 Returns a Boolean value that indicates whether the receiver's accessibility
 traits force its presence in an accessibility hierarchy.

 Experimentation reveals that objects with certain accessibility traits 
 will appear in UIAutomation's accessibility hierarchy regardless of their 
 accessibility identification.

 @return YES if the receiver's accessibility traits force its presence in an
 accessibility hierarchy, otherwise NO.
 */
- (BOOL)accessibilityTraitsForcePresenceInAccessibilityHierarchy;

/**
 Returns a Boolean value that indicates whether the receiver's class
 forces its presence in an accessibility hierarchy.

 Experimentation reveals that objects descending from a certain set of classes 
 will appear in UIAutomation's accessibility hierarchy regardless of their 
 accessibility identification.

 @return YES if the receiver's class forces its presence in an accessibility
 hierarchy, otherwise NO.
 */
- (BOOL)classForcesPresenceInAccessibilityHierarchy;

/// ----------------------------------------
/// @name Binding and serializing paths
/// ----------------------------------------

/** Sets a unique identifier as the accessibilityIdentifier **/
- (void)setAccessibilityIdentifierWithStandardReplacement;

/** The string that should be used to uniquely identify this object to UIAutomation **/
- (NSString *)standardAccessibilityIdentifierReplacement;

/** 
 Resets the receiver's accessibilityIdentifier to its appropriate value, unless its
 value has been changed again since it was replaced with the
 standardAccessibilityIdentifierReplacement.

 @param previousIdentifier The accessibilityIdentifier's value before it was set to
 standardAccessibilityIdentifierReplacement.
 **/
- (void)resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:(NSString *)previousIdentifier;

@end


@interface UIView (SLAccessibility_Visibility)

/**
 Returns a Boolean value indicating whether the receiver contains the specified
 point, as indicated by its accessibility information.
 
 @param point A point that is in screen coordinates.
 @return YES if point is inside the receiver's accessibility frame; otherwise, NO.
 */
- (BOOL)slAccessibilityPointInside:(CGPoint)point;

/**
 Returns the farthest descendant of the receiver in the accessibility hierarchy 
 (including itself) that contains a specified point.

 @param point A point specified in screen coordinates.
 @return The view object that is the farthest descendant of the current view 
 that contains point. Returns `nil` if the point lies completely outside 
 the receiver's accessibility hierarchy.
 */
- (UIView *)slAccessibilityHitTest:(CGPoint)point;

@end


@interface UIView (SLAccessibility_SLAccessibilityPath)

/**
 Returns a Boolean value that indicates whether an object is a mock view.

 Mock views are accessibility elements created by the accessibility system
 to represent certain views like UITableViewCells. Where a mock view exists,
 the accessibility system, and UIAutomation, read/manipulate it instead of the
 real view.

 @return YES if viewObject is a UIView and elementObject is mocking that view, otherwise NO.
 */
+ (BOOL)elementObject:(id)elementObject isMockingViewObject:(id)viewObject;

/**
 Returns a Boolean value that indicates whether an object mocking the receiver
 should appear in an accessibility hierarchy.

 Experimentation reveals that a mock view will appear in the accessibility hierarchy
 if the real object should appear in [any accessibility hierarchy]
 (-shouldAppearInAccessibilityHierarchy) or is an instance of one of a [certain set
 of classes](-classForcesPresenceOfMockingViewsInAccessibilityHierarchy).

 @return YES if an object mocking the receiver should appear in an accessibility
 hierarchy, otherwise NO.
 */
- (BOOL)elementMockingSelfShouldAppearInAccessibilityHierarchy;

/**
 Returns a Boolean value that indicates whether the receiver's class
 forces the presence of mock views in the accessibility hierarchy.

 Experimentation reveals that objects mocking certain types of views will appear
 in UIAutomation's accessibility hierarchy regardless of their accessibility
 identification.

 @return YES if the receiver's class forces the presence of objects mocking
 instances of the class in an accessibility hierarchy, otherwise NO.
 */
- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy;

@end


#pragma mark - SLAccessibility implementation

@implementation NSObject (SLAccessibility)

#pragma mark -Public methods

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
    NSArray *accessibilityElementPath = [self rawAccessibilityPathToElement:element favoringUISubviews:NO];
    NSArray *viewPath = [self rawAccessibilityPathToElement:element favoringUISubviews:YES];

    return [[SLAccessibilityPath alloc] initWithRawAccessibilityElementPath:accessibilityElementPath
                                                                rawViewPath:viewPath];
}

// There are objects in the accessibility hierarchy which are neither UIAccessibilityElements
// nor UIViews, e.g. the elements vended by UIWebBrowserViews. We attempt to
// locate these elements in the hierarchy using an implementation
// similar to UIAccessibilityElement's.
- (BOOL)slAccessibilityIsVisible {
    CGPoint testPoint = CGPointMake(CGRectGetMidX(self.accessibilityFrame),
                                    CGRectGetMidY(self.accessibilityFrame));

    if (![self respondsToSelector:@selector(accessibilityContainer)]) {
        SLLogAsync(@"Cannot locate %@ in the accessibility hierarchy. Returning -NO from -slAccessibilityIsVisible.", self);
        return NO;
    }

    // we first determine that we are the foremost element within our containment hierarchy
    id parentOrSelf = self;
    id container = [self performSelector:@selector(accessibilityContainer)];
    while (container) {
        // UIAutomation ignores accessibilityElementsHidden, so we do too

        NSInteger elementCount = [container accessibilityElementCount];
        NSAssert(((elementCount != NSNotFound) && (elementCount > 0)),
                 @"%@'s accessibility container should implement the UIAccessibilityContainer protocol.", self);
        for (NSInteger idx = 0; idx < elementCount; idx++) {
            id element = [container accessibilityElementAtIndex:idx];
            if (element == parentOrSelf) break;
            // UIWebBrowserViews vend an element whose container is not the UIWebBrowserView
            // but rather, whose container's container is the UIWebBrowserView
            if ([element respondsToSelector:@selector(accessibilityContainer)] &&
                [element performSelector:@selector(accessibilityContainer)] == parentOrSelf) break;

            // if another element comes before us/our parent in the array
            // (thus is z-ordered before us/our parent)
            // and contains our hitpoint, it covers us
            if (CGRectContainsPoint([element accessibilityFrame], testPoint)) return NO;
        }

        // we should eventually reach a container that is a view
        // --the accessibility hierarchy begins with the main window if nothing else--
        // at which point we test the rest of the hierarchy using hit-testing
        if ([container isKindOfClass:[UIView class]]) break;

        // it's not a requirement that accessibility containers vend UIAccessibilityElements,
        // so it might not be possible to traverse the hierarchy upwards
        if (![container respondsToSelector:@selector(accessibilityContainer)]) {
            SLLogAsync(@"Cannot locate %@ in the accessibility hierarchy. Returning -NO from -slAccessibilityIsVisible.", self);
            return NO;
        }
        parentOrSelf = container;
        container = [container accessibilityContainer];
    }

    NSAssert([container isKindOfClass:[UIView class]],
             @"Every accessibility hierarchy should be rooted in a view.");
    UIView *viewContainer = (UIView *)container;

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *hitView = [window slAccessibilityHitTest:testPoint];
    if (hitView != viewContainer) return NO;

    return YES;
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

#pragma mark -Private methods

- (NSArray *)rawAccessibilityPathToElement:(SLElement *)element favoringUISubviews:(BOOL)favoringUISubviews {
    if ([element matchesObject:self]) {
        return [NSArray arrayWithObject:self];
    }

    for (NSObject *child in [self slChildAccessibilityElementsFavoringUISubviews:favoringUISubviews]) {
        NSArray *path = [child rawAccessibilityPathToElement:element favoringUISubviews:favoringUISubviews];
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

- (NSObject *)slAccessibilityParent {
    if ([self isKindOfClass:[UIView class]]) {
        return [(UIView *)self superview];
    } else if ([self isKindOfClass:[UIAccessibilityElement class]]) {
        return [(UIAccessibilityElement *)self accessibilityContainer];
    } else {
        return nil;
    }
}

- (BOOL)shouldAppearInAccessibilityHierarchy {
    // An object will not appear in the accessibility hierarchy
    // if its direct parent is an accessibility element.
    NSObject *parent = [self slAccessibilityParent];
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

    if ([self classForcesPresenceInAccessibilityHierarchy]) {
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
    if([[[self slAccessibilityParent] slAccessibilityParent] isKindOfClass:[UIWebView class]]) {
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
    NSObject *parent = [self slAccessibilityParent];
    BOOL isPopover = [[parent accessibilityLabel] isEqualToString:@"dismiss popup"];
    return (isWebBrowserView || isPopover);
}

- (void)setAccessibilityIdentifierWithStandardReplacement {
    if ([self respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
        [self performSelector:@selector(setAccessibilityIdentifier:) withObject:[self standardAccessibilityIdentifierReplacement]];
    }
}

- (NSString *)standardAccessibilityIdentifierReplacement {
    return [NSString stringWithFormat:@"%@: %p", [self class], self];
}

- (void)resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:(NSString *)previousIdentifier {
    
    if ([self respondsToSelector:@selector(accessibilityIdentifier)] && [self respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
        NSString *currentIdentifier = [self performSelector:@selector(accessibilityIdentifier)];
        if ([currentIdentifier isEqualToString:[self standardAccessibilityIdentifierReplacement]]) {
            [self performSelector:@selector(setAccessibilityIdentifier:) withObject:previousIdentifier];
        }
    }
}

@end


#pragma mark UIAccessibilityElement overrides

@implementation UIAccessibilityElement (SLAccessibility)

- (NSString *)slAccessibilityName {
    if ([self.accessibilityIdentifier length] > 0) {
        return self.accessibilityIdentifier;
    }
    
    return self.accessibilityLabel;
}

- (BOOL)slAccessibilityIsVisible {
    CGPoint testPoint = CGPointMake(CGRectGetMidX(self.accessibilityFrame),
                                    CGRectGetMidY(self.accessibilityFrame));

    // we first determine that we are the foremost element within our containment hierarchy
    id parentOrSelf = self;
    id container = self.accessibilityContainer;
    while (container) {
        // UIAutomation ignores accessibilityElementsHidden, so we do too

        NSInteger elementCount = [container accessibilityElementCount];
        NSAssert(((elementCount != NSNotFound) && (elementCount > 0)),
                 @"%@'s accessibility container should implement the UIAccessibilityContainer protocol.", self);
        for (NSInteger idx = 0; idx < elementCount; idx++) {
            id element = [container accessibilityElementAtIndex:idx];
            if (element == parentOrSelf) break;

            // if another element comes before us/our parent in the array
            // (thus is z-ordered before us/our parent)
            // and contains our hitpoint, it covers us
            if (CGRectContainsPoint([element accessibilityFrame], testPoint)) return NO;
        }

        // we should eventually reach a container that is a view
        // --the accessibility hierarchy begins with the main window if nothing else--
        // at which point we test the rest of the hierarchy using hit-testing
        if ([container isKindOfClass:[UIView class]]) break;

        // it's not a requirement that accessibility containers vend UIAccessibilityElements,
        // so it might not be possible to traverse the hierarchy upwards
        if (![container respondsToSelector:@selector(accessibilityContainer)]) {
            SLLogAsync(@"Cannot locate %@ in the accessibility hierarchy. Returning -NO from -slAccessibilityIsVisible.", self);
            return NO;
        }
        parentOrSelf = container;
        container = [container accessibilityContainer];
    }

    NSAssert([container isKindOfClass:[UIView class]],
             @"Every accessibility hierarchy should be rooted in a view.");
    UIView *viewContainer = (UIView *)container;

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *hitView = [window slAccessibilityHitTest:testPoint];
    if (hitView != viewContainer) return NO;
    
    return YES;
}

@end


#pragma mark UIView overrides

@implementation UIView (SLAccessibility)

#pragma mark -Public methods

- (NSString *)slAccessibilityName {
    // Prioritize identifiers over labels because some UIKit objects have transient labels.
    // For example: UIActivityIndicatorViews have label 'In progress' only while spinning.
    if ([self.accessibilityIdentifier length] > 0) {
        return self.accessibilityIdentifier;
    }

    return self.accessibilityLabel;
}

- (BOOL)slAccessibilityIsVisible {
    // a view is visible if its midpoint hit-tests to itself
    CGPoint testPoint = CGPointMake(CGRectGetMidX(self.accessibilityFrame),
                                    CGRectGetMidY(self.accessibilityFrame));
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *hitView = [window slAccessibilityHitTest:testPoint];
    return (hitView == self);
}

#pragma mark -Private methods

- (BOOL)slAccessibilityPointInside:(CGPoint)point {
    return CGRectContainsPoint(self.accessibilityFrame, point);
}

- (UIView *)slAccessibilityHitTest:(CGPoint)point {
    // we ignore views for all the same reasons as -hitTest:withEvent:
    // except -userInteractionEnabled: UIAutomation ignores it
    // (see -[SLElementVisibilityTest testViewIsVisibleEvenIfUserInteractionIsDisabled])
    if (![self slAccessibilityPointInside:point] ||
        self.hidden ||
        self.alpha < 0.01) return nil;

    // enumerate the subviews in reverse == front-to-back
    for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
        UIView *hitView = [subview slAccessibilityHitTest:point];
        if (hitView) return hitView;
    }

    return self;
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

// An object is a mock view if its accessibilityIdentifier tracks
// the accessibilityIdentifier of the view.
+ (BOOL)elementObject:(id)elementObject isMockingViewObject:(id)viewObject {
    if (![viewObject isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *view = (UIView *)viewObject;
    NSString *previousIdentifier = view.accessibilityIdentifier;
    [view setAccessibilityIdentifierWithStandardReplacement];

    BOOL isMocking = NO;
    if ([elementObject respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *mockIdentifier = [elementObject performSelector:@selector(accessibilityIdentifier)];
        isMocking = [mockIdentifier isEqualToString:view.accessibilityIdentifier];
    }

    view.accessibilityIdentifier = previousIdentifier;

    return isMocking;
}

- (BOOL)elementMockingSelfShouldAppearInAccessibilityHierarchy {
    if ([self shouldAppearInAccessibilityHierarchy]) return YES;

    if ([self classForcesPresenceOfMockingViewsInAccessibilityHierarchy]) {
        return YES;
    }

    return NO;
}

- (BOOL)classForcesPresenceOfMockingViewsInAccessibilityHierarchy {
    return NO;
}

@end


#pragma mark UIView subclass overrides

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


#pragma mark - SLAccessibilityPath implementation

@implementation SLAccessibilityPath {
    NSArray *_accessibilityElementPath, *_viewPath;
    SLMainThreadRef *_destinationRef;
}

+ (NSArray *)filterRawAccessibilityElementPath:(NSArray *)accessibilityElementPath
                              usingRawViewPath:(NSArray *)viewPath {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    __block NSUInteger viewPathIndex = 0;
    [accessibilityElementPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id objectFromAccessibilityElementPath = obj;
        id currentViewPathObject =  (viewPathIndex < [viewPath count] ?
                                        [viewPath objectAtIndex:viewPathIndex] : nil);

        // For each objectFromAccessibilityElementPath, if it mocks a view,
        // that view will be in viewAccessibilityPath. Elements from the
        // accessibilityElementPath that do not mock views (i.e. user-created
        // accessibility elements) will exist at the end of accessibilityElementPath,
        // and will also exist at the end of viewAccessibilityPath.
        if (![objectFromAccessibilityElementPath isKindOfClass:[UIView class]]) {
            while (![UIView elementObject:objectFromAccessibilityElementPath isMockingViewObject:currentViewPathObject] &&
                   currentViewPathObject) {
                viewPathIndex++;
                currentViewPathObject = (viewPathIndex < [viewPath count] ?
                                            [viewPath objectAtIndex:viewPathIndex] : nil);
            }
        }

        // Views that should appear in the hierarchy are always included
        if ([objectFromAccessibilityElementPath isKindOfClass:[UIView class]]) {
            viewPathIndex++;
            if ([objectFromAccessibilityElementPath shouldAppearInAccessibilityHierarchy]) {
                [filteredArray addObject:objectFromAccessibilityElementPath];
            }

        // Mock views are included in the hierarchy depending on the view
        } else if ([UIView elementObject:objectFromAccessibilityElementPath isMockingViewObject:currentViewPathObject]) {
            viewPathIndex++;
            if ([(UIView *)currentViewPathObject elementMockingSelfShouldAppearInAccessibilityHierarchy]) {
                [filteredArray addObject:objectFromAccessibilityElementPath];
            }

        // At this point, we only add the current objectFromAccessibilityElementPath
        // if we can be sure it's not mocking a view (by us having exhausted
        // the views in the view path) and it should appear in the accessibility hierarchy
        } else if ((![currentViewPathObject isKindOfClass:[UIView class]] &&
                    [objectFromAccessibilityElementPath shouldAppearInAccessibilityHierarchy])){
            [filteredArray addObject:objectFromAccessibilityElementPath];
        }
    }];
    return filteredArray;
}

+ (NSArray *)filterRawViewPath:(NSArray *)viewPath {
    NSMutableArray *filteredPath = [[NSMutableArray alloc] init];
    [viewPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // We will need the UIView path to contain any objects that will
        // appear in the accessibility hierarchy, as well as any objects
        // that will be accompanied by mock views that will appear in the
        // accessibility hierarchy
        if ([obj shouldAppearInAccessibilityHierarchy] ||
                ([obj isKindOfClass:[UIView class]] &&
                [(UIView *)obj elementMockingSelfShouldAppearInAccessibilityHierarchy])) {
            [filteredPath addObject:obj];
        }
    }];
    return filteredPath;
}

// As mentioned in the methods below where references' targets are retrieved:
// SLAccessibilityPath methods should not throw exceptions if
// references' targets are found to have fallen out of scope,
// because an exception thrown inside a dispatched block cannot be caught
// outside that block.
//
// SLAccessibilityPath's approach to error handling is described
// in the header.
+ (NSArray *)mapPathToBackgroundThread:(NSArray *)path {
    NSMutableArray *mappedPath = [[NSMutableArray alloc] initWithCapacity:[path count]];
    for (id obj in path) {
        [mappedPath addObject:[SLMainThreadRef refWithTarget:obj]];
    }
    return mappedPath;
}

- (instancetype)initWithRawAccessibilityElementPath:(NSArray *)accessibilityElementPath
                                        rawViewPath:(NSArray *)viewPath {
    self = [super init];
    if (self) {
        NSArray *filteredAccessibilityElementPath = [[self class] filterRawAccessibilityElementPath:accessibilityElementPath
                                                                                   usingRawViewPath:viewPath];
        NSArray *filteredViewPath = [[self class] filterRawViewPath:viewPath];

        // If, after filtering, the accessibility element path contains no elements,
        // or filtering removes the last element of the path (the path's destination)
        // the path is invalid
        if (![filteredAccessibilityElementPath count] ||
            ([filteredAccessibilityElementPath lastObject] != [accessibilityElementPath lastObject]) ||
            ![filteredViewPath count]) {
            self = nil;
            return self;
        }

        // the path's destination is given by the last element in the view path
        // (because that contains real and not mock views, as well as accessibility
        // elements generated by the application vs. the system),
        // unless it was filtered (e.g. it was a UILabel in a UITableViewCell)
        id destination;
        if ([filteredViewPath count] && ([filteredViewPath lastObject] == [viewPath lastObject])) {
            destination = [filteredViewPath lastObject];
        } else {
            destination = [filteredAccessibilityElementPath lastObject];
        }

        _accessibilityElementPath = [[self class] mapPathToBackgroundThread:filteredAccessibilityElementPath];
        _viewPath = [[self class] mapPathToBackgroundThread:filteredViewPath];
        _destinationRef = [SLMainThreadRef refWithTarget:destination];
    }
    return self;
}

- (void)examineLastPathComponent:(void (^)(NSObject *lastPathComponent))block {
    dispatch_sync(dispatch_get_main_queue(), ^{
        block([_destinationRef target]);
    });
}

// To bind the path to a unique destination, unique identifiers are set on
// the objects in the view path. This ensures that the identifiers are set
// successfully (because some mock views' identifiers cannot be set directly,
// but rather track the identifiers on their corresponding views)
// and that the path does not contain any extra elements.
//
// After the block has been executed, the accessibilityIdentifiers on each element
// in the view matching chain are reset.

- (void)bindPath:(void (^)(SLAccessibilityPath *boundPath))block {
    __block NSMutableArray *previousAccessorPathIdentifiers = [[NSMutableArray alloc] init];

    // Unique the elements' identifiers
    dispatch_sync(dispatch_get_main_queue(), ^{

        for (SLMainThreadRef *objRef in _viewPath) {
            NSObject *obj = [objRef target];

            // see note on +mapPathToBackgroundThread:;
            // we only throw a fatal exception if there *are* objects in the path
            // that differ from our assumptions
            NSAssert(!obj || [obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the view path must conform to UIAccessibilityIdentification");

            NSObject *previousIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if (previousIdentifier == nil) {
                previousIdentifier = [NSNull null];
            }
            [previousAccessorPathIdentifiers addObject:previousIdentifier];

            // see note on +mapPathToBackgroundThread:
            // we only throw a fatal exception if there *are* objects in the path
            // that differ from our assumptions
            NSAssert(!obj || [obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the view path must conform to UIAccessibilityIdentification");
            [obj setAccessibilityIdentifierWithStandardReplacement];
        }
    });

    block(self);

    // Reset the elements' identifiers
    dispatch_sync(dispatch_get_main_queue(), ^{
        // The path's elements' accessibility information is updated in reverse order,
        // because of the issue listed in the above note.
        [_viewPath enumerateObjectsUsingBlock:^(SLMainThreadRef *objRef, NSUInteger idx, BOOL *stop) {
            NSObject *obj = [objRef target];
            NSObject *identifierObj = [previousAccessorPathIdentifiers objectAtIndex:idx];
            NSString *identifier = ([identifierObj isEqual:[NSNull null]] ? nil : (NSString *)identifierObj);
            
            [obj resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:identifier];
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
        for (SLMainThreadRef *objRef in _accessibilityElementPath) {
            NSObject *obj = [objRef target];

            // see note on +mapPathToBackgroundThread:
            // we only throw a fatal exception if there *are* objects in the path
            // that differ from our assumptions
            NSAssert(!obj || [obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the mock view path must conform to UIAccessibilityIdentification");

            // On some classes you cannot set an accessibility identifer
            // e.g. UISegmentedControl. In these cases the element can
            // be identified by its accessibilityLabel and accessibilityFrame.
            NSString *currentIdentifier = [obj performSelector:@selector(accessibilityIdentifier)];
            if (![currentIdentifier length]) {
                currentIdentifier = obj.accessibilityLabel;
                CGRect accessibilityRect = [obj accessibilityFrame];

                NSString *predicate = [NSString stringWithFormat:@"(rect.x == %g) AND (rect.y == %g) AND (rect.width == %g) AND (rect.height == %g)",
                                       accessibilityRect.origin.x,
                                       accessibilityRect.origin.y,
                                       accessibilityRect.size.width,
                                       accessibilityRect.size.height];

                if ([currentIdentifier length] > 0) {
                    predicate = [predicate stringByAppendingFormat:@" AND (label like \"%@\")", [currentIdentifier slStringByEscapingForJavaScriptLiteral]];
                }

                [uiaRepresentation appendFormat:@".elements().firstWithPredicate(\"%@\")", [predicate slStringByEscapingForJavaScriptLiteral]];

            } else {
                [uiaRepresentation appendFormat:@".elements()['%@']",
                 [currentIdentifier slStringByEscapingForJavaScriptLiteral]];
            }
        }
    });
    return uiaRepresentation;
}

@end
