//
//  SLNavigationBar.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLStaticElement.h"

/**
 `SLNavigationBar` allows you to read the title of your app's navigation bar
 and manipulate the navigation bar's left and right buttons.
 
 You can almost always access these elements directly, using instances of
 `SLElement`. Assuming that the navigation bar's left button had the label "Cancel",
 
    [SLButton elementWithAccessibilityLabel:@"Cancel"]
 
 would return an element functionally identical to
 
    [[SLNavigationBar currentNavigationBar] leftButton]
 
 However, you might use `SLNavigationBar` to verify that the current navigation bar's
 buttons had the expected labels, or to match the navigation bar of a
 [remote view controller](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/)
 (where `SLElement` could not examine the contents of the view).
 */
@interface SLNavigationBar : SLStaticElement

/**
 Returns an object that represents the app's current navigation bar, if any.
 
 This element will be [valid](-[SLUIAElement isValid]) if and only if the application
 is currently showing a navigation bar.
 
 If there are multiple navigation bars visible onscreen,
 this element will represent the frontmost bar.

 @return An object that represents the app's current navigation bar.
 */
+ (instancetype)currentNavigationBar;

/**
 The title (-[UIViewController title]) of the navigation controller's
 top view controller (-[UINavigationController topViewController]).
 
 @exception SLUIAElementInvalidException Raised if the navigation bar is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) NSString *title;

/**
 The left button in the navigation bar, if any.
 
 If there is no left button, this element will not be [valid](-[SLUIAElement isValid]).
 If the left button is the back button, and the back button is hidden (-[UINavigationItem hidesBackButton]),
 it _may_ be invalid, depending on the platform--you should check that
 [-isValidAndVisible](-[SLUIAElement isValidAndVisible]) returns `YES` before
 attempting to access or manipulate the element.
 
 @exception SLUIAElementInvalidException Raised if the navigation bar is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) SLUIAElement *leftButton;

/**
 The right button in the navigation bar, if any.
 
 If there is no right button, this element will not be [valid](-[SLUIAElement isValid]).
 
 @exception SLUIAElementInvalidException Raised if the navigation bar is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) SLUIAElement *rightButton;

@end
