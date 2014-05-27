//
//  SLGeometryTest.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

#import <Subliminal/SLGeometry.h>
#import <Subliminal/SLTerminal+ConvenienceFunctions.h>

@interface SLGeometryTest : SLIntegrationTest

@end

@implementation SLGeometryTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLGeometryTestViewController";
}

- (void)testSLUIARectFromCGRect {
    NSString *const expectedRect = @"{ origin: { x: 5.0, y: 10.0 }, size: { width: 50.0, height: 100.0 } }";
    NSString *const actualRect = SLUIARectFromCGRect(CGRectMake(5.0, 10.0, 50.0, 100.0));

    SLAssertTrue([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectEqualToRectFunctionName()
                                                           withArgs:(@[ actualRect, expectedRect ])] boolValue],
                 @"`SLUIARectFromCGRect` did not return the expected value.");
}

- (void)testSLCGRectFromUIARect {
    const CGRect expectedRect = CGRectMake(5.0, 10.0, 50.0, 100.0);
    const CGRect actualRect = SLCGRectFromUIARect(@"{ origin: { x: 5.0, y: 10.0 }, size: { width: 50.0, height: 100.0 } }");
    
    SLAssertTrue(CGRectEqualToRect(actualRect, expectedRect),
                 @"`SLCGRectFromUIARect` did not return the expected value.");
}

- (void)testSLUIARectEqualToRect {
    NSString *const rect1 = @"{ origin: { x: 5.0, y: 10.0 }, size: { width: 50.0, height: 100.0 } }";
    NSString *const rect2 = @"{ origin: { x: 5.0, y: 10.0 }, size: { width: 50.0, height: 115.0 } }";

    SLAssertTrue([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectEqualToRectFunctionName()
                                                           withArgs:(@[ rect1, rect1 ])] boolValue],
                 @"Two identical rects should be equal.");
    SLAssertTrue([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectEqualToRectFunctionName()
                                                           withArgs:(@[ @"null", @"null" ])] boolValue],
                 @"Two null rects should be equal.");
    SLAssertFalse([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectEqualToRectFunctionName()
                                                            withArgs:(@[ rect1, rect2 ])] boolValue],
                  @"Two different rects should not be equal.");
}

- (void)testSLUIARectContainsRect {
    NSString *const containerRect =         @"{ origin: { x: 5.0, y: 10.0 }, size: { width: 50.0, height: 100.0 } }";
    NSString *const containedWithinRect =   @"{ origin: { x: 10.0, y: 15.0 }, size: { width: 30.0, height: 50.0 } }";
    NSString *const intersectingRect =      @"{ origin: { x: 10.0, y: 15.0 }, size: { width: 50.0, height: 100.0 } }";
    NSString *const nonIntersectingRect =   @"{ origin: { x: 65.0, y: 120.0 }, size: { width: 50.0, height: 100.0 } }";

    SLAssertTrue([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectContainsRectFunctionName()
                                                           withArgs:(@[ containerRect, containerRect ])] boolValue],
                 @"A rect should contain itself.");
    SLAssertTrue([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectContainsRectFunctionName()
                                                           withArgs:(@[ containerRect, containedWithinRect ])] boolValue],
                 @"A rect should contain a rect within itself.");
    SLAssertFalse([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectContainsRectFunctionName()
                                                            withArgs:(@[ containerRect, intersectingRect])] boolValue],
                  @"A rect should not contain a partially-intersecting rect.");
    SLAssertFalse([[[SLTerminal sharedTerminal] evalFunctionWithName:SLUIARectContainsRectFunctionName()
                                                            withArgs:(@[ containerRect, nonIntersectingRect])] boolValue],
                  @"A rect should not contain a non-intersecting rect.");
}

@end
