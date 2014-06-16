//
//  SLTextFieldPicker.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTextFieldPicker.h"

@interface SLTextFieldPicker () <UIPickerViewDelegate, UIPickerViewDataSource>
@property UIPickerView *pickerView;
@end

@implementation SLTextFieldPicker {
    NSMutableArray *_values;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.accessibilityIdentifier = @"Picker View";
        _values = [[NSMutableArray alloc] initWithObjects:@1, [[NSNumber alloc] initWithInt:1], nil];
        self.inputView = _pickerView;
        self.accessibilityIdentifier = @"Text Field";
        [self updateText];
    }

    return self;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[NSString alloc] initWithFormat:@"%d", (row + 1)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _values[component] = @(row + 1);
    [self updateText];
}

- (void)updateText {
    self.text = [_values componentsJoinedByString:@" - "];
}

// Have the cursor to not blink in the text field, but it isn't necessary to test the scenario.
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

@end
