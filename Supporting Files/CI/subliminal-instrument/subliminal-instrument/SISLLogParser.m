//
//  SISLLogParser.m
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

#import "SISLLogParser.h"

@implementation SISLLogParser

+ (NSDateFormatter *)iso8601DateFormatter {
    static NSDateFormatter *__formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __formatter = [[NSDateFormatter alloc] init];
        // produce invariant results: see https://developer.apple.com/library/ios/qa/qa1480/_index.html
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [__formatter setLocale:enUSPOSIXLocale];
        [__formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    return __formatter;
}

+ (NSString *)parseMessageFromLine:(NSString *)line {
    NSParameterAssert(line);

    static NSRegularExpression *__instrumentsLogExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *instrumentsLogPattern = @"^(?:\\d+-\\d+-\\d+ \\d+:\\d+:\\d+ \\+\\d+) (.+)$";
        __instrumentsLogExpression = [[NSRegularExpression alloc] initWithPattern:instrumentsLogPattern
                                                                          options:0 error:NULL];
    });

    NSTextCheckingResult *result = [__instrumentsLogExpression firstMatchInString:line
                                                                          options:0 range:NSMakeRange(0, [line length])];
    NSString *message = nil;
    if (result) {
        // the first range is for the whole result
        message = [line substringWithRange:[result rangeAtIndex:1]];
    } else {
        // e.g. the message didn't have a timestamp
        message =  line;
    }
    return message;
}

+ (BOOL)shouldFilterStdoutLine:(NSString *)line {
    // filter the trace-completed message: the tests have already completed
    return [line rangeOfString:@"Instruments Trace Complete"].location != NSNotFound;
}

+ (BOOL)shouldFilterStderrLine:(NSString *)line {
    // filter diagnostic messages from "ScriptAgent"
    return [line rangeOfString:@"ScriptAgent"].location != NSNotFound;
}

- (void)parseStdoutLine:(NSString *)line {
    if ([[self class] shouldFilterStdoutLine:line]) return;

    // we use our own timestamps rather than the timestamp in the line
    // because we can't guarantee that error messages (below) will have timestamps
    NSString *timestamp = [[[self class] iso8601DateFormatter] stringFromDate:[NSDate date]];
    NSString *message = [[self class] parseMessageFromLine:line];

    NSDictionary *event = @{
        @"timestamp": timestamp,
        @"type": @(SISLLogEventTypeDefault),
        @"message": message
    };

    [self.delegate parser:self didParseEvent:event];
}

- (void)parseStderrLine:(NSString *)line {
    if ([[self class] shouldFilterStderrLine:line]) return;

    // we use our own timestamps rather than the timestamp in the line
    // because we can't guarantee that error messages will have timestamps
    NSString *timestamp = [[[self class] iso8601DateFormatter] stringFromDate:[NSDate date]];
    NSString *message = [[self class] parseMessageFromLine:line];

    NSDictionary *event = @{
        @"timestamp": timestamp,
        @"type": @(SISLLogEventTypeError),
        @"message": message
    };

    [self.delegate parser:self didParseEvent:event];
}

@end
