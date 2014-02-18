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
                    _outputWriter.indentLevel++;
                    break;
                case SISLLogEventSubtypeTestStarted:
                    [_outputWriter printLine:message];
                    _outputWriter.indentLevel++;
                    break;

                case SISLLogEventSubtypeTestCaseStarted:
                    // close the test-setup section if present
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" started.", event[@"info"][@"testCase"]];
                    _outputWriter.dividerActive = NO;
                    [_outputWriter printLine:formattedMessage];
                    _outputWriter.indentLevel++;
                    break;

                case SISLLogEventSubtypeTestCasePassed:
                case SISLLogEventSubtypeTestCaseFailed:
                case SISLLogEventSubtypeTestCaseFailedUnexpectedly: {
                    _outputWriter.indentLevel--;
                    // close the test case section
                    _outputWriter.dividerActive = NO;

                    NSString *finishDescription;
                    switch (([event[@"subtype"] unsignedIntegerValue])) {
                        case SISLLogEventSubtypeTestCasePassed:
                            finishDescription = @"passed";
                            break;
                        case SISLLogEventSubtypeTestCaseFailed:
                            finishDescription = @"failed";
                            break;
                        case SISLLogEventSubtypeTestCaseFailedUnexpectedly:
                            finishDescription = @"failed unexpectedly";
                            break;
                        default:
                            NSAssert(NO, @"Should not have reached this point.");
                            break;
                    }
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" %@.", event[@"info"][@"testCase"], finishDescription];
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
            [_outputWriter printLine:message];
            break;
        case SISLLogEventTypeError:
            [_errorWriter printLine:message];
            break;
    }
}

@end
