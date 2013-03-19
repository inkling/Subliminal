//
//  SLElementStateTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementStateTest : SLIntegrationTest

@end

@implementation SLElementStateTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementStateTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    _testElement = [SLElement elementWithAccessibilityLabel:@"Test Element"];
}

- (void)testValue {
    NSString *expectedValue = SLAskApp(elementValue);
    NSString *value = [_testElement value];
    SLAssertTrue([value isEqualToString:expectedValue], @"-value did not return expected.");
}

- (void)testRect {
    CGRect expectedRect = [SLAskApp(elementRect) CGRectValue];
    CGRect rect = [_testElement rect];
    SLAssertTrue(CGRectEqualToRect(expectedRect, rect), @"-rect did not return expected.");
}

@end
