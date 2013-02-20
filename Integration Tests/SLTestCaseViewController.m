//
//  SLTestCaseViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@implementation SLTestCaseViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return nil;
}

+ (UIView *)viewForTestCase:(SEL)testCase {
    return nil;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithNibName:[[self class] nibNameForTestCase:testCase] bundle:nil];
    if (self) {
        _testCase = testCase;
    }
    return self;
}

- (NSString *)title {
    return NSStringFromSelector(self.testCase);
}

- (void)loadView {
    // if we have a nib, load it
    if (self.nibName) {
        [super loadView];
    } else {
        // otherwise load the view programmatically
        UIView *view = [[self class] viewForTestCase:self.testCase];
        NSAssert(view, @"Concrete subclasses of %@ must override %@ if they do not override %@.",
                        NSStringFromClass([SLTestCaseViewController class]),
                        NSStringFromSelector(@selector(viewForTestCase:)), NSStringFromSelector(@selector(nibNameForTestCase:)));
        self.view = view;
    }
}

@end
