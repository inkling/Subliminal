//
//  SLElementDraggingTest.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
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

#import "SLIntegrationTest.h"

static const CGFloat kTopLabelYOffset = 0.99;
static const CGFloat kBottomLabelYOffset = 0.2;

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
    _scrollView = [SLElement elementWithAccessibilityIdentifier:@"drag scrollview"];
}

/// This test demonstrates simply that we can drag a view.
/// It will also confirm that we can drag a scroll view
/// despite UIAutomation reporting it not being tappable when running
/// on the iPad 5.1 Simulator (though error messages are logged).
- (void)testDraggingSimple {
    // Do not run this test on Travis, because even very simple scrolling tests
    // fail regularly on the Travis machines.  These tests seem to work fine in
    // other CI environments (such as Jenkins), but on Travis they're unreliable.
    char *travis = getenv("TRAVIS");
    if (travis) {
        return;
    }

    // Make sure the labels start out the way we expect (top is visible, bottom is not).
    SLElement *topLabel = [SLElement elementWithAccessibilityLabel:@"Top"];
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertTrue([UIAElement(topLabel) isVisible], @"Top label should be visible at this point in the test.");
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"Bottom label should not be visible at this point in the test.");

    // Instruments sometimes refuses to drag. If it does we attempt a retry.
    NSException *dragException = nil;
startDraggingSimple:
    @try {
        // Drag bottom to top to scroll down and show the bottom label, hiding the top label.
        [_scrollView dragWithStartOffset:CGPointMake(0.75, kTopLabelYOffset) endOffset:CGPointMake(0.75, kBottomLabelYOffset)];
        SLAssertTrueWithTimeout([UIAElement(topLabel) isInvalidOrInvisible], 3.0, @"The top label failed to become invisible after scrolling.");
        SLAssertTrueWithTimeout([UIAElement(bottomLabel) isValidAndVisible], 3.0, @"The bottom label failed to become visible after scrolling.");

        // Drag top to bottom to scroll up and show the top label again, hiding the bottom label.
        [_scrollView dragWithStartOffset:CGPointMake(0.75, kBottomLabelYOffset) endOffset:CGPointMake(0.75, kTopLabelYOffset)];
        SLAssertTrueWithTimeout([UIAElement(topLabel) isValidAndVisible], 3.0, @"The top label failed to become visible after scrolling.");
        SLAssertTrueWithTimeout([UIAElement(bottomLabel) isInvalidOrInvisible], 3.0, @"The bottom label failed to become invisible after scrolling.");
    }
    @catch (NSException *exception) {
        if (dragException) @throw exception;
        else {
            dragException = exception;
            SLAskApp(resetScrollingState);
            [self wait:2.0];
            goto startDraggingSimple;
        }
    }
}

/// This test demonstrates exactly what it means to drag between two points,
/// in terms of the distance dragged.
- (void)testDraggingPrecise {
    // Do not run this test on Travis, because even very simple scrolling tests
    // fail regularly on the Travis machines.  These tests seem to work fine in
    // other CI environments (such as Jenkins), but on Travis they're unreliable.
    char *travis = getenv("TRAVIS");
    if (travis) {
        return;
    }

    CGFloat dragStartY = kTopLabelYOffset;
    CGFloat dragEndY = kBottomLabelYOffset;

    
    // Instruments sometimes refuses to drag. If it does we attempt a retry.
    NSException *dragException = nil;
startDraggingPrecise:
    @try {
        // Drag bottom to top to scroll down
        [_scrollView dragWithStartOffset:CGPointMake(0.75, dragStartY) endOffset:CGPointMake(0.75, dragEndY)];

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
    @catch (NSException *exception) {
        if (dragException) @throw exception;
        else {
            dragException = exception;
            SLAskApp(resetScrollingState);
            [self wait:2.0];
            goto startDraggingPrecise;
        }
    }
}


- (void)testScrollToVisible {
    // Make sure the labels start out the way we expect (top is visible, bottom is not).
    SLElement *topLabel = [SLElement elementWithAccessibilityLabel:@"Top"];
    SLElement *bottomLabel = [SLElement elementWithAccessibilityLabel:@"Bottom"];
    SLAssertTrue([UIAElement(topLabel) isVisible], @"Top label should be visible at this point in the test.");
    SLAssertFalse([UIAElement(bottomLabel) isVisible], @"Bottom label should not be visible at this point in the test.");

    [bottomLabel scrollToVisible];

    SLAssertTrueWithTimeout([UIAElement(topLabel) isInvalidOrInvisible], 3.0, @"The top label failed to become invisible after scrolling.");
    SLAssertTrueWithTimeout([UIAElement(bottomLabel) isValidAndVisible], 3.0, @"The bottom label failed to become visible after scrolling.");
}

@end
