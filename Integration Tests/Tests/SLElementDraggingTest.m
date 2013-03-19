//
//  SLElementDraggingTest.m
//  Subliminal
//
//  Created by Aaron Golden on 2/28/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementDraggingTest : SLIntegrationTest {
    SLElement *_scrollView;
}
@end

@implementation SLElementDraggingTest

- (void)setUpTest {
	[super setUpTest];
    _scrollView = [SLElement elementWithAccessibilityLabel:@"drag scrollview"];
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementDraggingTestViewController";
}

/// This test demonstrates simply that we can drag a view.
- (void)testDraggingSimple {
    // Make sure the labels start out the way we expect (top is visible, bottom is not).
    SLElement *topLabel = [SLElement elementWithAccessibilityLabel:@"Top"];
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertTrue([UIAElement(topLabel) isVisible], @"Top label should be visible at this point in the test.");
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"Bottom label should not be visible at this point in the test.");

    // Drag bottom to top to scroll down and show the bottom label, hiding the top label.
    CGFloat dragStartY = 0.99;
    CGFloat dragEndY = 0.2;
    [_scrollView dragWithStartPoint:CGPointMake(0.75, dragStartY) endPoint:CGPointMake(0.75, dragEndY)];
    SLAssertNoThrow([UIAElement(topLabel) waitUntilInvisible:3.0], @"The top label failed to become invisible after scrolling.");
    SLAssertNoThrow([UIAElement(bottomLabel) waitUntilVisible:3.0], @"The bottom label failed to become visible after scrolling.");

    // Drag top to bottom to scroll up and show the top label again, hiding the bottom label.
    [_scrollView dragWithStartPoint:CGPointMake(0.75, dragEndY) endPoint:CGPointMake(0.75, dragStartY)];
    SLAssertNoThrow([UIAElement(topLabel) waitUntilVisible:3.0], @"The top label failed to become visible after scrolling.");
    SLAssertNoThrow([UIAElement(bottomLabel) waitUntilInvisible:3.0], @"The bottom label failed to become invisible after scrolling.");
}

/// This test demonstrates exactly what it means to drag between two points,
/// in terms of the distance dragged.
- (void)testDraggingPrecise {
    SLAskApp(resetScrollingState);
    CGFloat dragStartY = 0.99;
    CGFloat dragEndY = 0.2;

    // Drag bottom to top to scroll down
    [_scrollView dragWithStartPoint:CGPointMake(0.75, dragStartY) endPoint:CGPointMake(0.75, dragEndY)];

    // Compare the drag distance to the expected distance
    // (with a tolerance because scrollviews' delegates may not receive -scrollViewWillBeginDragging:
    // until dragging has occurred over a small distance, per the documentation).
    const CGFloat kDragRecognitionTolerance = 12.0;
    CGFloat dragDistance = [SLAskApp(dragDistance) floatValue];
    CGFloat expectedDragDistance = CGRectGetHeight([_scrollView rect]) * (dragStartY - dragEndY);
    SLAssertTrue(ABS(dragDistance - expectedDragDistance) < kDragRecognitionTolerance,
                 @"Average drag offset (%g) is very far from the expected offset (%g)!",
                 dragDistance, expectedDragDistance);
}

@end
