//
//  SLSwitchTestViewController.m
//  Subliminal
//
//  Created by Justin Mutter on 2013-09-13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLSwitchTestViewController : SLTestCaseViewController

@end

@interface SLSwitchTestViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *theSwitch;
@end

@implementation SLSwitchTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLSwitchTestViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.theSwitch.accessibilityLabel = @"switch";
}

@end
