//
//  SLElementDraggingTestViewController.m
//  Subliminal
//
//  Created by Aaron Golden on 2/28/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface SLElementDraggingTestViewController : SLTestCaseViewController <UIScrollViewDelegate> {
    CGFloat _scrollViewWillBeginDraggingOffset, _dragDistance;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

@implementation SLElementDraggingTestViewController

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithNibName:[[self class] nibNameForTestCase:testCase] bundle:nil];
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
    self.scrollView.accessibilityIdentifier = @"drag scrollview";
}

- (void)resetScrollingState {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    _dragDistance = 0.0;
}

- (NSNumber *)dragDistance {
    return @(_dragDistance);
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementDraggingTestViewController";
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

@end
