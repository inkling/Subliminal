//
//  SLElementDraggingTestViewController.m
//  Subliminal
//
//  Created by Aaron Golden on 2/28/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface SLElementDraggingTestViewController : SLTestCaseViewController {
    CGFloat _totalScrollViewDidEndDraggingOffset;
    NSUInteger _didEndDraggingCount;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

@implementation SLElementDraggingTestViewController

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithNibName:[[self class] nibNameForTestCase:testCase] bundle:nil];
    if (self) {
        SLTestController *testController = [SLTestController sharedTestController];
        [testController registerTarget:self forAction:@selector(setScrollOffset:)];
        [testController registerTarget:self forAction:@selector(resetScrollingState)];
        [testController registerTarget:self forAction:@selector(averageScrollViewDidEndDraggingOffset)];
    }
    return self;
}

- (void)dealloc {
    [[SLTestController sharedTestController] deregisterTarget:self];
}

- (void)setScrollOffset:(NSNumber *)offset {
    [self.scrollView setContentOffset:CGPointMake(0.0, [offset floatValue]) animated:NO];
}

- (void)resetScrollingState {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    _totalScrollViewDidEndDraggingOffset = 0.0;
    _didEndDraggingCount = 0;
}

- (NSNumber *)averageScrollViewDidEndDraggingOffset {
    return @(_totalScrollViewDidEndDraggingOffset / _didEndDraggingCount);
}

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLElementDraggingTestViewController";
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 2000.0);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _totalScrollViewDidEndDraggingOffset += scrollView.contentOffset.y;
    _didEndDraggingCount++;
}

@end
