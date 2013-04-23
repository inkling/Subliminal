//
//  SLMainThreadRefTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 4/15/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SLMainThreadRef.h"


@interface SLTestMainThreadRef : SLMainThreadRef
@property (nonatomic, weak) id autoreleasingTarget;
@end

@implementation SLTestMainThreadRef
@end


@interface SLMainThreadRefTests : SenTestCase
@end

@implementation SLMainThreadRefTests

- (void)testTargetsMustBeAccessedFromMainThread {
    id __block target = [[NSMutableArray alloc] init];
    SLMainThreadRef *ref = [SLMainThreadRef refWithTarget:target];

    STAssertNoThrow([ref target], @"Should not have thrown");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"*** The assertion failure seen in the test output immediately below is an expected part of the tests.");
        STAssertThrows([ref target], @"Should have thrown");
    });

    // spin the run loop to give the background assertion time to pass or fail
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (void)testTargetsAreNotRetained {
    id target = [[NSMutableArray alloc] init];
    SLMainThreadRef *ref = [SLMainThreadRef refWithTarget:target];

    // target will be autoreleased on return--have to flush it from pool
    // so as not to cause second assertion to fail
    @autoreleasepool {
        STAssertNotNil([ref target], @"Should not be nil");
    }
    
    target = nil;
    STAssertNil([ref target], @"Should be nil");
}

@end
