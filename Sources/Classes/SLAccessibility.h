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

 The path starts with this object and ends with an object matching the target element.

 @param element The element to be matched.
 @return A path that can used by UIAutomation to access the element or `nil`
 if the element is not found within this object's accessibility hierarchy.
 */
- (SLAccessibilityPath *)slAccessibilityPathToElement:(SLElement *)element;

/** Sets a unique identifier as the accessibilityIdentifier **/
- (void)setAccessibilityIdentifierWithStandardReplacement;

/** The string that should be used to uniquely identify this object to UIAutomation **/
- (NSString *)standardAccessibilityIdentifierReplacement;

/** Resets the accessibilityIndentifier and accessibilityLabel to their appropriate
 values, unless their values have been changed again since they were replaced with
 the standardAccessibilityIdentifierReplacement.
 
 @param previousIdentifer The accessibilityIdentifer's value before it was set to
                    standardAccessibilityIdentifierReplacement
 
 @param previousLabel The accessibilityIdentifier's value before it was set to 
                    standardAccessibilityIdentifierReplacement
 
 **/
- (void)resetAccessibilityInfoIfNecessaryWithPreviousIdentifier:(NSString *)previousIdentifier previousLabel:(NSString *)previousLabel;

/// ----------------------------------------
/// @name Debug methods
/// ----------------------------------------
- (NSString *)slAccessibilityDescription;
- (NSString *)slRecursiveAccessibilityDescription;

@end


/**
 SLAccessibilityPath contains two sequences of objects ("paths") that can be used to identify
 the accessibility path that will be used by UIAutomation.

 The mock view accessibility path will prioritize paths along UIAccessibilityElements
 to a matching element, while the uiview accessibility path will prioritize paths
 made up of UIViews. Every view in the mock object accessibility path will exist
 in the uiview accessibility path, and each mock object in the mock accessibility
 path that mocks a view, will mock a view from the view accessibility path.

 It is the mock view path that will match the path created by UIAutomation.
 The view accessibility path can be used to set the
 accessibility identifiers of mock views in the mock view accessibility path.
 */
@interface SLAccessibilityPath : NSObject

@property (nonatomic, readonly) NSArray *mockViewPath, *viewPath;

@end
