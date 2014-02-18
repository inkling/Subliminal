//
//  NSTask+Utilities.m
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

#import "NSTask+Utilities.h"

#import "NSPipe+Utilities.h"

@implementation NSTask (Utilities)

- (NSString *)output {
    NSPipe *outPipe = [NSPipe pipe];

    [outPipe beginReadingInBackground];
    [self setStandardOutput:outPipe];

    [self launch];
    [self waitUntilExit];
    [outPipe finishReading];

    // We read in the background, rather than simply doing
    // `NSData *outData = [[outPipe fileHandleForReading] readDataToEndOfFile];`,
    // to avoid the pipe potentially filling up.
    NSData *outData = [outPipe availableData];
    return [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
}

@end
