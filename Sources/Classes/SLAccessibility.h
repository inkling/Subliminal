//
//  SLAccessibility.h
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLElement;
@class SLAccessibilityPath;
@interface NSObject (SLAccessibility)

/** 
 A string Subliminal will use to match this object with an SLElement.
 
 The default implementation returns the object's accessibility identifier, 
 if the object responds to -accessibilityIdentifier and the identifier is non-empty,
 otherwise the object's accessibility label.
 */
@property (nonatomic, readonly) NSString *slAccessibilityName;

/**
 Returns the accessibility path from this object to the specified element.

 The path starts with this object and ends with an object [matching](-[SLElement matchesObject:]) 
 the target element (i.e. that object is the path's 
 [last component](-[SLAccessibilityPath examineLastPathComponent:])).

 @param element The element to be matched.
 @return A path that can used by UIAutomation to access the element or `nil`
 if the element is not found within this object's accessibility hierarchy.
 */
- (SLAccessibilityPath *)slAccessibilityPathToElement:(SLElement *)element;

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
 parent and child object, it can then be [serialized into Javascript]](-UIARepresentation) in order
 to identify, access, and manipulate the `UIAElement` corresponding to the child 
 when [evaluated](-[SLTerminal eval:]) as part of a larger expression.
 
 @warning Because the path's components are likely UIKit objects, 
 they must not manipulated off the main thread. SLAccessibilityPath's API 
 enforces this as best possible, but the caller must take additional care 
 that the path is not added to an @autoreleasepool on a background thread 
 (or else it, and thus its components, may be released on that thread).
 
 This should be done by explicitly retaining/releasing paths (if ARC is not used)
 or declaring methods that return paths as NS_RETURNS_RETAINED (if ARC is used).
 */
@interface SLAccessibilityPath : NSObject

/**
 Allows the caller to interact with the last path component of the receiver.
 
 Path components are objects at successive levels of an accessibility hierarchy 
 (where the component at index i + 1 is the child of the component at index i).
 The last path component is the object at the deepest level of such a hierarchy.
 
 The block will be executed synchronously on the main thread.

 @param block A block which takes the last path component of the receiver 
 as an argument and returns void.
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

 @warning To guarantee that each `UIAElementArray` reference will uniquely identify
 the corresponding component of the receiver, the receiver should be
 [bound](-bindPath:) before serialization.

 @bug This method should not assume that the path identifies elements within
 the main window.

 @return A Javascript expression that represents the absolute path to the `UIAElement`
 corresponding to the last component of the receiver.
 */
- (NSString *)UIARepresentation;

@end
