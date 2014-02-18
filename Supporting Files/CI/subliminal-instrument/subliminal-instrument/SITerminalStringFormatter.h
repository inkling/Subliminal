//
//  SITerminalStringFormatter.h
//  subliminal-instrument
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2014 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

/**
 Instances of `SITerminalStringFormatter` process text for output to terminals.
 In particular, they convert XML markup into ANSI escape sequences.
 
 For instance, a string reading "<red>red text</red> plain text" will be formatted
 as "\033[31mred text\033[0m plain text"; that string, printed to a capable terminal,
 will appear in color.
 
 The XML tags supported by `SITerminalStringFormatter` are as follows:
 
 * `b`: bold text
 * `faint`: faint text
 * `ul`: underlined text
 * `red`: red text
 * `green`: green text
 * `yellow`: yellow text
 
 By setting `useColors` to `NO`, a formatter may be directed to strip the markup
 from a string i.e. for output to a terminal that does not support colors.
 */
@interface SITerminalStringFormatter : NSObject

/**
 If `YES`, XML markup in strings processed by the receiver will be converted
 to ANSI escape sequences. If `NO`, such markup will be stripped in when formatting
 such that only plain text is output.

 Defaults to `YES`.
 */
@property (nonatomic) BOOL useColors;

/**
 Formats a string according to its markup and the receiver's configuration.
 
 @warning XML entities that are not part of terminal-formatting markup should be
          escaped e.g. by using `CFXMLCreateStringByEscapingEntities`.

 @param string The string to format, optionally containing markup as described
               in the class discussion.
 
 @return The formatted string, or `nil` if an error occurred while parsing _string_.
 */
- (NSString *)formattedStringFromString:(NSString *)string;

@end
