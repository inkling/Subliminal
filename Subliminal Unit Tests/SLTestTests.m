//
//  SLTestTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>

#import "SharedTests.h"

@interface SLTestTests : SenTestCase

@end

@implementation SLTestTests

- (void)testAllTestsReturnsExpected {
    NSSet *allTests = [SLTest allTests];
    NSSet *expectedTests = [NSSet setWithObjects:
        [EmptyTest class],
        nil
    ];
    STAssertEqualObjects(allTests, expectedTests, @"Unexpected tests returned.");
}

- (void)testTestNamedReturnsExpected {
    Class validTestClass = [EmptyTest class];
    Class resultTestClass = [SLTest testNamed:NSStringFromClass(validTestClass)];
    STAssertEqualObjects(resultTestClass, validTestClass, @"+testNamed: should have found the test.");

    Class undefinedTestClass = [SLTest testNamed:NSStringFromSelector(_cmd)];
    STAssertNil(undefinedTestClass, @"+testNamed: should not have found a test.");
}

@end
