//
//  SLActionSheet.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLStaticElement.h"

/**
 `SLActionSheet` allows you to manipulate the buttons of action sheets
 within your app.

 You can almost always access these elements directly, using instances of
 `SLElement`. Assuming that an action sheet had a cancel button labeled "Cancel",

    [SLButton elementWithAccessibilityLabel:@"Cancel"]

 would return an element functionally identical to

    [[SLActionSheet currentActionSheet] cancelButton]

 However, you might use `SLActionSheet` to verify that the current action sheet's
 buttons had the expected labels, or to match the action sheet of a
 [remote view controller](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/)
 (where `SLElement` could not examine the contents of the view).
 */
@interface SLActionSheet : SLStaticElement

/**
 Returns an object that represents the app's current action sheet, if any.
 
 This element will be [valid](-[SLUIAElement isValid]) if and only if the application
 is currently showing an action sheet.
 
 @return An object that represents the app's current action sheet.
 */
+ (instancetype)currentActionSheet;

/**
 The string that appears in the title area of the action sheet, if any.
 
 @exception SLUIAElementInvalidException Raised if the action sheet is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) NSString *title;

/**
 The buttons in the action sheet, as instances of `SLUIAElement`.
 
 If the action sheet has a cancel button, this array will include that cancel button
 as the last item in the array.
 
 @exception SLUIAElementInvalidException Raised if the action sheet is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) NSArray *buttons;

/**
 The cancel button in the action sheet, if any.
 
 If there is no cancel button, this element will not be [valid](-[SLUIAElement isValid]).
 
 @exception SLUIAElementInvalidException Raised if the action sheet is not
 [valid](-[SLUIAElement isValid]) by the end of the [default timeout](+[SLUIAElement defaultTimeout]).
 */
@property (nonatomic, readonly) SLUIAElement *cancelButton;

@end
