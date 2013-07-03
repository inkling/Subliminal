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

@interface focus_SLGeometryTest : SLIntegrationTest

@end

@implementation focus_SLGeometryTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLGeometryTestViewController";
}

- (void)testTheRectOfTheMainWindowIsEquivalent
{
    const CGRect UIARect = SLCGRectFromUIARect(@"UIATarget.localTarget().frontMostApp().navigationBar().rect()");
    const CGRect UIKitRect = [SLAskApp(navigationBarFrameValue) CGRectValue];
    
    SLAssertTrue(CGRectEqualToRect(UIARect, UIKitRect), @"The frame of the main window should be the same when coming from UIAutomation or UIKit");
}

- (void)testTest
{
    NSString *result = [[SLTerminal sharedTerminal] eval:@"UIATarget.localTarget().frontMostApp().mainWindow().rect()"];
    SLLog(@"Result = %@",result);
    SLAssertTrue(YES, @"YES is true");
}

@end
