//
//  SLTextFieldPickerTestViewController.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"
#import "SLTextFieldPicker.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLTextFieldPickerTestViewController : SLTestCaseViewController
@property (weak, nonatomic) IBOutlet SLTextFieldPicker *textField;
@end

@implementation SLTextFieldPickerTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLTextFieldPickerTestView";
}

@end
