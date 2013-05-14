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

- (void)testEvalReturnsValuesOfCommandsThatEvaluateToStringsBooleansOrNumbersElseNil {
    id result;
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"'foo'"]), @"Should not have thrown.");
    SLAssertTrue([result isEqual:@"foo"], @"-eval: did not return expected value.");

    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"false"]), @"Should not have thrown.");
    SLAssertTrue([result isEqual:@NO], @"-eval: did not return expected value.");

    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"5"]), @"Should not have thrown.");
    SLAssertTrue([result isEqual:@5], @"-eval: did not return expected value.");

    // For everything else, we return nil.
    // Arrays and dictionaries (hashes) serialize faithfully
    // if they contain only property-list types, but if they don't,
    // they serialize as empty collections.
    // If at some point we decide to support more complex types,
    // we should probably switch to using JSON.
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"function foo(){}"]), @"Should not have thrown.");
    SLAssertTrue(result == nil, @"-eval: did not return expected value.");

    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"var bar = { key: 'value' }; bar"]), @"Should not have thrown.");
    SLAssertTrue(result == nil, @"-eval: did not return expected value.");

    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] eval:@"var bar = [ 'value' ]; bar"]), @"Should not have thrown.");
    SLAssertTrue(result == nil, @"-eval: did not return expected value.");
}

- (void)testRethrowsJavascriptExceptions {
    // throws because the script could not be evaluated
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] eval:@"var"], SLTerminalJavaScriptException,
                        @"Terminal should have rethrown Javascript exception.");

    // throws because the script threw an exception when evaluated
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] eval:@"throw 'test'"],
                        SLTerminalJavaScriptException,
                        @"Terminal should have rethrown Javascript exception.");
}

@end
