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

#import "SIFileReportWriter.h"

@interface SITerminalReporter ()
@end

@implementation SITerminalReporter {
    SIFileReportWriter *_outputWriter, *_errorWriter;
}

+ (NSString *)passIndicatorString {
    // no particular reason to choose this character except for that it's used by xctool
    return @"~";
}

+ (NSString *)warningIndicatorString {
    return @"!";
}

+ (NSString *)failIndicatorString {
    return @"X";
}

+ (NSString *)placeholderIndicatorString {
    return @"|";
}

- (void)beginReportingWithStandardOutput:(NSFileHandle *)standardOutput
                           standardError:(NSFileHandle *)standardError {
    [super beginReportingWithStandardOutput:standardOutput standardError:standardError];

    _outputWriter = [[SIFileReportWriter alloc] initWithOutputHandle:self.standardOutput];
    _errorWriter = [[SIFileReportWriter alloc] initWithOutputHandle:self.standardError];
}

- (void)reportEvent:(NSDictionary *)event {
    NSString *message = event[@"message"], *formattedMessage = nil;

    // Certain log types are bracketed within their respective test/test cases.
    BOOL eventOccurredWithinTest = (event[@"info"][@"test"] != nil);

    switch ([event[@"type"] unsignedIntegerValue]) {
        case SISLLogEventTypeTestStatus:
            switch ([event[@"subtype"] unsignedIntegerValue]) {
                case SISLLogEventSubtypeNone:
                    NSAssert(NO, @"Unexpected event type and subtype: %lu, %lu.",
                             (unsigned long)SISLLogEventTypeTestStatus, (unsigned long)SISLLogEventSubtypeNone);
                    break;

                case SISLLogEventSubtypeTestError:
                case SISLLogEventSubtypeTestFailure:
                    if (eventOccurredWithinTest) _outputWriter.dividerActive = YES;
                    [_outputWriter printLine:message];
                    break;

                case SISLLogEventSubtypeTestingStarted:
                    [_outputWriter printLine:message];
                    // offset the tests
                    [_outputWriter printNewline];
                    _outputWriter.indentLevel++;
                    break;
                case SISLLogEventSubtypeTestStarted:
                    [_outputWriter printLine:message];
                    _outputWriter.indentLevel++;
                    break;

                case SISLLogEventSubtypeTestCaseStarted:
                    // close the test-setup section if present
                    _outputWriter.dividerActive = NO;
                    // So that the pass or fail message can overwrite this,
                    // leave room for an indicator at the beginning and don't print a newline.
                    formattedMessage = [NSString stringWithFormat:@"%@ \"%@\" started.",
                                                                [[self class] placeholderIndicatorString], event[@"info"][@"testCase"]];
                    [_outputWriter updateLine:formattedMessage];
                    break;

                case SISLLogEventSubtypeTestCasePassed:
                case SISLLogEventSubtypeTestCaseFailed:
                case SISLLogEventSubtypeTestCaseFailedUnexpectedly: {
                    // close the test case section
                    _outputWriter.dividerActive = NO;

                    NSString *statusIndicator, *finishDescription;
                    switch (([event[@"subtype"] unsignedIntegerValue])) {
                        case SISLLogEventSubtypeTestCasePassed:
                            statusIndicator = [[self class] passIndicatorString];
                            finishDescription = @"passed";
                            break;
                        case SISLLogEventSubtypeTestCaseFailed:
                            statusIndicator = [[self class] failIndicatorString];
                            finishDescription = @"failed";
                            break;
                        case SISLLogEventSubtypeTestCaseFailedUnexpectedly:
                            statusIndicator = [[self class] failIndicatorString];
                            finishDescription = @"failed unexpectedly";
                            break;
                        default:
                            NSAssert(NO, @"Should not have reached this point.");
                            break;
                    }
                    formattedMessage = [NSString stringWithFormat:@"%@ \"%@\" %@.",
                                                                    statusIndicator, event[@"info"][@"testCase"], finishDescription];
                    // This will overwrite the test case-started message.
                    [_outputWriter printLine:formattedMessage];
                    break;
                }


                case SISLLogEventSubtypeTestFinished:
                case SISLLogEventSubtypeTestTerminatedAbnormally:
                    // close the test-teardown section if present
                    _outputWriter.dividerActive = NO;
                    [_outputWriter printLine:message];
                    // test-finish and terminates-abnormally messages are logged at the same level as the test cases
                    _outputWriter.indentLevel--;
                    // separate the tests by a newline
                    [_outputWriter printNewline];
                    break;

                case SISLLogEventSubtypeTestingFinished:
                    _outputWriter.indentLevel--;
                    [_outputWriter printLine:message];
                    break;
            }
            break;

        case SISLLogEventTypeDefault:
        case SISLLogEventTypeDebug:
        case SISLLogEventTypeWarning:
            if (eventOccurredWithinTest) _outputWriter.dividerActive = YES;
            if ([event[@"type"] unsignedIntegerValue] == SISLLogEventTypeWarning) {
                formattedMessage = [NSString stringWithFormat:@"%@ %@", [[self class] warningIndicatorString], message];
            } else {
                formattedMessage = message;
            }
            [_outputWriter printLine:formattedMessage];
            break;
        case SISLLogEventTypeError:
            formattedMessage = [NSString stringWithFormat:@"ERROR: %@", message];
            [_errorWriter printLine:formattedMessage];
            break;
    }
}

@end
