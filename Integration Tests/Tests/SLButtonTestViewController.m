//
//  SLButtonTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/20/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLButtonTestViewController : SLTestCaseViewController

@end

@interface SLButtonTestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *buttonElement;
@property (weak, nonatomic) IBOutlet UIView *otherElement;
@end

@implementation SLButtonTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLButtonTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(buttonValue)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(buttonElementValue)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.button.accessibilityLabel = @"button";
    self.button.accessibilityValue = @"button value";

    // note that the button element and the other element have the same label
    // but only the button element has UIAccessibilityTraitButton
    // in our test we should match the button element
    self.buttonElement.isAccessibilityElement = YES;
    self.buttonElement.accessibilityLabel = @"button element";
    self.buttonElement.accessibilityTraits = UIAccessibilityTraitButton;
    self.buttonElement.accessibilityValue = @"button element value";

    self.otherElement.isAccessibilityElement = YES;
    self.otherElement.accessibilityLabel = @"button element";
    self.otherElement.accessibilityValue = @"other element value";
}

- (NSString *)buttonValue {
    return @"button value";
}

- (NSString *)buttonElementValue {
    return @"button element value";
}

@end
