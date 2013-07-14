//
//  SLGeometryTest.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>
#import "SLIntegrationTest.h"
#import "SLGeometry.h"
#import "SLTerminal.h"

@interface SLGeometryTest : SLIntegrationTest

@end

@implementation SLGeometryTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLGeometryTestViewController";
}

- (void)testSLCGRectFromUIARectConvertsCorrectly
{
    const CGRect UIARect = SLCGRectFromUIARect(@"UIATarget.localTarget().frontMostApp().navigationBar().rect()");
    const CGRect UIKitRect = [SLAskApp(navigationBarFrameValue) CGRectValue];
    
    SLAssertTrue(CGRectEqualToRect(UIARect, UIKitRect), @"The frame of the main window should be the same when coming from UIAutomation or UIKit");
}

@end
