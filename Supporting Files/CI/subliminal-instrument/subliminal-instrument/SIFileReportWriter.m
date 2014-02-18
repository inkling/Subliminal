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

static const NSUInteger kIndentSize = 4;
static const NSUInteger kDefaultWidth = 80;

@implementation SIFileReportWriter {
    NSFileHandle *_outputHandle;
    BOOL _outputHandleIsATerminal;
    NSString *_indentString;
    NSUInteger _dividerWidth;
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

        // closing dividers have the down line to link back to the indent
        BOOL includeDownLine = !_dividerActive;
        NSString *divider = [self dividerWithDownLineAtLocation:(includeDownLine ? [_indentString length] : NSNotFound)];
        [self printLine:divider usingIndent:NO];
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

- (void)printLine:(NSString *)line {
    [self printLine:line usingIndent:!self.dividerActive];
}

- (void)printLine:(NSString *)line usingIndent:(BOOL)usingIndent {
    [_outputHandle printString:@"%@%@\n", (usingIndent ? _indentString : @""), line];
}

@end
