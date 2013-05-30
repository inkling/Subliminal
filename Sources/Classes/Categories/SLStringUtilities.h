//
//  SLStringUtilities.h
//  Subliminal
//
//  Created by William Green on 10/31/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The methods in the `NSString (SLJavaScript)` category facilitate the construction 
 of JavaScript scripts for `SLTerminal` to evaluate.
 */
@interface NSString (SLJavaScript)

/** 
 Returns a representation of the receiver that has been escaped as necessary
 to substitute the receiver into a JavaScript string literal.
 
 The result can be substituted into a single- or double-quoted literal.
 
 @return A string that can be safely substituted into a JavaScript string literal.
 */
- (NSString *)slStringByEscapingForJavaScriptLiteral;

@end


/**
 `SLComposeString` composes a format string and arguments for substitution 
 into a larger format string.
 
 This function is a wrapper around `SLComposeStringv`. See that function for 
 further discussion.
 
 @param leadingString A string to be used to prefix the formatted string 
 if `format` is non-`nil`. Can be `nil`.
 @param format A format string. Can be `nil`.
 @param ... (Optional) A comma-separated list of arguments to substitute into `format` if 
 `format is non-`nil`.
 
 @return A string created by using `format` as a template into which the remaining
 arguments are substituted (optionally prefixed by a leading string) if `format`
 is non-`nil`; otherwise, the empty string.
 */
extern NSString *SLComposeString(NSString *leadingString, NSString *format, ...);

/**
 `SLComposeStringv` composes a format string and arguments for substitution
 into a larger format string.

 Unlike the `NSString` format APIs, this function does not raise an exception 
 if the format string is `nil`. Instead, this method simply returns the empty
 string.
 
 Thus, using this function in the preparation of a larger format string 
 allows certain arguments to that format string to be `nil`.

 @param leadingString A string to be used to prefix the formatted string
 if `format` is non-`nil`. Can be `nil`.
 @param format A format string. Can be `nil`.
 @param args A list of arguments to substitute into `format` if `format` is non-`nil`.
 
 @return A string created by using `format` as a template into which the remaining
 arguments are substituted (optionally prefixed by a leading string) if `format` 
 is non-`nil`; otherwise, the empty string.
 */
extern NSString *SLComposeStringv(NSString *leadingString, NSString *format, va_list args);
