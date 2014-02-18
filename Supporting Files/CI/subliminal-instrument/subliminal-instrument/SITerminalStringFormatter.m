//
//  SITerminalStringFormatter.m
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

#import "SITerminalStringFormatter.h"

static NSString *const SITerminalFormattedStringRootElement = @"SITerminalFormattedString";

@interface SITerminalStringFormatter () <NSXMLParserDelegate>
@end

@implementation SITerminalStringFormatter {
    NSString *_string;
    NSMutableString *_formattedString;
    NSMutableArray *_escapeSequenceStack;
}

+ (void)load {
    [self registerEscapeSequence:@"\033[1m" forTag:@"b"];       // bold
    [self registerEscapeSequence:@"\033[2m" forTag:@"faint"];
    [self registerEscapeSequence:@"\033[4m" forTag:@"ul"];      // underline
    [self registerEscapeSequence:@"\033[31m" forTag:@"red"];
    [self registerEscapeSequence:@"\033[32m" forTag:@"green"];
    [self registerEscapeSequence:@"\033[33m" forTag:@"yellow"];
}

static NSMutableDictionary *__tagToEscapeSequenceMap = nil;
+ (void)registerEscapeSequence:(NSString *)sequence forTag:(NSString *)tag {
    NSParameterAssert(sequence && tag);

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tagToEscapeSequenceMap = [[NSMutableDictionary alloc] init];
    });
    __tagToEscapeSequenceMap[tag] = sequence;
}

- (id)init {
    self = [super init];
    if (self) {
        _useColors = YES;
    }
    return self;
}

- (NSString *)formattedStringFromString:(NSString *)string {
    NSParameterAssert(string);

    _string = string;
    _formattedString = [[NSMutableString alloc] init];
    _escapeSequenceStack = [[NSMutableArray alloc] init];

    NSString *xmlMessage = [NSString stringWithFormat:@"<%@>%@</%@>", SITerminalFormattedStringRootElement, _string, SITerminalFormattedStringRootElement];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[xmlMessage dataUsingEncoding:NSUTF8StringEncoding]];
    parser.delegate = self;
    [parser parse];

    return [_formattedString copy];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (![elementName isEqualToString:SITerminalFormattedStringRootElement]) {
        elementName = [elementName lowercaseString];
        NSString *escapeSequence = __tagToEscapeSequenceMap[elementName];
        if (escapeSequence && self.useColors) {
            [_formattedString appendString:escapeSequence];
            [_escapeSequenceStack addObject:escapeSequence];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_formattedString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (![elementName isEqualToString:SITerminalFormattedStringRootElement]) {
        elementName = [elementName lowercaseString];
        NSString *escapeSequence = __tagToEscapeSequenceMap[elementName];
        if (escapeSequence && self.useColors) {
            // `NSXMLParser` should error-out before we get this callback but just to be safe
            NSAssert([escapeSequence isEqualToString:[_escapeSequenceStack lastObject]],
                     @"Log message \"%@\" is malformed: tags are not properly nested.", _string);
            [_escapeSequenceStack removeLastObject];

            // Each escape sequence does not have a specific, corresponding "unescape" sequence.
            // To unescape specific sequences, we must emit the "normal" escape sequence
            // and then re-emit all the other (unclosed) escape sequences.
            NSString *previousSequences = [[[_escapeSequenceStack reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
            [_formattedString appendFormat:@"%@%@", @"\033[0m", previousSequences];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // It's not likely that the parse error will give any useful information but we might as well log it.
    NSLog(@"Could not parse string \"%@\" to be terminal-formatted: %@.", _string, parseError);
    _formattedString = nil;
}

@end
