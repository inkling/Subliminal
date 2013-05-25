//
//  SLTextField.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"

/**
 `SLTextField` matches instances of `UITextField`.
 */
@interface SLTextField : SLElement

/** 
 The text displayed by the text field.
 
 @exception SLUIAElementInvalidException Raised by both `-text` and `-setText:`
 if the element is not valid by the end of the [default timeout](+defaultTimeout).

 @exception SLUIAElementNotTappableException Raised, only by `setText:`, if the 
 element is not tappable when whatever amount of time remains of the default 
 timeout after the element becomes valid elapses.
 */
@property (nonatomic, strong) NSString *text;

@end

/**
 `SLSearchField` matches objects that have the `UIAccessibilityTraitSearchField`
 accessibility trait.

 Such as the text field of a `UISearchBar`.

 @warning A search field can be matched only by using `+anyElement`,
 as it is a private member of `UISearchBar` and so it is not possible for the 
 application to configure its accessibility information.
 */
@interface SLSearchField : SLTextField
@end

/**
 SLWebTextField matches text fields displayed in UIWebViews.

 Such as form inputs.
 
 #### Configuring web text fields' accessibility information

 A web text field's `[-label](-[SLUIAElement label])` is the text of a `DOM` 
 element specified by the "aria-labelled-by" attribute, if present. 
 See `SLWebTextField.html` and the `SLWebTextField` test cases of `SLTextFieldTest`.
 */
@interface SLWebTextField : SLElement

/**
 The text displayed by the text field.
 
 `-text` returns the web text field's value (i.e. the value of the form input's
 "value" attribute).

 @exception SLUIAElementInvalidException Raised by both `-text` and `-setText:`
 if the element is not valid by the end of the [default timeout](+defaultTimeout).

 @exception SLUIAElementNotTappableException Raised, only by `-setText:`, if the
 element is not tappable when whatever amount of time remains of the default
 timeout after the element becomes valid elapses.
 */
@property (nonatomic, strong) NSString *text;

@end
