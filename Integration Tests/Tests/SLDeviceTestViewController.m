//
//  SLDeviceTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLDeviceTestViewController : SLTestCaseViewController

@end

@interface SLDeviceTestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *countdownDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (nonatomic) NSTimeInterval currentCount;
@end

@implementation SLDeviceTestViewController {
    NSTimer *_countdownTimer;
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLDeviceTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(beginCountdown:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
    [_countdownTimer invalidate]; _countdownTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.countdownDescriptionLabel.hidden = YES;
    self.countdownLabel.hidden = YES;
}

- (void)setCurrentCount:(NSTimeInterval)currentCount {
    _currentCount = currentCount;
    self.countdownLabel.text = [NSString stringWithFormat:@"%g", _currentCount];
}

- (void)beginCountdown:(NSNumber *)countdownIntervalNumber {
    if (_countdownTimer) return;

    NSTimeInterval countdownInterval = [countdownIntervalNumber doubleValue];
    self.countdownDescriptionLabel.text = [NSString stringWithFormat:@"Deactivating for %g seconds in", countdownInterval];
    self.countdownDescriptionLabel.hidden = NO;

    self.currentCount = countdownInterval;
    self.countdownLabel.hidden = NO;

    _countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown:) userInfo:nil repeats:YES];
}

- (void)updateCountdown:(NSTimer *)timer {
    if (self.currentCount >= 1.0) {
        self.currentCount--;
        if (self.currentCount < 1.0) {
            [_countdownTimer invalidate]; _countdownTimer = nil;
        }
    }
}

@end
