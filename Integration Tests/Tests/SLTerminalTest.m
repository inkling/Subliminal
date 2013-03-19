//
//  DummyTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTest.h"
#import "SLTerminal.h"

@interface SLTerminalTest : SLTest  // The terminal test doesn't need an interface
@end

@implementation SLTerminalTest

- (void)testMustUseSharedTerminal {
    NSLog(@"*** The two assertion failures seen in the test output immediately below are an expected part of the tests.");

    // ignore the unused results below
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

    // test attempted manual allocation before retrieving shared controller
    SLAssertThrows([[SLTerminal alloc] init],
                   @"Should not have been able to manually initialize an SLTerminal.");

    SLAssertTrue([SLTerminal sharedTerminal] != nil,
                 @"Should have been able to retrieve shared terminal.");

    // test attempted manual allocation after retrieving shared controller
    SLAssertThrows([[SLTerminal alloc] init],
                   @"Should not have been able to manually initialize an SLTerminal.");

#pragma clang diagnostic pop
}

#pragma mark - Command evaluation tests

// Note: the fundamental ability to communicate with UIAutomation
// has been verified by the app delegate at startup time.

- (void)testRethrowsJavascriptExceptions {
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] eval:@"throw 'test'"],
                        SLTerminalJavaScriptException,
                        @"Terminal should have rethrown Javascript exception.");
}

@end
