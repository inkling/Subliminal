//
//  SLElementDraggingTest.m
//  Subliminal
//
//  Created by Aaron Golden on 2/28/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementDraggingTest : SLIntegrationTest {
    SLWindow *_mainWindow;
}
@end

@implementation SLElementDraggingTest

- (void)setUpTest {
	[super setUpTest];
    _mainWindow = [SLWindow mainWindow];
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementDraggingTestViewController";
}

- (void)testDraggingUpAndDown {
    // Make sure the labels start out the way we expect (top is visible, bottom is not).
    SLElement *topLabel = [SLElement elementWithAccessibilityLabel:@"Top"];
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertTrue([UIAElement(topLabel) isVisible], @"Top label should be visible at this point in the test.");
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"Bottom label should not be visible at this point in the test.");

    const CGFloat kPixelTollerance = 5.0;

    SLTestController *sharedTestController = [SLTestController sharedTestController];
    [sharedTestController sendAction:@selector(resetScrollingState)];
    CGFloat dragStartY = 0.99;
    CGFloat dragEndY = 0.2;
    for (NSUInteger j = 0; j < 10; j++) {
        [sharedTestController sendAction:@selector(setScrollOffset:) withObject:[NSNumber numberWithFloat:0.0]];

        // Drag bottom to top to scroll down and show the bottom label, hiding the top label.
        [_mainWindow dragWithStartPoint:CGPointMake(0.75, dragStartY) endPoint:CGPointMake(0.75, dragEndY)];
        SLAssertNoThrow([UIAElement(topLabel) waitUntilInvisible:3.0], @"The top label failed to become invisible after scrolling.");
        SLAssertNoThrow([UIAElement(bottomLabel) waitUntilVisible:3.0], @"The bottom label failed to become visible after scrolling.");
    }
    NSNumber *averageDragDidEndOffsetNumber = [sharedTestController sendAction:@selector(averageScrollViewDidEndDraggingOffset)];
    CGFloat averageDragDidEndOffset = [averageDragDidEndOffsetNumber floatValue];
    CGFloat expectedOffset = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) * (dragStartY - dragEndY);
    SLAssertTrue(averageDragDidEndOffset > expectedOffset - kPixelTollerance && averageDragDidEndOffset < expectedOffset + kPixelTollerance, @"Average drag did end offset is very far from the expected value!");

    [sharedTestController sendAction:@selector(resetScrollingState)];
    dragStartY = 0.2;
    dragEndY = 0.99;
    for (NSUInteger j = 0; j < 10; j++) {
        [sharedTestController sendAction:@selector(setScrollOffset:) withObject:[NSNumber numberWithFloat:expectedOffset]];

        // Drag top to bottom to scroll up and show the top label again, hiding the bottom label.
        [_mainWindow dragWithStartPoint:CGPointMake(0.75, dragStartY) endPoint:CGPointMake(0.75, dragEndY)];
        SLAssertNoThrow([UIAElement(topLabel) waitUntilVisible:3.0], @"The top label failed to become visible after scrolling.");
        SLAssertNoThrow([UIAElement(bottomLabel) waitUntilInvisible:3.0], @"The bottom label failed to become invisible after scrolling.");
    }
    averageDragDidEndOffsetNumber = [sharedTestController sendAction:@selector(averageScrollViewDidEndDraggingOffset)];
    averageDragDidEndOffset = [averageDragDidEndOffsetNumber floatValue];
    expectedOffset = 0.0; // Should be back to the top of the content.
    SLAssertTrue(averageDragDidEndOffset > expectedOffset - kPixelTollerance && averageDragDidEndOffset < expectedOffset + kPixelTollerance, @"Average drag did end offset is very far from the expected value!");
}

@end
