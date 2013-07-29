//
//  SLTextView.h
//  Subliminal
//
//  Created by Jeffrey Wear on 7/29/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"

/**
 `SLTextView` matches instances of `UITextView`.
 */
@interface SLTextView : SLElement

/**
 The text displayed by the text field.
 
 @exception SLUIAElementInvalidException Raised by both `-text` and `-setText:`
 if the element is not valid by the end of the [default timeout](+defaultTimeout).

 @exception SLUIAElementNotTappableException Raised, only by `setText:`, if the
 element is not tappable when whatever amount of time remains of the default
 timeout after the element becomes valid elapses.
 */
@property (nonatomic, copy) NSString *text;

@end
