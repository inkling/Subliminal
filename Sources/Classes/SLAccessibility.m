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
#import <objc/runtime.h>

const CGFloat kMinVisibleAlphaFloat = 0.01;
const unsigned char kMinVisibleAlphaInt = 3; // 255 * 0.01 = 2.55, but our bitmap buffers use integer color components.

#pragma mark SLAccessibilityPath interface

@interface SLAccessibilityPath ()

/**
 Creates and returns an array containing only those objects from
 the specified accessibility element path that will appear in the accessibility
 hierarchy as understood by UIAutomation.

 These objects corresponds closely, but not entirely, to the _views_ that will appear
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
 path's referent. Providing a view path enables clients to examine
 the actual object that was matched in the event that the path's referent is a view.

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


/**
 Returns a Boolean value that indicates whether the receiver is prevented from
 existing in the accessibility hierarchy by an accessibility element above it in
 the hierarchy.
 
 Experimentation reveals that accessibilityElements decending from certain classes
 prevent any other elements from existing in the hierarchy below them.
 
 @return YES if there exists an element above the receiver in the accessibility hierarchy
 that prevents its accessibility descendents from appearing in the accessibility hierarchy.
 */
- (BOOL)accessibilityAncestorPreventsPresenceInAccessibilityHierarchy;

/// ----------------------------------------
/// @name Binding and serializing paths
/// ----------------------------------------

/**
 Returns a Boolean value that indicates whether the receiver 
 has loaded -slReplacementAccessibilityIdentifier.
 
 @return YES if +loadSLReplacementAccessibilityIdentifier has been sent
 on the receiver, otherwise NO;
 */
+ (BOOL)slReplacementAccessibilityIdentifierHasBeenLoaded;

/**
 Replaces the receiver's implementation of -accessibilityIdentifier 
 with -slReplacementAccessibilityIdentifier.
 
 This method is idempotent.

 Note that -slReplacementAccessibilityIdentifier will return the true
 value of -accessibilityIdentifier unless -useSLReplacementAccessibilityIdentifier 
 is YES.
 */
+ (void)loadSLReplacementAccessibilityIdentifier;

/**
 Indicates whether -slReplacementAccessibilityIdentifier should return
 the receiver's [replacement accessibility identifier](-slReplacementAccessibilityIdentifier), 
 or the object's [true accessibility identifier](-slTrueAccessibilityIdentifier).
 
 When this is set to YES, the receiver's class will [load -slReplacementAccessibilityIdentifier]
 (+loadSLReplacementAccessibilityIdentifier) if necessary.
 */
@property (nonatomic) BOOL useSLReplacementAccessibilityIdentifier;

/**
 Returns a replacement for -[UIAccessibilityIdentification accessibilityIdentifier] 
 if -useSLReplacementAccessibilityIdentifier is YES.

 @warning This method must not be called unless +loadSLReplacementAccessibilityIdentifier 
 has been previously sent to the receiver's class.

 @return A replacement for -accessibilityIdentifier that is unique to the receiver, 
 if -useSLReplacementAccessibilityIdentifier is YES; otherwise, the value 
 returned by the receiver's true implementation of -accessibilityIdentifier.
 **/
- (NSString *)slReplacementAccessibilityIdentifier;

/**
 Returns the true accessibility identifier of the receiver.
 
 @warning This is intentionally unimplemented. Its implementation is set 
 when +loadSLReplacementAccessibilityIdentifier is sent to the receiver's class.
 
 @return The value returned by the receiver's implementation of -accessibilityIdentifier
 prior to -slReplacementAccessibilityIdentifier having been [loaded](+loadSLReplacementAccessibilityIdentifier).
 */
- (NSString *)slTrueAccessibilityIdentifier;

@end


@interface UIView (SLAccessibility_Visibility)

/**
 Renders the input view and that views hierarchy using compositing options that
 cause the target view and all of its subviews to be drawn as black rectangles,
 while every view not in the hierarchy of the target renders with kCGBlendModeDestinationOut.
 The result is a rendering with black or gray pixels everywhere that the target view is visible.
 Pixels will be black where the target view is not occluded at all, and gray where the target view
 is occluded by views that are not fully opaque.

 @param view the view to be rendered
 @param context the drawing context in which to render view
 @param target the view whose hierarchy should be drawn as black rectangles
 @param baseView the view which provides the base coordinate system for the rendering, usually target's window.
 */
- (void)renderViewRecursively:(UIView *)view inContext:(CGContextRef)context withTargetView:(UIView *)target baseView:(UIView *)baseView;

/**
 Returns the number of points from a set of test points for which the receiver is visible in a given window.

 @param testPointsInWindow a C array of points to test for visibility
 @param count the number of elements in testPointsInWindow
 @param window the UIWindow in which to test visibility.  This should usually be
        the receiver's window, but could be a different window, for example if the
        point is to test whether the view is in one window or a different window.

 @return the number of points from testPointsInWindow at which the receiver is visible.
 */
- (NSUInteger)numberOfPointsFromSet:(const CGPoint *)testPointsInWindow count:(const NSUInteger)numPoints thatAreVisibleInWindow:(UIWindow *)window;

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
 will appear in an accessibility hierarchy.

 Experimentation reveals that a mock view will appear in the accessibility hierarchy
 if the real object will appear in [any accessibility hierarchy]
 (-willAppearInAccessibilityHierarchy) or is an instance of one of a [certain set
 of classes](-classForcesPresenceOfMockingViewsInAccessibilityHierarchy).

 @return YES if an object mocking the receiver will appear in an accessibility
 hierarchy, otherwise NO.
 */
- (BOOL)elementMockingSelfWillAppearInAccessibilityHierarchy;

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
    return [viewContainer slAccessibilityIsVisible];
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

- (BOOL)willAppearInAccessibilityHierarchy {
    // An object will not appear in the accessibility hierarchy
    // if its direct parent is an accessibility element.
    NSObject *parent = [self slAccessibilityParent];
    if ([parent isAccessibilityElement]) {
        return NO;
    }

    if ([self accessibilityAncestorPreventsPresenceInAccessibilityHierarchy]) {
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


- (BOOL)accessibilityAncestorPreventsPresenceInAccessibilityHierarchy {
    id parent = [self slAccessibilityParent];
    while (parent) {
        if ([parent isKindOfClass:[UIControl class]] && [parent isAccessibilityElement]) {
            return YES;
        }
        parent = [parent slAccessibilityParent];
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

// At the NSObject level, we identify several private classes that seem to be
// special cases that will always appear in the accessibility hierarchy.
// We identify them by their context to avoid accessing or referencing private APIs.
- (BOOL)classForcesPresenceInAccessibilityHierarchy {
    id parent = [self slAccessibilityParent];

    // We identify UIWebBrowserViews by their superviews and by
    // the non-UIAccessibilityElement objects they vend from elementAtAccessibilityIndex:.
    BOOL isWebBrowserView = NO;
    if([parent isKindOfClass:[UIScrollView class]] &&
       [[parent slAccessibilityParent] isKindOfClass:[UIWebView class]]) {
        NSInteger elementCount = [self accessibilityElementCount];
        if (elementCount != NSNotFound && elementCount > 0) {
            for (NSUInteger i = 0; i < elementCount; i++) {
                id accessibilityObject = [self accessibilityElementAtIndex:i];
                if (![accessibilityObject isKindOfClass:[UIAccessibilityElement class]]) {
                    isWebBrowserView = YES;
                    break;
                }
            }
        }
    }
    if (isWebBrowserView) return YES;

    // UITableViewSectionElements are mock views created for UITableView header views,
    // which return NO from -isAccessibilityElement and do not carry any accessibility
    // information--thus will not otherwise pass -shouldAppearInAccessibilityHierarchy
    // or -elementObject:isMockingViewObject:--but will still appear in the hierarchy.
    // We identify them as accessibility elements vended by their parent table views.
    BOOL isTableViewSectionElement = NO;
    if ([parent isKindOfClass:[UITableView class]] &&
        [self isKindOfClass:[UIAccessibilityElement class]]) {
        NSInteger elementCount = [parent accessibilityElementCount];
        if (elementCount != NSNotFound && elementCount > 0) {
            for (NSUInteger i = 0; i < elementCount; i++) {
                if (self == [parent accessibilityElementAtIndex:i]) {
                    isTableViewSectionElement = YES;
                    break;
                }
            }
        }
    }
    if (isTableViewSectionElement) return YES;

    // _UIPopoverView is identified by its parent's label.
    BOOL isPopover = [[parent accessibilityLabel] isEqualToString:@"dismiss popup"];
    if (isPopover) return YES;

    return NO;
}

static const void *const kSLReplacementAccessibilityIdentifierHasBeenLoadedKey = &kSLReplacementAccessibilityIdentifierHasBeenLoadedKey;
+ (BOOL)slReplacementAccessibilityIdentifierHasBeenLoaded {
    if ([objc_getAssociatedObject(self, kSLReplacementAccessibilityIdentifierHasBeenLoadedKey) boolValue]) {
        return YES;
    }

    // -slReplacementAccessibilityIdentifier might have been loaded on a superclass;
    // if the subclass doesn't override -accessibilityIdentifier,
    // it's loaded on the subclass too
    Method accessibilityIdentifierMethod = class_getInstanceMethod(self, @selector(accessibilityIdentifier));
    IMP accessibilityIdentifierImp = method_getImplementation(accessibilityIdentifierMethod);
    
    Method replacementIdentifierMethod = class_getInstanceMethod(self, @selector(slReplacementAccessibilityIdentifier));
    IMP replacementIdentifierIMP = method_getImplementation(replacementIdentifierMethod);

    if (accessibilityIdentifierImp == replacementIdentifierIMP) {
        [self setSLReplacementAccessibilityIdentifierHasBeenLoaded];
        return YES;
    }

    return NO;
}

+ (void)setSLReplacementAccessibilityIdentifierHasBeenLoaded {
    objc_setAssociatedObject(self, kSLReplacementAccessibilityIdentifierHasBeenLoadedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)loadSLReplacementAccessibilityIdentifier {
    if (![self slReplacementAccessibilityIdentifierHasBeenLoaded]) {
        // we use class_getInstanceMethod to get the original IMP
        // rather than using the return value of class_replaceMethod
        // because class_replaceMethod returns NULL when it overrides a superclass' implementation
        Method originalIdentifierMethod = class_getInstanceMethod(self, @selector(accessibilityIdentifier));
        IMP originalIdentifierImp = method_getImplementation(originalIdentifierMethod);

        Method replacementIdentifierMethod = class_getInstanceMethod(self, @selector(slReplacementAccessibilityIdentifier));
        IMP replacementIdentifierIMP = method_getImplementation(replacementIdentifierMethod);
        const char *replacementIdentifierTypes = method_getTypeEncoding(replacementIdentifierMethod);

        (void)class_replaceMethod(self, method_getName(originalIdentifierMethod), replacementIdentifierIMP, replacementIdentifierTypes);
        class_addMethod(self, @selector(slTrueAccessibilityIdentifier), originalIdentifierImp, replacementIdentifierTypes);

        [self setSLReplacementAccessibilityIdentifierHasBeenLoaded];
    }
}

static const void *const kUseSLReplacementIdentifierKey = &kUseSLReplacementIdentifierKey;
- (BOOL)useSLReplacementAccessibilityIdentifier {
    return [objc_getAssociatedObject(self, kUseSLReplacementIdentifierKey) boolValue];
}

- (void)setUseSLReplacementAccessibilityIdentifier:(BOOL)useSLReplacementAccessibilityIdentifier {
    if (useSLReplacementAccessibilityIdentifier) {
        [[self class] loadSLReplacementAccessibilityIdentifier];
    }
    objc_setAssociatedObject(self, kUseSLReplacementIdentifierKey, @(useSLReplacementAccessibilityIdentifier), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)slReplacementAccessibilityIdentifier {
    NSAssert([[self class] slReplacementAccessibilityIdentifierHasBeenLoaded],
             @"-slReplacementAccessibilityIdentifier must not be called before it has been loaded.");
    
    if (self.useSLReplacementAccessibilityIdentifier) {
        return [NSString stringWithFormat:@"%@: %p", [self class], self];
    } else {
        return [self slTrueAccessibilityIdentifier];
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
    return [viewContainer slAccessibilityIsVisible];
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

#pragma mark -Private methods

- (void)renderViewRecursively:(UIView *)view inContext:(CGContextRef)context withTargetView:(UIView *)target baseView:(UIView *)baseView {
    // Skip any views that are hidden or have alpha < kMinVisibleAlphaFloat.
    if (view.hidden || view.alpha < kMinVisibleAlphaFloat) {
        return;
    }

    // Push the drawing state to save the clip mask.
    CGContextSaveGState(context);
    if ([view clipsToBounds]) {
        CGContextClipToRect(context, [baseView convertRect:view.bounds fromView:view]);
    }

    // Push the drawing state to save the CTM.
    CGContextSaveGState(context);

    // Apply a transform that takes the origin to view's top left corner.
    const CGPoint viewOrigin = [baseView convertPoint:view.bounds.origin fromView:view];
    CGContextTranslateCTM(context, viewOrigin.x, viewOrigin.y);

    // If this is *not* in our target view's hierarchy then use the destination
    // out blend mode to reduce the visibility of any already painted pixels by
    // the alpha of the current view.
    //
    // If this is in our target view's hierarchy then just draw a black rectangle
    // covering the whole thing.
    if (![view isDescendantOfView:target]) {
        CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
        // Draw the view.  I haven't found anything better than this, unfortunately.
        // renderInContext is pretty inefficient for our purpose because it renders
        // the whole tree under view instead of *only* rendering view.
        [view.layer renderInContext:context];
    } else {
        CGContextSetFillColor(context, (CGFloat[2]){0.0, 1.0});
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextFillRect(context, view.bounds);
    }

    // Restore the CTM.
    CGContextRestoreGState(context);

    // Recurse for subviews
    for (UIView *subview in [view subviews]) {
        [self renderViewRecursively:subview inContext:context withTargetView:target baseView:baseView];
    }

    // Restore the clip mask.
    CGContextRestoreGState(context);
}

- (NSUInteger)numberOfPointsFromSet:(const CGPoint *)testPointsInWindow count:(const NSUInteger)numPoints thatAreVisibleInWindow:(UIWindow *)window {
    static CGColorSpaceRef rgbColorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    });

    NSParameterAssert(numPoints > 0);
    NSParameterAssert(testPointsInWindow != NULL);
    NSParameterAssert(window != nil);

    // Allocate a buffer sufficiently large to store a rendering that could possibly cover all the test points.
    int x = rintf(testPointsInWindow[0].x);
    int y = rintf(testPointsInWindow[0].y);
    int minX = x;
    int maxX = x;
    int minY = y;
    int maxY = y;
    for (NSUInteger j = 1; j < numPoints; j++) {
        x = rintf(testPointsInWindow[j].x);
        y = rintf(testPointsInWindow[j].y);
        minX = MIN(minX, x);
        maxX = MAX(maxX, x);
        minY = MIN(minY, y);
        maxY = MAX(maxY, y);
    }
    NSAssert(maxX >= minX, @"maxX (%d) should be greater than or equal to minX (%d)", maxX, minX);
    NSAssert(maxY >= minY, @"maxY (%d) should be greater than or equal to minY (%d)", maxY, minY);
    size_t columns = maxX - minX + 1;
    size_t rows = maxY - minY + 1;
    unsigned char *pixels = (unsigned char *)malloc(columns * rows * 4);
    CGContextRef context = CGBitmapContextCreate(pixels, columns, rows, 8, 4 * columns, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -minX, -minY);
    [self renderViewRecursively:window inContext:context withTargetView:self baseView:window];

    NSUInteger count = 0;
    for (NSUInteger j = 0; j < numPoints; j++) {
        int x = rintf(testPointsInWindow[j].x);
        int y = rintf(testPointsInWindow[j].y);
        NSAssert(x >= minX, @"Invalid x encountered, %d, but min is %d", x, minX);
        NSAssert(y >= minY, @"Invalid y encountered, %d, but min is %d", y, minY);
        NSUInteger col = x - minX;
        NSUInteger row = y - minY;
        NSUInteger pixelIndex = row * columns + col;
        NSAssert(pixelIndex < columns * rows, @"Encountered invalid pixel index: %ul", pixelIndex);
        if (pixels[4 * pixelIndex + 3] >= kMinVisibleAlphaInt) {
            count++;
        }
    }

    CGContextRelease(context);
    free(pixels);

    return count;
}

- (BOOL)slAccessibilityIsVisible {
    // View is not visible if it's hidden or has very low alpha.
    if (self.hidden || self.alpha < kMinVisibleAlphaFloat) {
        return NO;
    }

    // View is not visible if its center point is not inside its window.
    const CGRect accessibilityFrame = self.accessibilityFrame;
    const CGPoint centerInScreenCoordinates = CGPointMake(CGRectGetMidX(accessibilityFrame), CGRectGetMidY(accessibilityFrame));

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    const CGPoint centerInWindow = [window convertPoint:centerInScreenCoordinates fromWindow:nil];

    const CGRect windowBounds = [window bounds];
    if (!CGRectContainsPoint(windowBounds, centerInWindow)) {
        return NO;
    }

    // View is not visible if it is a descendent of any hidden view.
    UIView *parent = [self superview];
    while (parent) {
        if (parent.hidden || parent.alpha < kMinVisibleAlphaFloat) {
            return NO;
        }
        parent = [parent superview];
    }

    // Subliminal's visibility rules are:
    // 1.  If the center is visible then the view is visible.
    // 2.  If the center is not visible *and* at least one corner is not visible then the view is not visible.
    // 3.  If the center is not visible but *all four* corners are visible (strange as that would be) the view is visible.
    if ([self numberOfPointsFromSet:&centerInWindow count:1 thatAreVisibleInWindow:window] == 0) {
        // Center is covered, so check the status of the corners.
        const CGPoint topLeftInScreenCoordinates = CGPointMake(CGRectGetMinX(accessibilityFrame), CGRectGetMinY(accessibilityFrame));
        const CGPoint topRightInScreenCoordinates = CGPointMake(CGRectGetMaxX(accessibilityFrame) - 1.0, CGRectGetMinY(accessibilityFrame));
        const CGPoint bottomLeftInScreenCoordinates = CGPointMake(CGRectGetMinX(accessibilityFrame), CGRectGetMaxY(accessibilityFrame) - 1.0);
        const CGPoint bottomRightInScreenCoordinates = CGPointMake(CGRectGetMaxX(accessibilityFrame) - 1.0, CGRectGetMaxY(accessibilityFrame) - 1.0);
        const CGPoint topLeftInWindow = [window convertPoint:topLeftInScreenCoordinates fromWindow:nil];
        const CGPoint topRightInWindow = [window convertPoint:topRightInScreenCoordinates fromWindow:nil];
        const CGPoint bottomLeftInWindow = [window convertPoint:bottomLeftInScreenCoordinates fromWindow:nil];
        const CGPoint bottomRightInWindow = [window convertPoint:bottomRightInScreenCoordinates fromWindow:nil];
        NSUInteger numberOfVisiblePoints = [self numberOfPointsFromSet:(CGPoint[4]){topLeftInWindow, topRightInWindow, bottomLeftInWindow, bottomRightInWindow} count:4 thatAreVisibleInWindow:window];
        // View with a covered center is visible only if all four corners are visible.
        return (numberOfVisiblePoints == 4);
    } else {
        // Center is not covered, so consider the view visible no matter what else is going on.
        return YES;
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

// An object is a mock view if its accessibilityIdentifier tracks
// the accessibilityIdentifier of the view.
+ (BOOL)elementObject:(id)elementObject isMockingViewObject:(id)viewObject {
    if (![viewObject isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *view = (UIView *)viewObject;
    NSString *previousIdentifier = view.accessibilityIdentifier;
    view.accessibilityIdentifier = [NSString stringWithFormat:@"%@: %p", [view class], view];

    BOOL isMocking = NO;
    if ([elementObject respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString *mockIdentifier = [elementObject performSelector:@selector(accessibilityIdentifier)];
        isMocking = [mockIdentifier isEqualToString:view.accessibilityIdentifier];
    }

    view.accessibilityIdentifier = previousIdentifier;

    return isMocking;
}

- (BOOL)elementMockingSelfWillAppearInAccessibilityHierarchy {
    if ([self willAppearInAccessibilityHierarchy]) return YES;

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

@implementation UILabel (SLAccessibility)

- (BOOL)accessibilityAncestorPreventsPresenceInAccessibilityHierarchy {
    if ([super accessibilityAncestorPreventsPresenceInAccessibilityHierarchy]) return YES;

    NSObject *parent = [self slAccessibilityParent];
    // A label will not appear in the accessibility hierarchy
    // if it is contained within a UITableViewCell, at any depth
    // -- UITableViewCells create a mock element that aggregates sublabels' text;
    // we can match that combined label, but not individual labels.
    do {
        if ([parent isKindOfClass:[UITableViewCell class]]) return YES;
    } while ((parent = [parent slAccessibilityParent]));

    return NO;
}

@end


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
    NSArray *_accessibilityElementPath;
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

        // Views that will appear in the hierarchy are always included
        if ([objectFromAccessibilityElementPath isKindOfClass:[UIView class]]) {
            viewPathIndex++;
            if ([objectFromAccessibilityElementPath willAppearInAccessibilityHierarchy]) {
                [filteredArray addObject:objectFromAccessibilityElementPath];
            }

        // Mock views are included in the hierarchy depending on the view
        } else if ([UIView elementObject:objectFromAccessibilityElementPath isMockingViewObject:currentViewPathObject]) {
            viewPathIndex++;
            if ([(UIView *)currentViewPathObject elementMockingSelfWillAppearInAccessibilityHierarchy]) {
                [filteredArray addObject:objectFromAccessibilityElementPath];
            }

        // At this point, we only add the current objectFromAccessibilityElementPath
        // if we can be sure it's not mocking a view (by us having exhausted
        // the views in the view path) and it will appear in the accessibility hierarchy
        } else if ((![currentViewPathObject isKindOfClass:[UIView class]] &&
                    [objectFromAccessibilityElementPath willAppearInAccessibilityHierarchy])){
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
        if ([obj willAppearInAccessibilityHierarchy] ||
                ([obj isKindOfClass:[UIView class]] &&
                [(UIView *)obj elementMockingSelfWillAppearInAccessibilityHierarchy])) {
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
            ([filteredAccessibilityElementPath lastObject] != [accessibilityElementPath lastObject])) {
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
        _destinationRef = [SLMainThreadRef refWithTarget:destination];
    }
    return self;
}

- (void)examineLastPathComponent:(void (^)(NSObject *lastPathComponent))block {
    dispatch_sync(dispatch_get_main_queue(), ^{
        block([_destinationRef target]);
    });
}

- (void)bindPath:(void (^)(SLAccessibilityPath *boundPath))block {
    // To bind the path to a unique destination, each object in the mock view path
    // is caused to return a unique replacement identifier. This is done by swizzling
    // -accessibilityIdentifier because some objects' identifiers cannot be set directly
    // (e.g. UISegmentedControl, some mock views).
    //
    // @warning This implementation assumes that there's only one SLAccessibilityPath
    // binding/bound at a time. It also assumes that it's unlikely that clients
    // other than UIAccessibility will try to read the elements' identifiers
    // while bound.
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (SLMainThreadRef *objRef in _accessibilityElementPath) {
            NSObject *obj = [objRef target];

            // see note on +mapPathToBackgroundThread:;
            // we only throw a fatal exception if there *are* objects in the path
            // that differ from our assumptions
            NSAssert(!obj || [obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the view path must conform to UIAccessibilityIdentification");

            obj.useSLReplacementAccessibilityIdentifier = YES;
        }
    });

    block(self);

    // Set the objects to use the original -accessibilityIdentifier again.
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (SLMainThreadRef *objRef in _accessibilityElementPath) {
            NSObject *obj = [objRef target];
            obj.useSLReplacementAccessibilityIdentifier = NO;
        }
    });
}

- (NSString *)UIARepresentation {
    __block NSMutableString *uiaRepresentation = [@"UIATarget.localTarget().frontMostApp().mainWindow()" mutableCopy];
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (SLMainThreadRef *objRef in _accessibilityElementPath) {
            NSObject *obj = [objRef target];

            // see note on +mapPathToBackgroundThread:
            // we only throw a fatal exception if there *are* objects in the path
            // that differ from our assumptions
            NSAssert(!obj || [obj respondsToSelector:@selector(accessibilityIdentifier)],
                     @"elements in the mock view path must conform to UIAccessibilityIdentification");

            NSString *identifier = [obj performSelector:@selector(accessibilityIdentifier)];
            NSAssert(!obj || [identifier length], @"Accessibility paths can only be serialized while bound.");

            [uiaRepresentation appendFormat:@".elements()['%@']", [identifier slStringByEscapingForJavaScriptLiteral]];
        }
    });
    return uiaRepresentation;
}

@end
