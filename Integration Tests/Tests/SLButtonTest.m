//
//  SLButtonTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/20/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLButtonTest : SLIntegrationTest

@end

@implementation SLButtonTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLButtonTestViewController";
}

- (void)testSLButtonMatchesObjectsWithButtonTrait {
    // SLButton matches UIButtons
    SLButton *button = [SLButton elementWithAccessibilityLabel:@"button"];
    SLAssertTrue([[UIAElement(button) value] isEqualToString:@"button value"],
                 @"SLButton should have matched a UIButton.");

    // but really any object (here, a plain UIView) with UIAccessibilityTraitButton
    SLButton *buttonElement = [SLButton elementWithAccessibilityLabel:@"button element"];
    SLAssertTrue([[UIAElement(buttonElement) value] isEqualToString:@"button element value"],
                 @"SLButton should have matched a UIView with UIAccessibilityButtonTrait.");
}

@end
