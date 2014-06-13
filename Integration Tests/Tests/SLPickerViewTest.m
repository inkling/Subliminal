//
//  SLPickerViewTest.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLPickerViewTest : SLIntegrationTest

@end

@implementation SLPickerViewTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLPickerViewTestViewController";
}

- (void)focus_testPickerView {
    // Validate initial state
    SLTextField *textField = [SLTextField elementWithAccessibilityIdentifier:@"Text Field"];
    SLPickerView *pickerView = [SLPickerView elementWithAccessibilityIdentifier:@"Picker View"];

    SLAssertTrue([[UIAElement(textField) value] isEqualToString:@"1 - 1"], @"SLTextField should have matched the UITextField.");
    SLAssertFalse([pickerView isValidAndVisible], @"The Picker View shouldn't be visible initially");

    // Tapping the text field should make the picker view appear
    SLAssertNoThrow([UIAElement(textField) tap], @"SLTextField should be tappable.");
    SLAssertTrue([UIAElement(pickerView) isValid], @"SLPickerView should be valid.");
    // NOTE: The element is not considered visible, because it is fully covered by its spinners
    SLAssertFalse([UIAElement(pickerView) isVisible], @"SLPickerView itslef isn't visible.");
    SLAssertTrue([UIAElement(pickerView) isTappable], @"SLPickerView should be tappable.");

    // Make sure the custom methods all work
    SLAssertTrue([UIAElement(pickerView) numberOfComponentsInPickerView] == 2, @"SLPickerView should have 2 components.");
    NSArray *values = [UIAElement(pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"1. 1 of 3"], @"SLPickerView first spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(textField) value] isEqualToString:@"1 - 1"], @"SLTextField should have updated to match the UITextField.");

    // Select value 1 on the first picker component
    SLAssertTrue([UIAElement(pickerView) selectValue:@"2" forComponent:0], @"SLPickerView should be able to set the first value.");
    values = [UIAElement(pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"2. 2 of 3"], @"SLPickerView first spinner should have value '2. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(textField) value] isEqualToString:@"2 - 1"], @"SLTextField should have updated to match the UITextField.");

    // Select an invalid value on the second picker component
    SLAssertThrowsNamed([UIAElement(pickerView) selectValue:@"0" forComponent:1], @"SLUIAElementAutomationException", @"SLPickerView should return false on trying to select an invalid value.");
    SLAssertThrowsNamed([UIAElement(pickerView) selectValue:@"3" forComponent:2], @"SLUIAElementAutomationException", @"SLPickerView should return false on trying to select an invalid component.");

    // Values should be unchanged after failed changes
    values = [UIAElement(pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"2. 2 of 3"], @"SLPickerView first spinner should have value '2. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(textField) value] isEqualToString:@"2 - 1"], @"SLTextField should have updated to match the UITextField.");

    // Select value 1 on the first picker component
    SLAssertTrue([UIAElement(pickerView) selectValue:@"3" forComponent:1], @"SLPickerView should be able to set the first value.");
    values = [UIAElement(pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"2. 2 of 3"], @"SLPickerView first spinner should have value '2. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"3. 3 of 3"], @"SLPickerView second spinner should have value '3. 3 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(textField) value] isEqualToString:@"2 - 3"], @"SLTextField should have updated to match the UITextField.");
}

@end
