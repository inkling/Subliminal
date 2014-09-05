//
//  SLActionSheetTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLActionSheetTestViewController : SLTestCaseViewController

@end

@implementation SLActionSheetTestViewController {
    UIActionSheet *_actionSheet;
    UIPopoverController *_popoverController;
}

- (void)loadViewForTestCase:(SEL)testCase {
    [self loadGenericView];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(showActionSheetWithInfo:)];
        [testController registerTarget:self forAction:@selector(dismissActionSheet)];
        [testController registerTarget:self forAction:@selector(actionSheetFrameValue)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showActionSheetWithInfo:(NSDictionary *)info {
    NSAssert(!_actionSheet, @"An action sheet is already showing.");
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:info[@"title"]
                                               delegate:nil
                                      cancelButtonTitle:info[@"cancelButtonTitle"]
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:info[@"otherButtonTitle1"], info[@"otherButtonTitle2"], nil];

    if ([info[@"showInPopover"] boolValue]) {
        SLActionSheetTestViewController *contentViewController = [[SLActionSheetTestViewController alloc] initWithTestCaseWithSelector:self.testCase];
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
        _popoverController.popoverContentSize = CGSizeMake(320.0f, 480.0f);
        [_popoverController presentPopoverFromRect:CGRectInset((CGRect){ .origin = self.view.center }, -10.0f, -10.0f)
                                            inView:self.view.superview
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];

        // register this here vs. in init so the controller we just presented doesn't steal it
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(dismissPopover)];
        [_actionSheet showInView:_popoverController.contentViewController.view];
    } else {
        [_actionSheet showInView:self.view];
    }
}

- (void)dismissActionSheet {
    [_actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    _actionSheet = nil;
}

- (NSValue *)actionSheetFrameValue {
    return [NSValue valueWithCGRect:_actionSheet.accessibilityFrame];
}

- (void)dismissPopover {
    [_popoverController dismissPopoverAnimated:NO];
}

@end
