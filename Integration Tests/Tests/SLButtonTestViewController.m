//
//  SLButtonTestViewController.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
