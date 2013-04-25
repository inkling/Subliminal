//
//  SLStringUtilities.h
//  Subliminal
//
//  Created by William Green on 10/31/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SLJavaScript)
/** Returns a string that is valid inside a javascript literal.
 
 The result can be used inside a single or double quoted literal.
 
 @return A string that is valid inside a javascript literal.
 */
- (NSString *)slStringByEscapingForJavaScriptLiteral;
@end


extern NSString *SLComposeString(NSString *leadingString, NSString *format, ...);
extern NSString *SLComposeStringv(NSString *leadingString, NSString *format, va_list args);
