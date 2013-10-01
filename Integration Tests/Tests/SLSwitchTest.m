//
//  SLSwitchTest.m
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLSwitchTest : SLIntegrationTest

@end

@implementation SLSwitchTest {
    SLSwitch *_aSwitch;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLSwitchTestViewController";
}

- (void)setUpTest
{
    [super setUpTest];
    _aSwitch = [SLSwitch elementWithAccessibilityLabel:@"switch"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector
{
    [super setUpTestCaseWithSelector:testCaseSelector];
    SLAssertTrue([UIAElement(_aSwitch) isValidAndVisible], @"Switch should be valid and visible");
    SLAssertTrue([UIAElement(_aSwitch) isTappable], @"Switch should be tappable");
    [_aSwitch setOn:YES];
}

- (void)testSLSwitchSetOn
{
    [_aSwitch setOn:NO];
    SLAssertTrue([[_aSwitch value] boolValue] == NO, @"Switch value was not set to OFF");
    [_aSwitch setOn:YES];
    SLAssertTrue([[_aSwitch value] boolValue] == YES, @"Switch value was not set to ON");
}

- (void)testSLSwitchIsOn
{
    [_aSwitch setOn:NO];
    SLAssertTrue([_aSwitch isOn] == NO, @"Switch should be OFF");
    [_aSwitch setOn:YES];
    SLAssertTrue([_aSwitch isOn] == YES, @"Switch should be ON");
}

- (void)testSLSwitchCanToggleWithTap
{
    BOOL value = [_aSwitch.value boolValue];
    [_aSwitch tap];
    SLAssertFalse(value == [_aSwitch.value boolValue], @"Value should have changed");
    [_aSwitch tap];
    SLAssertTrue(value == [_aSwitch.value boolValue], @"Value should have changed back");
}

@end
