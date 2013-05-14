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

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementDraggingTestViewController";
}

- (void)setUpTest {
	[super setUpTest];
    _scrollView = [SLElement elementWithAccessibilityLabel:@"drag scrollview"];
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if (testCaseSelector == @selector(testCanDragOnlyWhenTappable)) {
        SLAskApp(disableScrollViewUserInteraction); // to make the scroll view not tappable
    }
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
    SLWaitUntilInvisibleOrInvalid(UIAElement(topLabel), 3.0, @"The top label failed to become invisible after scrolling.");
    SLWaitUntilVisible(UIAElement(bottomLabel), 3.0, @"The bottom label failed to become visible after scrolling.");

    // Drag top to bottom to scroll up and show the top label again, hiding the bottom label.
    [_scrollView dragWithStartPoint:CGPointMake(0.75, dragEndY) endPoint:CGPointMake(0.75, dragStartY)];
    SLWaitUntilVisible(UIAElement(topLabel), 3.0, @"The top label failed to become visible after scrolling.");
    SLWaitUntilInvisibleOrInvalid(UIAElement(bottomLabel), 3.0, @"The bottom label failed to become invisible after scrolling.");
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

- (void)testCanDragOnlyWhenTappable {
    // try dragging bottom to top to scroll down and show the bottom label, first when not tappable
    SLAssertFalse([UIAElement(_scrollView) isTappable],
                  @"For the purposes of this test case, the scroll view should not be tappable.");
    CGFloat dragStartY = 0.99;
    CGFloat dragEndY = 0.2;

    SLLog(@"*** The errors seen in the test output immediately below are an expected part of the tests.");
    SLAssertThrowsNamed([UIAElement(_scrollView) dragWithStartPoint:CGPointMake(0.75, dragStartY)
                                                           endPoint:CGPointMake(0.75, dragEndY)],
                        SLTerminalJavaScriptException,
                        @"Element should be draggable only when tappable.");
    // sanity check
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"The scroll view should not have been dragged.");

    // make the scroll view tappable
    SLAskApp(enableScrollViewUserInteraction);

    // try dragging bottom to top to scroll down and show the bottom label, now when tappable
    SLAssertTrue([UIAElement(_scrollView) isTappable],
                 @"The scroll view should now be tappable.");
    SLAssertNoThrow([UIAElement(_scrollView) dragWithStartPoint:CGPointMake(0.75, dragStartY)
                                                           endPoint:CGPointMake(0.75, dragEndY)],
                    @"Element should be draggable now that it is tappable.");
    SLWaitUntilVisible(UIAElement(bottomLabel), 3.0, @"The bottom label should have become visible after dragging.");
}

@end
