//
//  SLElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/19/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLUIAElement.h"

/**
 Instances of `SLElement` allow you to access and manipulate user interface
 elements that match criteria such as having certain accessible values
 or being of a particular type of control.

 These criteria are specified when `SLElement` is constructed, in the form of a
 predicate. When `SLElement` needs to access its corresponding interface element,
 it evaluates the element hierarchy using that predicate. If a matching object
 is found, it is made available to Subliminal and to UIAutomation
 to access and manipulate.
 */
@interface SLElement : SLUIAElement

/**
 Creates and returns an element that matches objects in the accessibility hierarchy
 with the specified accessibility label.

 An accessibility label is the preferred way to identify an element to Subliminal, 
 because accessibility labels are visible to users of assistive applications.
 See the UIAccessibility Protocol Reference for guidance in determining appropriate 
 labels.

 @param label A label that identifies a matching object.
 @return A newly created element that matches objects in the accessibility
 hierarchy with the specified accessibility label.
 */
+ (instancetype)elementWithAccessibilityLabel:(NSString *)label;

/**
 Creates and returns an element that matches objects in the accessibility hierarchy
 with the specified accessibility label, value, and/or traits.

 See the UIAccessibility Protocol Reference for guidance in determining
 appropriate accessibility labels, values, and traits.
 
 @param label A label that identifies a matching object. 
 If this is `nil`, the element does not restrict matches by label.
 @param value The value of a matching object. 
 If this is `nil`, the element does not restrict matches by value.
 @param traits The combination of accessibility traits that characterize a 
 matching object. If this is `SLUIAccessibilityTraitAny`, the element does not 
 restrict matches by trait.
 */
+ (instancetype)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

/**
 Creates and returns an element that matches objects in the accessibility hierarchy
 with the specified accessibility identifier.

 It is best to identify an object using information like its accessibility label,
 value, and/or traits, because that information also helps users with disabilities
 use your application. However, when that information is not sufficient to
 identify an object, an accessibility identifier may be set by the application. 
 Unlike accessibility labels, identifiers are not visible to users of assistive 
 applications.

 @param identifier A string that uniquely identifies a matching object.
 @return A newly created element that matches objects in the accessibility
 hierarchy with the specified accessibility identifier.
 */
+ (instancetype)elementWithAccessibilityIdentifier:(NSString *)identifier;

/**
 Creates and returns an element that evaluates the accessibility hierarchy
 using a specified block object.

 This method allows you to apply some knowledge of the target object's identity
 and/or its location in the view hierarchy, where the target object's accessibility
 information is not sufficient to distinguish the object.

 Consider using one of the more specialized constructors before this method.
 It is best to identify an object using information like its accessibility label, 
 value, and/or traits, because that information also helps users with disabilities 
 use your application. Even when that information is not sufficient to distinguish 
 a target object, it may be easier for your application to set a unique
 accessibility identifier on a target object than for your tests to define a 
 complex predicate.

 @param predicate The block used to evaluate objects within the accessibility 
 hierarchy. The block will be evaluated on the main thread. The block should 
 return YES if the element matches the object, otherwise NO.
 @param description An optional description of the element, for use in debugging.
 (The other `SLElement` constructors derive element descriptions from their arguments.)
 @return A newly created element that evaluates objects using predicate.
 
 @see +elementWithAccessibilityIdentifier:
 */
+ (instancetype)elementMatching:(BOOL (^)(NSObject *obj))predicate withDescription:(NSString *)description;

/**
 Creates and returns an element that matches any object in the accessibility hierarchy.

 SLElement defines this constructor primarily for the benefit of subclasses
 that match a certain kind of object by default, such that a match is likely
 unique even without the developer specifying additional information. For instance,
 if your application only has one webview onscreen at a time, you could match
 that webview (using `SLWebView`) by matching "any" webview, without having to
 give that webview an accessibility label or identifier.

 @return A newly created element that matches any object in the accessibility hierarchy.
 */
+ (instancetype)anyElement;

@end


/// Used with `+[SLElement elementWithAccessibilityLabel:value:traits:]`
/// to match elements with any combination of accessibility traits.
extern UIAccessibilityTraits SLUIAccessibilityTraitAny;
