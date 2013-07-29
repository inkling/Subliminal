//
//  SLTextViewTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 7/29/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLTextViewTestViewController : SLTestCaseViewController

@end

@interface SLTextViewTestViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation SLTextViewTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLTextViewTestViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _textView.accessibilityLabel = @"test element";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(text)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(setText:)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSString *)text {
    return self.textView.text;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

@end
