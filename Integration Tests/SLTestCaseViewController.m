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

- (void)loadViewForTestCase:(SEL)testCase {
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
        [self loadViewForTestCase:self.testCase];
        NSAssert([self isViewLoaded], @"Concrete subclasses of %@ must override -%@ if they do not override +%@.",
                NSStringFromClass([SLTestCaseViewController class]),
                 NSStringFromSelector(@selector(loadViewForTestCase:)), NSStringFromSelector(@selector(nibNameForTestCase:)));
    }
}

@end
