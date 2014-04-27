//
//  SLSliderTest.m
//  Subliminal
//
//  Created by Maximilian Tagher on 4/27/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLSliderTest : SLIntegrationTest

@property (nonatomic, strong) SLSlider *aSlider;

@end

@implementation SLSliderTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLSliderTestViewController";
}

- (void)setUpTest
{
    [super setUpTest];
    
    self.aSlider = [SLSlider elementWithAccessibilityLabel:@"slider"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector
{
    [super setUpTestCaseWithSelector:testCaseSelector];
    
    SLAssertTrue([UIAElement(self.aSlider) isValidAndVisible], @"Slider should be valid and visible");
    SLAssertTrue([UIAElement(self.aSlider) isTappable], @"Slider should be tappable");
}

- (void)testSLSliderDragToValue
{
    [self.aSlider dragToValue:1];
    SLAssertTrue([[self.aSlider value] isEqualToString:@"100%"], @"After dragging to 1, the value should be 100 percent");
}

- (void)testFormattingSLSLiderValue
{
    SLAssertTrue([self.aSlider floatValue] == 0.5f, @"The slider's starting percentage (50 percent) should be formatted as 0.5f");
}

@end
