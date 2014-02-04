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

#import <sys/ioctl.h>

#import "NSFileHandle+StringWriting.h"
#import "NSTask+Utilities.h"

static const NSUInteger kIndentSize = 4;
static const NSUInteger kDefaultWidth = 80;

@interface SITerminalReporter ()
@property (nonatomic) NSUInteger indentLevel;
@property (nonatomic) BOOL dividerActive;
@end

@implementation SITerminalReporter {
    NSString *_indentString;
}

+ (BOOL)isRunningInTerminal {
    static BOOL __isRunningInTerminal = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __isRunningInTerminal = (getenv("TERM") != NULL);
    });
    return __isRunningInTerminal;
}

+ (NSString *)dividerWithDownLineAtLocation:(NSInteger)location {
    NSString *dashStr = @"-";
    NSString *downLineStr = @"|";

    NSUInteger dividerWidth = kDefaultWidth;
    if ([self isRunningInTerminal]) {
        struct winsize w = {0};
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
        if (w.ws_col > 0) dividerWidth = (NSUInteger)w.ws_col;
    }

    NSString *divider = [@"" stringByPaddingToLength:dividerWidth withString:dashStr startingAtIndex:0];
    if (location != NSNotFound) {
        divider = [divider stringByReplacingCharactersInRange:NSMakeRange(location, [downLineStr length])
                                                   withString:downLineStr];
    }
    return divider;
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
                    if (eventOccurredWithinTest) self.dividerActive = YES;
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
                    // close the test-setup section if present
                    self.dividerActive = NO;
                    formattedMessage = [NSString stringWithFormat:@"\"%@\" started.", event[@"info"][@"testCase"]];
                    [self printMessage:formattedMessage];
                    self.indentLevel++;
                    break;

                case SISLLogEventSubtypeTestCasePassed:
                case SISLLogEventSubtypeTestCaseFailed:
                case SISLLogEventSubtypeTestCaseFailedUnexpectedly: {
                    self.indentLevel--;
                    // close the test case section
                    self.dividerActive = NO;

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
                    [self printMessage:formattedMessage];
                    break;
                }


                case SISLLogEventSubtypeTestFinished:
                case SISLLogEventSubtypeTestTerminatedAbnormally:
                    // close the test-teardown section if present
                    self.dividerActive = NO;
                    [self printMessage:message];
                    // test-finish and terminates-abnormally messages are logged at the same level as the test cases
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
            if (eventOccurredWithinTest) self.dividerActive = YES;
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

- (void)setDividerActive:(BOOL)dividerActive {
    if (dividerActive != _dividerActive) {
        _dividerActive = dividerActive;

        // closing dividers have the down line to link back to the indent
        BOOL includeDownLine = !_dividerActive;
        NSString *divider = [[self class] dividerWithDownLineAtLocation:(includeDownLine ? [_indentString length] : NSNotFound)];
        [self printMessage:divider asError:NO usingIndent:NO];
    }
}

- (void)printMessage:(NSString *)message {
    [self printMessage:message asError:NO];
}

- (void)printMessage:(NSString *)message asError:(BOOL)error {
    [self printMessage:message asError:error usingIndent:!self.dividerActive];
}

- (void)printMessage:(NSString *)message asError:(BOOL)error usingIndent:(BOOL)usingIndent {
    NSFileHandle *outHandle = error ? self.standardError : self.standardOutput;
    [outHandle printString:@"%@%@\n", (usingIndent ? _indentString : @""), message];
}

@end
