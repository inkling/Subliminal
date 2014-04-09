//
//  SLGeometryUnitTests.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SLGeometry.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLGeometryUnitTests : SenTestCase

@end

@implementation SLGeometryUnitTests

- (void)testSLUIARectFromCGRectThrowsWhenGivenCGRectNull
{
    STAssertThrowsSpecificNamed(SLUIARectFromCGRect(CGRectNull), NSException, NSInternalInconsistencyException, @"An internal inconsistency exception should be thrown if CGRectNull is passed");
}

- (void)testSLUIARectFromCGRectConvertsCorrectly
{
    STAssertEqualObjects(SLUIARectFromCGRect(CGRectMake(0.5f, -10, 20, 30)), @"{origin:{x:0.500000,y:-10.000000}, size:{width:20.000000, height:30.000000}}", @"A rect of {{0.5f,-10},{20,30}} should return the correct UIA representation");
}



@end
