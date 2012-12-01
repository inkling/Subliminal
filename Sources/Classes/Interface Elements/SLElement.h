//
//  SLElement.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIAccessibilityConstants.h>


#pragma mark - SLElement


extern NSString *const SLInvalidElementException;


@interface SLElement : NSObject

// Defaults - to be set by the test controller, from the testing thread.
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout;

// Returns an element for an NSObject in the accessibility hierarchy that matches predicate.
+ (id)elementMatching:(BOOL (^)(NSObject *obj))predicate;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName.
+ (id)elementWithAccessibilityLabel:(NSString *)label;

// Returns an element for an NSObject in the accessibility hierarchy with the given slAccessibilityName, accessibilityValue, and matching the traits accessibilityTraits mask.
// If label is nil the condition on slAccessibilityName is ignored.
// If value is nil the condition on accessibilityValue is ignored.
+ (id)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits;

// If the UIAccessibilityElement corresponding to the receiver does not exist,
// isValid and isVisible will return NO.
// All other methods below will throw an SLElementAccessException.
- (BOOL)isValid;
- (BOOL)isVisible;
- (void)waitUntilVisible:(NSTimeInterval)timeout;
- (void)waitUntilInvisible:(NSTimeInterval)timeout;

- (void)tap;

- (NSString *)value;

- (void)logElement;
- (void)logElementTree;

/** Returns YES if the instance of SLElement should 'match' object, no otherwise.

  Subclasses of SLElement can override this method to provide custom matching behavior.
  Default implementation returns [object.slAccessibilityName isEqualToString:self.label].

  @param object The object to which the instance of SLElement should be compared.
  @return a BOOL indicating whether or not the instance of SLElement matches object.
  */
- (BOOL)matchesObject:(NSObject *)object;

@end

@interface SLElement (Debugging)
// Returns the UIA prefix for the element in the view hierarchy of the current main window.
- (NSString *)currentUIAPrefix;
@end

#pragma mark - SLElement Subclasses

@interface SLAlert : SLElement
- (void)dismiss;
- (void)dismissWithButtonTitled:(NSString *)buttonTitle;
@end

@interface SLControl : SLElement
- (BOOL)isEnabled;
@end

@interface SLButton : SLControl
@end

@interface SLTextField : SLElement
@property (nonatomic, strong) NSString *text;
@end

// Instances always refer to mainWindow()
@interface SLWindow : SLElement
+ (SLWindow *)mainWindow;
@end

// Instances refer to the first instance of (a kind of) UIWebView that appears in the view hierarchy.
@interface SLCurrentWebView : SLElement
@end
