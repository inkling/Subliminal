//
//  SLStringUtilitiesTests.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import <SenTestingKit/SenTestingKit.h>
#import "SLStringUtilities.h"


@interface SLStringUtilitiesTests : SenTestCase

@end


@implementation SLStringUtilitiesTests

// `-[NSString(SLJavaScript) slStringByEscapingForJavaScriptLiteral]`
// is tested by `-[SLTerminal testStringVarargsMustBeEscaped]`.

- (void)testSLComposeStringReturnsEmptyIfFormatIsNil {
    STAssertEqualObjects(@"", SLComposeString(nil, nil),
                         @"Did not return expected value.");
}

- (void)testSLComposeStringIgnoresLeadingStringIfFormatIsNil {
    STAssertEqualObjects(@"", SLComposeString(@" ", nil),
                         @"Did not return expected value.");
}

- (void)testSLComposeStringReturnsFormattedStringIfFormatIsNonNil {
    STAssertEqualObjects(@"Hello World", SLComposeString(nil, @"%@ %@", @"Hello", @"World"),
                         @"Did not return expected value.");
}

- (void)testSLComposeStringPrefixesFormattedStringIfLeadingStringIsNonNil {
    STAssertEqualObjects(@" Hello World", SLComposeString(@" ", @"%@ %@", @"Hello", @"World"),
                         @"Did not return expected value.");
}

@end
