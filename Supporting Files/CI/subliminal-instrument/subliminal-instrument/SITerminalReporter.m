//
//  SITerminalReporter.m
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

#import "SITerminalReporter.h"

#import "NSFileHandle+StringWriting.h"

static const NSUInteger kIndentSize = 4;

@interface SITerminalReporter ()
@property (nonatomic) NSUInteger indentLevel;
@end

@implementation SITerminalReporter {
    NSString *_indentString;
}

- (id)init {
    self = [super init];
    if (self) {
        _indentString = @"";
    }
    return self;
}

- (void)reportEvent:(NSDictionary *)event {
    NSString *message = event[@"message"], *formattedMessage = nil;

    switch ([event[@"type"] unsignedIntegerValue]) {
        case SISLLogEventTypeTestStatus:
            switch ([event[@"subtype"] unsignedIntegerValue]) {
                case SISLLogEventSubtypeNone:
                    NSAssert(NO, @"Unexpected event type and subtype: %lu, %lu.",
                             (unsigned long)SISLLogEventTypeTestStatus, (unsigned long)SISLLogEventSubtypeNone);
                    break;

                case SISLLogEventSubtypeTestError:
                case SISLLogEventSubtypeTestFailure:
                    [self printMessage:message];
                    break;

                case SISLLogEventSubtypeTestingStarted:
                    [self printMessage:message];
                    self.indentLevel++;
                    break;
                case SISLLogEventSubtypeTestStarted:
                    [self printMessage:message];
                    self.indentLevel++;
                    break;

                case SISLLogEventSubtypeTestCaseStarted:
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" started.", event[@"info"][@"testCase"]];
                    [self printMessage:formattedMessage];
                    self.indentLevel++;
                    break;
                case SISLLogEventSubtypeTestCasePassed:
                    self.indentLevel--;
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" passed.", event[@"info"][@"testCase"]];
                    [self printMessage:formattedMessage];
                    break;
                case SISLLogEventSubtypeTestCaseFailed:
                    self.indentLevel--;
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" failed.", event[@"info"][@"testCase"]];
                    [self printMessage:formattedMessage];
                    break;
                case SISLLogEventSubtypeTestCaseFailedUnexpectedly:
                    self.indentLevel--;
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" failed unexpectedly.", event[@"info"][@"testCase"]];
                    [self printMessage:formattedMessage];
                    break;

                // test-finish and terminates-abnormally messages are logged at the same level as the test cases
                case SISLLogEventSubtypeTestFinished:
                    [self printMessage:message];
                    self.indentLevel--;
                    break;
                case SISLLogEventSubtypeTestTerminatedAbnormally:
                    [self printMessage:message];
                    self.indentLevel--;
                    break;

                case SISLLogEventSubtypeTestingFinished:
                    self.indentLevel--;
                    [self printMessage:message];
                    break;
            }
            break;

        case SISLLogEventTypeDefault:
        case SISLLogEventTypeDebug:
        case SISLLogEventTypeWarning:
            [self printMessage:message];
            break;
        case SISLLogEventTypeError:
            [self printMessage:message asError:YES];
            break;
    }
}

#pragma mark -

- (void)setIndentLevel:(NSUInteger)indentLevel {
    NSAssert(indentLevel != NSUIntegerMax, @"An attempt was made to set the indent level to -1!");

    if (indentLevel != _indentLevel) {
        _indentLevel = indentLevel;
        _indentString = [@"" stringByPaddingToLength:(indentLevel * kIndentSize)
                                          withString:@" " startingAtIndex:0];
    }
}

- (void)printMessage:(NSString *)message {
    [self printMessage:message asError:NO];
}

- (void)printMessage:(NSString *)message asError:(BOOL)error {
    NSFileHandle *outHandle = error ? self.standardError : self.standardOutput;
    [outHandle printString:@"%@%@\n", _indentString, message];
}

@end
