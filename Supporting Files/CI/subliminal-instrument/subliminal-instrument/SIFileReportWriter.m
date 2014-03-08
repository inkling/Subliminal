//
//  SIFileReportWriter.m
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

#import "SIFileReportWriter.h"

#import <sys/ioctl.h>

#import "NSFileHandle+StringWriting.h"
#import "NSTask+Utilities.h"

static const NSUInteger kIndentSize = 4;
static const NSUInteger kDefaultWidth = 80;

@implementation SIFileReportWriter {
    NSFileHandle *_outputHandle;
    BOOL _outputHandleIsATerminal;
    NSString *_indentString;
    NSUInteger _dividerWidth;
    NSString *_currentLine, *_pendingLine;
}

+ (NSString *)clearToEOLCharacter {
    static NSString *__clearToEOLCharacter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTask *clearToEOLCharacterTask = [[NSTask alloc] init];
        clearToEOLCharacterTask.launchPath = @"/usr/bin/tput";
        clearToEOLCharacterTask.arguments = @[ @"el" ];
        __clearToEOLCharacter = [[clearToEOLCharacterTask output] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    });
    return __clearToEOLCharacter;
}

- (instancetype)initWithOutputHandle:(NSFileHandle *)outputHandle {
    NSParameterAssert(outputHandle);

    self = [super init];
    if (self) {
        _outputHandle = outputHandle;

        // We need to check both `isatty` and whether the _TERM_ environment variable is set
        // because when running in Xcode, `isatty` will return true for `stdout`,
        // even though neither `ioctl` nor `tput` will work.
        int handleDescriptor = [_outputHandle fileDescriptor];
        _outputHandleIsATerminal = isatty(handleDescriptor) && getenv("TERM");

        if (_outputHandleIsATerminal) {
            // Determine the clear-to-EOL character so that there will be no delay while writing the log.
            (void)[[self class] clearToEOLCharacter];

            struct winsize w = {0};
            ioctl(handleDescriptor, TIOCGWINSZ, &w);
            _dividerWidth = (NSUInteger)w.ws_col;
        }
        _dividerWidth = _dividerWidth ?: kDefaultWidth;

        _indentString = @"";
    }
    return self;
}

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

        // the down line links back to the indent
        NSString *divider = [self dividerWithDownLineAtLocation:[_indentString length]];

        // flush output pending before the divider
        if (![self lineHasEnded]) [self printNewline];

        [self updateLine:divider usingIndent:NO];
        [self printNewline];
    }
}

- (NSString *)dividerWithDownLineAtLocation:(NSInteger)location {
    NSString *dashStr = @"-";
    NSString *downLineStr = @"|";

    NSString *divider = [@"" stringByPaddingToLength:_dividerWidth withString:dashStr startingAtIndex:0];
    divider = [divider stringByReplacingCharactersInRange:NSMakeRange(location, [downLineStr length])
                                               withString:downLineStr];
    return divider;
}

- (BOOL)lineHasEnded {
    // The line has ended unless we've written something ("current") to the line,
    // or we're waiting to write something ("pending") to the line.
    return !(_currentLine || _pendingLine);
}

- (void)printLine:(NSString *)line {
    [self updateLine:line];
    [self printNewline];
}

- (void)updateLine:(NSString *)line {
    [self updateLine:line usingIndent:!self.dividerActive];
}

- (void)updateLine:(NSString *)line usingIndent:(BOOL)usingIndent {
    NSString *formattedLine = [NSString stringWithFormat:@"%@%@", (usingIndent ? _indentString : @""), line];
    if (_outputHandleIsATerminal) {
        // The carriage return + clear-to-EOL character will overwrite the current line.
        [_outputHandle printString:@"\r%@", [[self class] clearToEOLCharacter]];
        [_outputHandle printString:@"%@", formattedLine];
        _currentLine = formattedLine;
    } else {
        // Since we can't overwrite the current line, we've got to cache this update
        // so that we can potentially discard it if another update comes in before a newline.
        _pendingLine = formattedLine;
    }
}

- (void)printNewline {
    if (_pendingLine) {
        [_outputHandle printString:@"%@", _pendingLine];
        _pendingLine = nil;
    }
    _currentLine = nil;
    [_outputHandle printString:@"\n"];
}

@end
