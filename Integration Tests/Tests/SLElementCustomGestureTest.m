//
//  SLElementCustomGestureTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementCustomGestureTest : SLIntegrationTest

@end

@implementation SLElementCustomGestureTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementCustomGestureTestViewController";
}

- (void)setUpTest {
    [super setUpTest];

    _testElement = [SLElement elementWithAccessibilityLabel:@"test element"];
}

- (void)focus_testCustomGesture {
    while (YES) {
        BOOL recordNewGesture = YES;
        NSString *const gesturePath = @"/Users/jeffreywear/Desktop/test.slgesture";

        SLGesture *gesture = nil;
        if (recordNewGesture) {
            SLLog(@"Waiting for gesture to be recorded...");

            gesture = [SLGestureRecordingSession recordGestureWithElement:_testElement];
            [gesture writeToFile:gesturePath];

            // small pause between dismissing the recording UI and playing the gesture back
            [self wait:1.0];
        } else {
            gesture = [SLGesture gestureWithContentsOfFile:gesturePath];
        }

        SLLog(@"Playing gesture back.");
        [gesture applyToElement:_testElement];

        [self wait:3.0];
    }
}

@end
