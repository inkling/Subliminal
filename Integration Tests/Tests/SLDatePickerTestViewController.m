//
//  SLDatePickerTestViewController.m
//  Subliminal
//
//  Created by Justin Martin on 6/13/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLDatePickerTestViewController : SLTestCaseViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation SLDatePickerTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLDatePickerTestView";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Apparently iOS 6 doesn't support initializing a Date control to a specific value directly in the XIB
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:12];
        [comps setMonth:12];
        [comps setYear:2012];
        [self.datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
    }
}

@end
