//
//  SLElementTouchAndHoldTest.m
//  Subliminal
//
//  Created by Aaron Golden on 7/11/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementTouchAndHoldTest : SLIntegrationTest
@end

@implementation SLElementTouchAndHoldTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementTouchAndHoldTestViewController";
}

- (void)testTouchAndHoldWithDuration {
    SLButton *touchAndHoldButton = [SLButton elementWithAccessibilityLabel:@"Touch and Hold"];
    [UIAElement(touchAndHoldButton) touchAndHoldWithDuration:1.0];
    SLElement *counter = [SLElement elementWithAccessibilityLabel:@"Touch duration: 1"];
    SLAssertTrue([UIAElement(counter) isValid], @"Touch duration label does not appear as expected.");
    [UIAElement(touchAndHoldButton) touchAndHoldWithDuration:2.0];
    counter = [SLElement elementWithAccessibilityLabel:@"Touch duration: 2"];
    SLAssertTrue([UIAElement(counter) isValid], @"Touch duration label does not appear as expected.");
}

@end
