//
//  SLDatePickerTest.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLDatePickerTest : SLIntegrationTest
@end

// All of these test cases focus on containing a UIPickerView in a TextField's inputView
@implementation SLDatePickerTest {
    SLDatePicker *_pickerView;
}

#pragma mark - Test Case Setup

+ (NSString *)testCaseViewControllerClassName {
    return @"SLDatePickerTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];
    
    _pickerView = [SLDatePicker elementWithAccessibilityIdentifier:@"Picker View"];
    
}

#pragma mark - Test Cases

- (void)testDatePickerCanBeFoundAfterTappingText {
    SLAssertTrue([UIAElement(_pickerView) isValid], @"SLDatePicker should be valid.");
    SLAssertTrue([UIAElement(_pickerView) isTappable], @"SLDatePicker should be tappable.");
}

// Breaking the Visibility check out into a separate test, as it requires a custom method implementation
- (void)testDatePickerIsVisibleAfterTappingText {
    SLAssertTrue([UIAElement(_pickerView) isVisible], @"SLDatePicker should be visible.");
}

- (void)testDatePickerReportsCorrectNumberOfComponents {
    SLAssertTrue([UIAElement(_pickerView) numberOfComponentsInPickerView] == 3, @"SLDatePicker should have 3 components by default.");
}

// Default value is hardcoded to 12/12/2012
- (void)testDatePickerInitialComponentValues {
    NSArray *values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 3, @"SLDatePicker should have 3 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"December"], @"SLDatePicker first spinner should have value 'December'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"12"], @"SLDatePicker second spinner should have value '12'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[values objectAtIndex:2] isEqualToString:@"2012"], @"SLDatePicker third spinner should have value '2012'. Actual: %@", [values objectAtIndex:2]);
}

- (void)testDatePickerValuesCanBeModified {
    // Select value 'November 13 2010' on the DatePicker
    [UIAElement(_pickerView) selectValue:@"November" forComponent:0];
    [UIAElement(_pickerView) selectValue:@"13" forComponent:1];
    [UIAElement(_pickerView) selectValue:@"2010" forComponent:2];
    
    NSArray *values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 3, @"SLDatePicker should have 3 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"November"], @"SLDatePicker first spinner should have value 'November'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"13"], @"SLDatePicker second spinner should have value '13'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[values objectAtIndex:2] isEqualToString:@"2010"], @"SLDatePicker third spinner should have value '2010'. Actual: %@", [values objectAtIndex:2]);
}

@end
