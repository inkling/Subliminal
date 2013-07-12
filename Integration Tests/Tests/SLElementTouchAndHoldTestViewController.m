//
//  SLElementTouchAndHoldTestViewController.m
//  Subliminal
//
//  Created by Aaron Golden on 7/11/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLElementTouchAndHoldTestViewController : SLTestCaseViewController
@property (nonatomic, strong) IBOutlet UIButton *touchAndHoldButton;
@property (nonatomic, strong) IBOutlet UILabel *touchDurationLabel;
@end

@implementation SLElementTouchAndHoldTestViewController {
    NSDate *_touchStartDate;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementTouchAndHoldTestViewController";
}

- (void)viewDidLoad {
    [self.touchAndHoldButton addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [self.touchAndHoldButton addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchDown {
    _touchStartDate = [NSDate date];
}

- (void)touchUp {
    NSTimeInterval duration = -[_touchStartDate timeIntervalSinceNow];
    self.touchDurationLabel.text = [NSString stringWithFormat:@"Touch duration: %ld", lround(duration)];
}

@end
