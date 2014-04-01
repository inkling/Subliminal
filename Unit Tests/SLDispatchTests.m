//
//  SLDispatchTests.m
//  Subliminal
//
//  Created by Maximilian Tagher on 3/31/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SLTerminal.h"
#import "SLLogger.h"

/**
 When Apple deprecated the `dispatch_get_current_queue` functionality, the workaround we came up with was to use `dispatch_queue_set_specific` and `dispatch_get_specific` to check if we were on that queue.
 
 These tests verify that was a valid workaround.
 
 See https://github.com/inkling/Subliminal/issues/164
 */
@interface SLDispatchTests : SenTestCase

@end

@implementation SLDispatchTests

- (void)testSLTerminalCurrentQueueIsEvalQueue
{
    dispatch_sync([SLTerminal sharedTerminal].evalQueue, ^{
        STAssertTrue([[SLTerminal sharedTerminal] currentQueueIsEvalQueue], @"We should be on the eval queue");
    });
    
    STAssertFalse([[SLTerminal sharedTerminal] currentQueueIsEvalQueue], @"We should not be on the eval queue");
}

- (void)testSLLoggerCurrentQueueIsLoggingQueue
{
    dispatch_sync([SLLogger sharedLogger].loggingQueue, ^{
        STAssertTrue([[SLLogger sharedLogger] currentQueueIsLoggingQueue], @"We should be on the logging queue");
    });
    
    STAssertFalse([[SLLogger sharedLogger] currentQueueIsLoggingQueue], @"We should not be on the logging queue");
}

@end
