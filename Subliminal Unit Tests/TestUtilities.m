//
//  TestUtilities.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/26/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "TestUtilities.h"
#import <Subliminal/Subliminal.h>

void SLRunTestsAndWaitUntilFinished(NSSet *tests, void (^completionBlock)()) {
    __block BOOL testingHasFinished = NO;
    [[SLTestController sharedTestController] runTests:tests
                                  withCompletionBlock:^{
                                      if (completionBlock) completionBlock();
                                      testingHasFinished = YES;
                                  }];
    while (!testingHasFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    // After the SLTestController executes its completion block
    // it still has one more command to send through the terminal.
    // We must spin once more to give it time to do so,
    // lest the unit test which called this tear down,
    // and destroy its partial mock for the terminal,
    // as the controller tries to use the terminal.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
}
