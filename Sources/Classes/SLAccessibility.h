//
//  SLAccessibility.h
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//


@class SLElement;
@class SLAccessibilityPath;

/**
 The methods in the `NSObject (SLAccessibility)` category
 allow Subliminal to access and manipulate the accessibility hierarchy
 --a subset of the hierarchy formed by views and the accessibility elements
 they vend--for the purposes of describing the hierarchy to the user, for debugging;
 and to UIAutomation, in order to evaluate expressions involving the `UIAElement` 
 instances corresponding to `SLElement` instances.
 */
@interface NSObject (SLAccessibility)

/**
 Returns the accessibility path from this object to the object 
 [matching](-[SLElement matchesObject:]) the specified element.

 The first component in the path is the receiver, and the last component 
 is an object matching the specified element.

 @param element The element to be matched.
 @return A path that can used by UIAutomation to access element or `nil`
 if an object matching `element` is not found within the accessibility hierarchy
 rooted in the receiver.
 */
- (SLAccessibilityPath *)slAccessibilityPathToElement:(SLElement *)element;

/**
 Returns a Boolean value that indicates whether the receiver will appear
 in the accessibility hierarchy.
 
 The receiver will only be accessible to UIAutomation if it appears in the 
 hierarchy. Experimentation reveals that presence in the hierarchy is determined 
 by a combination of the receiver's accessibility information and its location 
 in the view hierarchy.
 
 See the method's implementation for specifics, or use the Accessibility Inspector: 
 if it can read an element's information, some underlying object is present 
 in the hierarchy.

 @return YES if the receiver will appear in the accessibility hierarchy,
 otherwise NO.
 */
- (BOOL)willAppearInAccessibilityHierarchy;

/**
 Determines if the specified object is visible on the screen.
 
 @return YES if the receiver is visible within the accessibility hierarchy, 
 NO otherwise.
 */
- (BOOL)slAccessibilityIsVisible;

/**
 Returns the SLAccessibility-specific accessibility container of the receiver.

 This method allows the developer to navigate upwards through the hierarchy 
 constructed by `-slChildAccessibilityElementsFavoringSubviews:`. That hierarchy 
 is not guaranteed to contain only those elements that will appear in the 
 accessibility hierarchy.

 @return The object's superview, if it is a `UIView`;
 otherwise its `accessibilityContainer`, if it is a `UIAccessibilityElement`;
 otherwise `nil`.
 
 @see -willAppearInAccessibilityHierarchy
 */
- (NSObject *)slAccessibilityParent;

/**
 Creates and returns an array of objects that are child accessibility elements
 of this object.

 If the receiver is a `UIView`, this will also include subviews.
 
 This method, applied recursively, will construct a hierarchy that includes 
 all accessibility elements and views of the receiver. This hierarchy is not 
 guaranteed to contain only those elements that will appear in the accessibility 
 hierarchy.

 @param favoringSubviews If YES, views should be placed before accessibility 
 elements in the returned array; otherwise, they will be placed afterwards.

 @return An array of objects that are child accessibility elements of this object.
 
 @see -willAppearInAccessibilityHierarchy
 */
- (NSArray *)slChildAccessibilityElementsFavoringSubviews:(BOOL)favoringSubviews;

/**
 Returns the index of the specified child element in the array of the
 child accessibility elements of the receiver.

 @param childElement A child accessibility element of the receiver.
 @param favoringSubviews If `YES`, subviews should be ordered before
 accessibility elements among the receiver's child accessibility elements;
 otherwise, they will be ordered afterwards.
 @return The index of the child element in the array of child accessibility 
 elements of the receiver.
 
 @see -slChildAccessibilityElementsFavoringSubviews:
 @see -slAccessibilityParent
 */
- (NSUInteger)slIndexOfChildAccessibilityElement:(NSObject *)childElement favoringSubviews:(BOOL)favoringSubviews;

/**
 Returns the child accessibility element of the receiver at the specified index.

 @param index The index of the child accessibility element to be returned.
 @param favoringSubviews If `YES`, subviews should be ordered before
 accessibility elements among the receiver's child accessibility elements;
 otherwise, they will be ordered afterwards.
 @return The child accessibility element at the specified index in the array 
 of the child accessibility elements of the receiver.
 
 @see -slChildAccessibilityElementsFavoringSubviews:
 @see -slAccessibilityParent
 */
- (NSObject *)slChildAccessibilityElementAtIndex:(NSUInteger)index favoringSubviews:(BOOL)favoringSubviews;

/// ----------------------------------------
/// @name Debug methods
/// ----------------------------------------

/**
 Returns a string that describes the receiver in terms of its accessibility properties.

 @return A string that describes the receiver in terms of its accessibility properties.
 */
- (NSString *)slAccessibilityDescription;

/**
 Returns a string that recursively describes accessibility elements contained
 within the receiver.
 
 In terms of their accessibility properties, using `-slAccessibilityDescription`.

 If the receiver is a `UIView`, this also enumerates the subviews of the receiver.
 
 @warning This method describes all elements contained within the receiver,
 even if they [will not appear in the accessibility hierarchy](-willAppearInAccessibilityHierarchy). 
 That is, the set of elements described by this method is a superset of those
 elements that will appear in the accessibility hierarchy. To log only those 
 elements that will appear in the accessibility hierarchy, use `-[SLUIAElement logElementTree]`.
 
 @return A string that recursively describes the receiver and its accessibility children
 in terms of their accessibility properties.
 */
- (NSString *)slRecursiveAccessibilityDescription;

@end


/**
 `SLAccessibilityPath` represents a path through an accessibility hierarchy
 from an accessibility container to one of its (potentially distant) children.

 Once a path is found between a parent and child object using
 `-[NSObject slAccessibilityPathToElement:]`, it can then be 
 [serialized into Javascript](-UIARepresentation) in order to identify, 
 access, and manipulate the `UIAElement` corresponding to the child when
 [evaluated](-[SLTerminal eval:]) as part of a larger expression.
 
 @warning `SLAccessibilityPath` is designed for use from background threads.
 Because its components are likely `UIKit` objects, `SLAccessibilityPath`
 holds weak references to those components. Clients should be prepared
 to handle nil [path components](-examineLastPathComponent:) or invalid 
 [UIAutomation representations](-UIARepresentation) in the event that a path
 component drops out of scope.
 */
@interface SLAccessibilityPath : NSObject

/**
 Allows the caller to interact with the last path component of the receiver.
 
 Path components are objects at successive levels of an accessibility hierarchy 
 (where the component at index `i + 1` is the child of the component at index `i`).
 The last path component is the object at the deepest level of such a hierarchy, 
 i.e. the destination of the path.
 
 The block will be executed synchronously on the main thread.

 @param block A block which takes the last path component of the receiver 
 as an argument and returns void. The block may invoked with a `nil` argument
 if the last path component has dropped out of scope between the receiver being
 constructed and it receiving this message.
 */
- (void)examineLastPathComponent:(void (^)(NSObject *lastPathComponent))block;

/**
 Binds the components of the receiver to unique `UIAElement` instances 
 for the duration of the method.
 
 This is done by modifying the components' accessibility properties in such a 
 way as to make the names (`UIAElement.name()`) of their corresponding `UIAElement` 
 instances unique. With the modifications in place, the block provided is then 
 evaluated, on the calling thread, with the receiver. The modifications are then 
 reset.

 @param block A block which takes the bound receiver as an argument and returns 
 `void`.
 
 @see -UIARepresentation
 */
- (void)bindPath:(void (^)(SLAccessibilityPath *boundPath))block;

/**
 Returns the representation of the path as understood by UIAutomation.

 This method operates by serializing the objects constituting the path's components
 as references into successive instances of `UIElementArray`, the outermost of 
 which is contained by the main window. That is, this method creates a JavaScript 
 expression of the form:

    UIATarget.localTarget().frontMostApp().mainWindow().elements()[...].elements()[...]...

 Each reference into a `UIAElementArray` (within brackets) is by element name
 (`UIAElement.name()`). Any components that the receiver was unable to name 
 (e.g. components which have dropped out of scope between the receiver being 
 constructed and it receiving this message) will be serialized as `elements()["(null)"]`.

 @warning To guarantee that each `UIAElementArray` reference will uniquely identify
 the corresponding component of the receiver, this method must only be called 
 while the receiver is [bound](-bindPath:).
 
 @bug This method should not assume that the path identifies elements within
 the main window.

 @return A JavaScript expression that represents the absolute path to the `UIAElement`
 corresponding to the last component of the receiver.
 */
- (NSString *)UIARepresentation;

@end
