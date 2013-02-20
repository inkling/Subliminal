//
//  SLElementMatchingTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLElementMatchingTestViewController : SLTestCaseViewController

@end

@interface SLElementMatchingTestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fooButton;
@end

@implementation SLElementMatchingTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementMatchingTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fooButton.accessibilityLabel = @"foo";
    self.fooButton.accessibilityValue = @"fooValue";
}

@end
