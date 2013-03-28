//
//  SLTextField.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"

/**
 SLTextField allows access to, and control of, text field elements in your app.
 */
@interface SLTextField : SLElement

/** The text displayed by the text field. */
@property (nonatomic, strong) NSString *text;

@end

/**
 SLSearchBarTextField allows access to, and control of, search bar elements in your app.

 @warning For reasons out of Subliminal's control, it is not possible to match
 accessibility properties on search bars. Search bars can only be matched
 using +anyElement.

 (The text field inside a UISearchBar is the accessible element, not the
 search bar itself. This means that the accessibility properties of the search bar
 don't matter--and unfortunately, you can't set accessibility properties on the
 text field because it's private.)
 */
@interface SLSearchBar : SLTextField
@end

/**
 SLWebTextField matches text fields displayed in UIWebViews.

 Such as form inputs.

 A web text field's value is its text (i.e. the value of a form input's "value"
 attribute). A web text field's label is the text of an element specified by the
 "aria-labelled-by" attribute, if present. See SLWebTextField.html and the
 SLWebTextField test cases of SLTextFieldTest.
 */
@interface SLWebTextField : SLElement

/** The text displayed by the text field. */
@property (nonatomic, strong) NSString *text;

@end
