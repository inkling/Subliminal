//
//  SLPickerTestViewController.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLPickerTestViewController : SLTestCaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation SLPickerTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLPickerViewTestView";
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[NSString alloc] initWithFormat:@"%li", (long)(row + 1)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

@end
