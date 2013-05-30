//
//  SLStringUtilitiesTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
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
