//
//  SLElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/19/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLUIAElement.h"

/**
 Instances of SLElement allow you to access and manipulate user interface
 elements that match criteria such as having certain accessible values
 or being of a particular type of control.

 These criteria are specified, when SLElement is constructed, in the form of a
 predicate. When SLElement needs to access its corresponding interface element,
 it evaluates the element hierarchy using that predicate. If a matching object
 is found, it is made available to Subliminal to examine and/or to UIAutomation
 to manipulate.
 */
@interface SLElement : SLUIAElement

/**
 Creates and returns an element that evaluates the accessibility hierarchy
 using a specified block object.

 @param predicate The block is applied to the object to be evaluated.
 The block returns YES if the element matches the object, otherwise NO.
 @param description An optional description of the element, for use in debugging.
 (The other SLElement constructors derive element descriptions from their arguments.)
 @return A new element that evaluates objects using predicate.
 */
+ (instancetype)elementMatching:(BOOL (^)(NSObject *obj))predicate withDescription:(NSString *)description;

/**
 Returns an element which matches any object in the accessibility hierarchy.

 SLElement defines this constructor primarily for the benefit of subclasses
 that match a certain kind of object by default, such that a match is likely
 unique even without the developer specifying additional information. For instance,
 if your application only has one webview onscreen at a time, you could match
 that webview (using SLWebView) by matching "any" webview, without having to
 give that webview an accessibility label or identifier.

 @return An element which matches any object in the accessibility hierarchy.
 */
+ (instancetype)anyElement;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName.
+ (instancetype)elementWithAccessibilityLabel:(NSString *)label;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName, accessibilityValue, and matching the traits accessibilityTraits mask.
// If label is nil the condition on slAccessibilityName is ignored.
// If value is nil the condition on accessibilityValue is ignored.
+ (instancetype)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

@end
