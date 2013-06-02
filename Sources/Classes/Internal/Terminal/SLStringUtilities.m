//
//  SLStringUtilities.m
//  Subliminal
//
//  Created by William Green on 10/31/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLStringUtilities.h"

@implementation NSString (SLJavaScript)

- (NSString *)slStringByEscapingForJavaScriptLiteral {
    // Escape sequences taken from here: http://ecma262-5.com/ELS5_HTML.htm#Section_7.8.4
    NSString *literal = [self stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    literal = [literal stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    literal = [literal stringByReplacingOccurrencesOfString:@"\v" withString:@"\\v"];
    return literal;
}

@end


NSString *SLComposeString(NSString *leadingString, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *formattedString = SLComposeStringv(leadingString, format, args);
    va_end(args);

    return formattedString;
}

NSString *SLComposeStringv(NSString *leadingString, NSString *format, va_list args) {
    if (!format) {
        return @"";
    }

    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    if (leadingString) {
        return [leadingString stringByAppendingString:formattedString];
    }

    return formattedString;
}
