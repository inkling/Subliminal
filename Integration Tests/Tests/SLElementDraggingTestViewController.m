//
//  SLElementDraggingTestViewController.m
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

@interface SLElementDraggingTestViewController : SLTestCaseViewController <UIScrollViewDelegate> {
    CGFloat _scrollViewWillBeginDraggingOffset, _dragDistance;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

@implementation SLElementDraggingTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementDraggingTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(resetScrollingState)];
        [testController registerTarget:self forAction:@selector(dragDistance)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.accessibilityIdentifier = @"drag scrollview";
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 2000.0);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _scrollViewWillBeginDraggingOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat scrollViewDidEndDraggingOffset = scrollView.contentOffset.y;
    _dragDistance = ABS(scrollViewDidEndDraggingOffset - _scrollViewWillBeginDraggingOffset);
}

#pragma mark - App hooks

- (void)resetScrollingState {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    _dragDistance = 0.0;
}

- (NSNumber *)dragDistance {
    return @(_dragDistance);
}

@end
