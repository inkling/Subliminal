//
//  SLAccessibility.h
//  Subliminal
//
//  Created by William Green on 11/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLElement;

extern NSString * const SLMockViewAccessibilityChainKey;
extern NSString * const SLUIViewAccessibilityChainKey;


@interface NSObject (SLAccessibility)

/** 
 A string Subliminal will use to match this object with an SLElement.
 
 The default implementation returns the object's accessibility identifier, 
 if the object responds to -accessibilityIdentifier and the identifier is non-empty,
 otherwise the object's accessibility label.
 */
@property (nonatomic, readonly) NSString *slAccessibilityName;

/** Returns an array of objects that are child accessibility elements of this object.
 
 This method is mostly a wrapper around the UIAccessibilityContainer protocol but
 also includes subviews if the object is a UIView. It attempts to represent the 
 accessibilty hierarchy used by the system.
 
 @param favoringUISubViews Whether subviews should be placed before or after 
                        UIAccessibilityElements in the returned array
 
 @return An array of objects that are child accessibility elements of this object.
 */
- (NSArray *)slChildAccessibilityElementsFavoringUISubviews:(BOOL)favoringUISubviews;

/** Returns a dictionary containing two chains of objects that can be used to identify
 the accessibility chain that will be used by UIAutomation.
 
 Each chain starts at index 0 with this object and ends with the target element.
 The returned chains can be accessed with the keys SLMockViewAccessibilityChainKey and
 SLUIViewAccessibilityChainKey. The mock view accessibility chain will prioritize
 paths along UIAccessibilityElements to a matching element, while the uiview accessibility
 chain will prioritize chains made up of UIViews. Every view in the mock object accessibility
 chain will exist in the uiview accessibility chain, and each mock object in the mock 
 accessibility chain that mocks a view, will mock a view from the view accesisbility chain.
 It is the mock view chain that will match the chain created by UIAutomation, the 
 uiview accessibility chain is returned as well because it can be used to set the
 accessibility identifiers of mock views in the mock accessibility chain.

 @param element The element to be matched.
 @return A dictionary containing chains of objects that can used by UIAutomation to access the element
 or `nil` if the element is not found within this object's accessibility hierarchy.
 */

- (NSDictionary *)slAccessibilityChainsToElement:(SLElement *)element;

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


@interface UIAccessibilityElement (SLAccessibility)
@end


@interface UIView (SLAccessibility)
@end


@interface UIControl (SLAccessibility)
@end


@interface UIScrollView (SLAccessibility)
@end
