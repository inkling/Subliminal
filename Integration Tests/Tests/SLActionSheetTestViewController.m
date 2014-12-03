//
//  SLActionSheetTestViewController.m
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

@interface SLActionSheetTestViewController : SLTestCaseViewController <UIActionSheetDelegate>

@end

@implementation SLActionSheetTestViewController {
    UILabel *_label;
    UIActionSheet *_actionSheet;
    BOOL _actionSheetVisible;
}

- (void)loadViewForTestCase:(SEL)testCase {
    // Since we're testing popovers in this test,
    // we don't need any particular view.
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(200.0f, 200.0f)}];
    view.backgroundColor = [UIColor whiteColor];

    UIFont *nothingToShowHereFont = [UIFont systemFontOfSize:18.0f];
    NSString *nothingToShowHereText = @"Nothing to show here.";
    CGSize nothingToShowHereSize = [nothingToShowHereText sizeWithFont:nothingToShowHereFont
                                                     constrainedToSize:CGSizeMake(3 * CGRectGetWidth(view.bounds) / 4.0f, CGFLOAT_MAX)];
    _label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, nothingToShowHereSize}];
    _label.backgroundColor = view.backgroundColor;
    _label.font = nothingToShowHereFont;
    _label.numberOfLines = 0;
    _label.text = nothingToShowHereText;
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [view addSubview:_label];
    _label.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));

    self.view = view;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(showActionSheet)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(isActionSheetVisible)];
        [[SLTestController sharedTestController] registerTarget:self forAction:@selector(hideActionSheet)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

#pragma mark - App hooks

- (void)showActionSheet {
    // Pass in nil for the cancelButtonTitle if displaying on an iPad
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Action Sheet" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];

    [_actionSheet showFromRect:_label.frame inView:self.view animated:NO];
}

- (NSNumber *)isActionSheetVisible {
    return @(_actionSheetVisible);
}

- (void)hideActionSheet {
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
    _actionSheetVisible = NO;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _actionSheetVisible = NO;
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    _actionSheetVisible = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _actionSheetVisible = NO;
}

@end
