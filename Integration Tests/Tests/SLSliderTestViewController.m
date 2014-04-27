//
//  SLSliderTestViewController.m
//  Subliminal
//
//  Created by Maximilian Tagher on 4/27/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLSliderTestViewController : SLTestCaseViewController

@end

@interface SLSliderTestViewController ()

@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation SLSliderTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLSliderTestViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slider.accessibilityLabel = @"slider";
}

@end
