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
 The methods in the NSObject (SLAccessibility) category 
 allow Subliminal to access and manipulate the accessibility hierarchy
 --a subset of the hierarchy formed by views and the accessibility elements
 they vend--for the purposes of describing the hierarchy to the user, for debugging;
 and to UIAutomation, in order to evaluate expressions involving the `UIAElement`s 
 corresponding to SLElements.
 */
@interface NSObject (SLAccessibility)

/** 
 A string Subliminal will use to match this object with an SLElement.
 
 The default implementation returns the object's accessibility identifier, 
 if the object responds to -accessibilityIdentifier and the identifier is non-empty,
 otherwise the object's accessibility label.
 */
@property (nonatomic, readonly) NSString *slAccessibilityName;

/**
 Returns the accessibility path from this object to the object [matching](-[SLElement matchesObject:]) 
 the specified element.

 The first component in the path is the receiver, and the last component 
 is an object matching the specified element.

 @param element The element to be matched.
 @return A path that can used by UIAutomation to access element or `nil`
 if an object matching element is not found within the accessibility hierarchy 
 rooted in the receiver.
 */
- (SLAccessibilityPath *)slAccessibilityPathToElement:(SLElement *)element;

/**
 Returns a Boolean value that indicates whether the receiver will appear
 in the accessibility hierarchy.
 
 The receiver will only be accessible to UIAutomation if it appears in the 
 hierarchy. Experimentation reveals that presence in the hierarchy is determined by a
 combination of the receiver's accessibility information and its location in the
 view hierarchy.
 
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

 This method is the inverse of slChildAccessibilityElementsFavoringUISubviews:,
 and not necessarily the inverse of UIAutomation's accessibility hierarchy.
 Objects returned from this method come with no guarantee regarding their
 accessibility identification or existence in the accessibility hierarchy.

 @return The object's superview, if it is a view; otherwise its accessibilityContainer,
 if it is an accessibility element; otherwise `nil`.
 */
- (NSObject *)slAccessibilityParent;

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
/// @name Debug methods
/// ----------------------------------------

- (NSString *)slAccessibilityDescription;
- (NSString *)slRecursiveAccessibilityDescription;

@end


/**
 SLAccessibilityPath represents a path through an accessibility hierarchy 
 from an accessibility container to one of its (potentially distant) children.

 Once a path is [found](-[NSObject slAccessibilityPathToElement:]) between a 
 parent and child object, it can then be [serialized into Javascript]](-UIARepresentation) 
 in order to identify, access, and manipulate the `UIAElement` corresponding to 
 the child when [evaluated](-[SLTerminal eval:]) as part of a larger expression.
 
 @warning SLAccessibilityPath is designed for use from background threads. 
 Because its components are likely UIKit objects, SLAccessibilityPath
 holds weak references to those components. Clients should be prepared
 to handle nil [path components](-examineLastPathComponent:) or invalid 
 [UIAutomation representations](-UIARepresentation).
 */
@interface SLAccessibilityPath : NSObject

/**
 Allows the caller to interact with the last path component of the receiver.
 
 Path components are objects at successive levels of an accessibility hierarchy 
 (where the component at index i + 1 is the child of the component at index i).
 The last path component is the object at the deepest level of such a hierarchy, 
 i.e. the destination of the path.
 
 The block will be executed synchronously on the main thread.

 @param block A block which takes the last path component of the receiver 
 as an argument and returns void. The block may invoked with a nil argument 
 if the last path component has dropped out of scope between the receiver being
 constructed and it receiving this message.
 */
- (void)examineLastPathComponent:(void (^)(NSObject *lastPathComponent))block;

/**
 Binds the components of the receiver to unique `UIAElement`s for the duration
 of the method.
 
 This is done by modifying the components' accessibility properties in such a 
 way as to make their corresponding `UIAElement`s' names (`UIAElement.name()`) unique.
 With the modifications in place, the block provided is then evaluated, on the calling 
 thread, with the receiver. The modifications are then reset.

 @param block A block which takes the bound receiver as an argument and returns 
 void.
 
 @see -UIARepresentation
 */
- (void)bindPath:(void (^)(SLAccessibilityPath *boundPath))block;

/**
 Returns the representation of the path as understood by UIAutomation.

 This method operates by serializing the objects constituting the path's components
 as references into successive UIElementArrays, the outermost of which is
 contained by the main window. That is, this method creates a Javascript expression
 of the form:

    UIATarget.localTarget().frontMostApp().mainWindow().elements()[...].elements()[...]...

 The `UIAElementArray` references (within the brackets) are by element name
 (`UIAElement.name()`): for each path component, its accessibility identifier,
 if the identifier exists and is non-empty; otherwise, its accessibility label.
 
 Any components that the receiver was unable to name (e.g. components which have 
 dropped out of scope between the receiver being constructed and it receiving 
 this message) will be serialized as elements()["(null)"].

 @warning To guarantee that each `UIAElementArray` reference will uniquely identify
 the corresponding component of the receiver, this method must only be called 
 while the receiver is [bound](-bindPath:).
 
 @bug This method should not assume that the path identifies elements within
 the main window.

 @return A Javascript expression that represents the absolute path to the `UIAElement`
 corresponding to the last component of the receiver.
 */
- (NSString *)UIARepresentation;

@end
