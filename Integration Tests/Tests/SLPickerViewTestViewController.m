//
//  SLPickerViewTestViewController.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLTestPickerTextField : UITextField <UIPickerViewDelegate, UIPickerViewDataSource>
@property UIPickerView *pickerView;
@end

@implementation SLTestPickerTextField {
    NSMutableArray *_values;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.accessibilityIdentifier = @"Picker View";
        _values = [[NSMutableArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:1], [[NSNumber alloc] initWithInt:1], nil];
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
    [_values setObject:[[NSNumber alloc] initWithInt:(row + 1)] atIndexedSubscript:component];
    [self updateText];
}

- (void)updateText {
    self.text = [_values componentsJoinedByString:@" - "];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

@end

@interface SLPickerViewTestViewController : SLTestCaseViewController
@property (weak, nonatomic) IBOutlet SLTestPickerTextField *textField;
@end

@implementation SLPickerViewTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLPickerViewTestViewController";
}

@end
