//
//  SLTextFieldPickerViewTest.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLTextFieldPickerViewTest : SLIntegrationTest
@end

// All of these test cases focus on containing a UIPickerView in a TextField's inputView
@implementation SLTextFieldPickerViewTest {
    SLTextField *_textField;
    SLPickerView *_pickerView;
}

#pragma mark - Test Case Setup

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTextFieldPickerTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];

    _textField = [SLTextField elementWithAccessibilityIdentifier:@"Text Field"];
    _pickerView = [SLPickerView elementWithAccessibilityIdentifier:@"Picker View"];
    _pickerView.isPickerForTextInputView = YES;
}

#pragma mark - Test Cases

- (void)testTextInputPickerViewIsNotFoundBeforeTapping {
    // Validate initial state
    SLAssertTrue([[UIAElement(_textField) value] isEqualToString:@"1 - 1"], @"SLTextField should have matched the UITextField.");
    SLAssertFalse([UIAElement(_pickerView) isValidAndVisible], @"The Picker View shouldn't be visible initially");
}

- (void)testTextInputPickerViewCanBeFoundAfterTappingText {
    // Tapping the text field should make the picker view appear
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");
    SLAssertTrue([UIAElement(_pickerView) isValid], @"SLPickerView should be valid.");
    SLAssertTrue([UIAElement(_pickerView) isTappable], @"SLPickerView should be tappable.");
}

// Breaking the Visibility check out into a separate test, as it requires a custom method implementation
- (void)testTextInputPickerViewIsVisibleAfterTappingText {
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");
    SLAssertTrue([UIAElement(_pickerView) isVisible], @"SLPickerView should be visible.");
}

- (void)testTextInputPickerViewReportsCorrectNumberOfComponents {
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");
    SLAssertTrue([UIAElement(_pickerView) numberOfComponentsInPickerView] == 2, @"SLPickerView should have 2 components.");
}

- (void)testTextInputPickerViewInitialComponentValues {
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");
    NSArray *values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"1. 1 of 3"], @"SLPickerView first spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);

    // Just sanity checking that the vales are being kept in sync with the textField via the delegate
    SLAssertTrue([[UIAElement(_textField) value] isEqualToString:@"1 - 1"], @"SLTextField should have updated to match the UITextField.");
}

- (void)testTextInputPickerViewValuesCanBeModified {
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");

    // Select value 2 on the first picker component
    [UIAElement(_pickerView) selectValue:@"2" forComponent:0];
    NSArray *values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"2. 2 of 3"], @"SLPickerView first spinner should have value '2. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(_textField) value] isEqualToString:@"2 - 1"], @"SLTextField should have updated to match the UITextField.");

    // Select value 3 on the second picker component
    [UIAElement(_pickerView) selectValue:@"3" forComponent:1];
    values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"2. 2 of 3"], @"SLPickerView first spinner should have value '2. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"3. 3 of 3"], @"SLPickerView second spinner should have value '3. 3 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(_textField) value] isEqualToString:@"2 - 3"], @"SLTextField should have updated to match the UITextField.");
}

- (void)testTextInputPickerViewValuesArentModifiedOnInvalidSelections {
    SLAssertNoThrow([UIAElement(_textField) tap], @"SLTextField should be tappable.");

    // Get us in a good state showing "3 - 1"
    [UIAElement(_pickerView) selectValue:@"3" forComponent:0];

    // Select an invalid value on the second picker component
    SLAssertThrowsNamed([UIAElement(_pickerView) selectValue:@"0" forComponent:1], @"SLUIAElementAutomationException", @"SLPickerView should return false on trying to select an invalid value.");
    SLAssertThrowsNamed([UIAElement(_pickerView) selectValue:@"3" forComponent:2], @"SLUIAElementAutomationException", @"SLPickerView should return false on trying to select an invalid component.");

    // Values should be unchanged after failed changes
    NSArray *values = [UIAElement(_pickerView) valueOfPickerComponents];
    SLAssertTrue([values count] == 2, @"SLPickerView should have 2 spinner components. Actual: %d", [values count]);
    SLAssertTrue([[values objectAtIndex:0] isEqualToString:@"3. 3 of 3"], @"SLPickerView first spinner should have value '3. 1 of 3'. Actual: %@", [values objectAtIndex:0]);
    SLAssertTrue([[values objectAtIndex:1] isEqualToString:@"1. 1 of 3"], @"SLPickerView second spinner should have value '1. 1 of 3'. Actual: %@", [values objectAtIndex:1]);
    SLAssertTrue([[UIAElement(_textField) value] isEqualToString:@"3 - 1"], @"SLTextField should have updated to match the UITextField.");
}

@end
