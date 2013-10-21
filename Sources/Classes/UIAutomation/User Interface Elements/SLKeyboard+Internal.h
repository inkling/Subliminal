//
//  SLKeyboard+Internal.h
//  Subliminal
//
//  Created by Aaron Golden on 10/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLKeyboard.h"

@class SLUIAElement;

@interface SLKeyboard (Internal)

/**
 Uses -[SLKeyboard typeString:] to tap the keys of the input string on the
 receiver.  Unlike -[SLKeyboard typeString:], this method will not throw an
 exception if the input string contains characters that can be accessed on
 the receiver only through a tap-hold gesture.  Instead, this method will
 send the setValue JavaScript message to the input element as a "fallback"
 procedure.

 @param string The string to be typed on the keyboard or set as the value for
 element.
 @param element The user interface element on which the setValue JavaScript
 method will be called if the internal call to -[SLKeyboard typeString:]
 throws an exception.
 */
 - (void)typeString:(NSString *)string withSetValueFallbackUsingElement:(SLUIAElement *)element;

@end
