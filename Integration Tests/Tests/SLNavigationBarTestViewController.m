//
//  SLNavigationBarTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLNavigationBarTestViewController : SLTestCaseViewController
@property (nonatomic, weak) SLNavigationBarTestViewController *parentVC;
@end

@implementation SLNavigationBarTestViewController

- (void)loadViewForTestCase:(SEL)testCase {
    [self loadGenericView];
    
    if (self.parentVC) {
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        [navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Child VC"] animated:NO];
        
        CGRect navBarFrame = (CGRect){ .size = [navBar sizeThatFits:CGSizeZero] };
        navBarFrame.origin = self.view.bounds.origin;
        navBar.frame = navBarFrame;
        [self.view addSubview:navBar];
    }
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(navigationBarFrameValue)];
        [testController registerTarget:self forAction:@selector(presentBarWithoutLeftButton)];
        [testController registerTarget:self forAction:@selector(presentBarInFormSheet)];
        [testController registerTarget:self forAction:@selector(addLeftButtonWithTitle:)];
        [testController registerTarget:self forAction:@selector(addRightButtonWithTitle:)];        
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (NSValue *)navigationBarFrameValue {
    return [NSValue valueWithCGRect:[self.navigationController.navigationBar accessibilityFrame]];
}

// there's no way to entirely remove a left (back) button from a navigation controller's nav bar, only hide it
// so we must present a new view controller with its own, unmanaged nav bar
- (void)presentBarWithoutLeftButton {
    SLNavigationBarTestViewController *childVC = [[SLNavigationBarTestViewController alloc] initWithTestCaseWithSelector:self.testCase];
    childVC.parentVC = self;
    [self presentViewController:childVC animated:NO completion:nil];
    
    // register this here so the child controller doesn't steal it
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(dismissBarWithoutLeftButton)];
}

- (void)dismissBarWithoutLeftButton {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)presentBarInFormSheet {
    SLNavigationBarTestViewController *childVC = [[SLNavigationBarTestViewController alloc] initWithTestCaseWithSelector:self.testCase];
    childVC.parentVC = self;
    childVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:childVC animated:NO completion:nil];
    
    // register this here so the child controller doesn't steal it
    [[SLTestController sharedTestController] registerTarget:self forAction:@selector(dismissBarInFormSheet)];
}

- (void)dismissBarInFormSheet {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)addLeftButtonWithTitle:(NSString *)title {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                             style:UIBarButtonItemStylePlain target:nil action:NULL];
}

- (void)addRightButtonWithTitle:(NSString *)title {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                              style:UIBarButtonItemStylePlain target:nil action:NULL];
}

@end
