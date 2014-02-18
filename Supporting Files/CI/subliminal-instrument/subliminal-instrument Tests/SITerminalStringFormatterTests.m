//
//  SITerminalStringFormatterTests.m
//  subliminal-instrument
//
//  Created by Jeffrey Wear on 2/9/14.
//  Copyright (c) 2014 jeffreywear. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SITerminalStringFormatter.h"

@interface SITerminalStringFormatterTests : SenTestCase

@end

@implementation SITerminalStringFormatterTests {
    SITerminalStringFormatter *_formatter;
}

- (void)setUp {
    [super setUp];

    _formatter = [[SITerminalStringFormatter alloc] init];
}

#pragma mark - Test Formatting Valid Strings

- (void)testFormattingStringWithoutMarkup {
    NSString *input = @"foo";
    NSString *expectedOutput = input;
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput, @"");
}

- (void)testFormattingStringWithFlatEscapeSequences { // "flat" as in not nested
    NSString *input = @"This is a <b>very</b> important message";
    NSString *expectedOutput = @"This is a \033[1mvery\033[0m important message";
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput, @"");
}

- (void)testFormattingStringWithNestedEscapeSequences {
    NSString *input = @"This is a <ul><b>very</b> important</ul> message";
    NSString *expectedOutput = @"This is a \033[4m\033[1mvery\033[0m\033[4m important\033[0m message";
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput, @"");
}

- (void)testFormattingTagsAreCaseInsensitive {
    NSString *input = @"<YELLOW><warning/></YELLOW> I wouldn't do that if I were you.";
    NSString *expectedOutput = @"\033[33m\u26A0\033[0m I wouldn't do that if I were you.";
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput, @"");
}

#pragma mark -Test Formatting With Colors Disabled

- (void)testFormattingStringWithColorsDisabled {
    _formatter.useColors = NO;
    NSString *input = @"This is a <ul><b>very</b> important</ul> message";
    NSString *expectedOutput = @"This is a very important message";
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput,
                         @"With colors disabled, the escape sequences should have been stripped from the string.");
}

#pragma mark - Test Formatting Malformed Strings

- (void)testFormattingStringWithMissingTagReturnsNil {
    NSLog(@"*** The error message below is expected.");
    NSString *input = @"This is a <b>very important message";
    NSString *output = [_formatter formattedStringFromString:input];
    STAssertNil(output, @"");
}

- (void)testFormattingStringWithMismatchedTagReturnsNil {
    NSLog(@"*** The error message below is expected.");
    NSString *input = @"This is a <b>very</ul> important message";
    NSString *output = [_formatter formattedStringFromString:input];
    STAssertNil(output, @"");
}

- (void)testFormattingStringWithMismatchedNestedTagReturnsNil {
    NSLog(@"*** The error message below is expected.");
    NSString *input = @"This is a <ul><b>very</ul> important</b> message";
    NSString *output = [_formatter formattedStringFromString:input];
    STAssertNil(output, @"");
}

- (void)testFormattingStringWithUnknownTagStripsTag {
    NSString *input = @"This is a <b>very</b> <foo>important</foo> message";
    NSString *expectedOutput = @"This is a \033[1mvery\033[0m important message";
    NSString *actualOutput = [_formatter formattedStringFromString:input];
    STAssertEqualObjects(expectedOutput, actualOutput, @"");
}

@end
