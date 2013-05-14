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

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementDraggingTestViewController";
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(resetScrollingState)];
        [testController registerTarget:self forAction:@selector(dragDistance)];
        [testController registerTarget:self forAction:@selector(disableScrollViewUserInteraction)];
        [testController registerTarget:self forAction:@selector(enableScrollViewUserInteraction)];
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

- (void)disableScrollViewUserInteraction {
    self.scrollView.userInteractionEnabled = NO;
}

- (void)enableScrollViewUserInteraction {
    self.scrollView.userInteractionEnabled = YES;
}

@end
