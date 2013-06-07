//
//  SLMainThreadRefTests.m
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
