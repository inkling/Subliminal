//
//  SLTerminalTest.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import "SLIntegrationTest.h"
#import "SLUIAElement+Subclassing.h"

@interface SLTerminalTest : SLIntegrationTest
@end

@implementation SLTerminalTest {
    NSString *_functionName;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLTerminalTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    [super setUpTestCaseWithSelector:testSelector];
    
    // The function evaluation test cases below must each use a different function,
    // as Subliminal does not support unloading functions.
    // A simple way to enforce this is to derive the function name from the test case name.
    _functionName = [NSString stringWithFormat:@"%@_%@",
                        NSStringFromClass([self class]), NSStringFromSelector(testSelector)];
}

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

// Note: the fundamental ability to communicate with the Automation instrument
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
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] eval:@"var"],
                        SLTerminalJavaScriptException,
                        @"Terminal should have rethrown Javascript exception.");

    // throws because the script threw an exception when evaluated
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] eval:@"throw 'test'"],
                        SLTerminalJavaScriptException,
                        @"Terminal should have rethrown Javascript exception.");
}

- (void)testStringVarargsMustBeEscaped {
    // single-quoted literal
    NSString *messageWithSingleQuotes = @"This framework is called 'Subliminal.'";
    SLAssertThrowsNamed(([[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');",
                                                                        messageWithSingleQuotes]),
                        SLTerminalJavaScriptException,
                        @"Command should not have been able to be parsed.");
    SLAssertNoThrow(([[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage('%@');",
                                                                    [messageWithSingleQuotes slStringByEscapingForJavaScriptLiteral]]),
                    @"Command should have been able to be parsed.");

    // double-quoted literal
    NSString *messageWithDoubleQuotes = @"This framework is called \"Subliminal.\"";
    SLAssertThrowsNamed(([[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage(\"%@\");", messageWithDoubleQuotes]),
                        SLTerminalJavaScriptException,
                        @"Command should not have been able to be parsed.");
    SLAssertNoThrow(([[SLTerminal sharedTerminal] evalWithFormat:@"UIALogger.logMessage(\"%@\");", [messageWithDoubleQuotes slStringByEscapingForJavaScriptLiteral]]),
                    @"Command should have been able to be parsed.");
}

#pragma mark - Function evaluation tests

- (void)testCanLoadAndEvaluateFunction {
    SLAssertNoThrow([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                               params:(@[ @"one", @"two" ])
                                                                 body:@"return one + two;"],
                    @"Should not have thrown.");
    id result;
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                       withArgs:(@[ @"5", @"7" ])]),
                    @"Should not have thrown.");
    SLAssertTrue([result isEqual:@12], @"Function did not evaluate to expected result.");
}

- (void)testCanLoadAndEvaluateFunctionTakingNoArguments {
    SLAssertNoThrow([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                               params:nil
                                                                 body:@"return 'Hello World';"],
                    @"Should not have thrown.");
    id result;
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                       withArgs:nil]),
                    @"Should not have thrown.");
    SLAssertTrue([result isEqual:@"Hello World"], @"Function did not evaluate to expected result.");
}

- (void)testCanLoadAndEvaluateFunctionUsingConvenienceWrapper {
    id result;
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                         params:(@[ @"one", @"two" ])
                                                                           body:@"return one + two;"
                                                                       withArgs:(@[ @"5", @"7" ])]),
                    @"Should not have thrown.");
    SLAssertTrue([result isEqual:@12], @"Function did not evaluate to expected result.");
}

- (void)testLoadFunctionThrowsIfFunctionHasBeenPreviouslyLoadedWithDifferentSignature {
    SLAssertNoThrow([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                               params:(@[ @"one", @"two" ])
                                                                 body:@"return one + two;"],
                    @"Should not have thrown.");
    
    // loadFunctionWithName:params:body: is idempotent...
    SLAssertNoThrow([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                               params:(@[ @"one", @"two" ])
                                                                 body:@"return one + two;"],
                    @"Should not have thrown because params and body arguments match those of first invocation.");

    // but will throw if invoked again with the same function name, but different params...
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                                   params:(@[ @"one", @"two", @"three" ])
                                                                     body:@"return one + two;"],
                        NSInternalInconsistencyException,
                        @"Should not have thrown because params differed from first invocation.");

    // or with the same function name, but a different body
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                                   params:(@[ @"one", @"two" ])
                                                                     body:@"return one + two + two;"],
                        NSInternalInconsistencyException,
                        @"Should not have thrown because body differed from first invocation.");
}

- (void)testLoadFunctionThrowsIfFunctionNameParamsOrBodyCannotBeEvaluated {
    // invalid function name
    NSString *invalidFunctionName = [NSString stringWithFormat:@"%@+", _functionName];
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] loadFunctionWithName:invalidFunctionName
                                                                   params:(@[ @"one", @"two" ])
                                                                     body:@"return one + two;"],
                        SLTerminalJavaScriptException,
                        @"Should have thrown because function name could not be evaluated.");

    // invalid parameter name
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                                   params:(@[ @"one+", @"two" ])
                                                                     body:@"return one + two;"],
                        SLTerminalJavaScriptException,
                        @"Should have thrown because params could not be evaluated.");

    // malformed body
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                                   params:(@[ @"one+", @"two" ])
                                                                     body:@"return one +;"],
                        SLTerminalJavaScriptException,
                        @"Should have thrown because body could not be evaluated.");
}

- (void)testEvalFunctionThrowsIfFunctionHasNotBeenPreviouslyLoaded {
    SLAssertThrowsNamed(([[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                       withArgs:(@[ @"5", @"7" ])]),
                        NSInternalInconsistencyException,
                        @"Should have thrown because function has not previously been loaded.");
}

- (void)testEvalFunctionThrowsIfArgumentsAreInvalid {
    SLAssertNoThrow([[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                                               params:(@[ @"aString" ])
                                                                 body:@"return aString.toUpperCase();"],
                    @"Should not have thrown.");
    id result;
    SLAssertNoThrow((result = [[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                       withArgs:(@[ @"'hi'" ])]),
                    @"Should not have thrown.");
    SLAssertTrue([result isEqual:@"HI"], @"Function did not evaluate to expected result.");

    // missing argument
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                 withArgs:nil],
                        SLTerminalJavaScriptException,
                        @"Should have thrown because the function was called with a missing argument.");

    // argument of wrong type
    SLAssertThrowsNamed([[SLTerminal sharedTerminal] evalFunctionWithName:_functionName
                                                                 withArgs:(@[ @"5" ])],
                        SLTerminalJavaScriptException,
                        @"Should have thrown because the function was called with an argument of the wrong type.");
}

#pragma mark - Waiting on boolean expressions and functions tests

static const NSTimeInterval kWaitUntilTrueRetryDelay = 0.25;

// There is some variability in waiting for JS to execute (kWaitUntilTrueRetryDelay for the condition,
// SLTerminalEvaluationDelay for the wait function itself) and in communicating with UIAutomation
// (two SLTerminalReadRetryDelays, one for SLTerminal.js receiving the command and one for SLTerminal
// receiving the result).
- (NSTimeInterval)waitDelayVariability {
    return kWaitUntilTrueRetryDelay + (SLTerminalReadRetryDelay * 2) + SLTerminalEvaluationDelay;
}

- (void)testWaitUntilTrueReturnsYESImmediatelyWhenConditionIsTrueUponWait {
    __block NSTimeInterval startTimeInterval, endTimeInterval;

    SLElement *testElement = [SLElement elementWithAccessibilityLabel:@"Nothing to show here."];
    [testElement waitUntilTappable:NO
                 thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *elementIsVisible = [NSString stringWithFormat:@"%@.isVisible()", uiaRepresentation];

        startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        SLAssertTrue([[SLTerminal sharedTerminal] waitUntilTrue:elementIsVisible
                                                     retryDelay:kWaitUntilTrueRetryDelay
                                                        timeout:1.5],
                     @"The expression should have evaluated to true within the timeout.");
        endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    } timeout:[SLElement defaultTimeout]];

    NSTimeInterval waitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(waitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited for an appreciable interval.", waitTimeInterval);
}

- (void)testWaitUntilTrueReturnsYESImmediatelyAfterConditionBecomesTrue {
    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    __block NSTimeInterval startTimeInterval, endTimeInterval;

    SLElement *testElement = [SLElement elementWithAccessibilityLabel:@"Nothing to show here."];
    [testElement waitUntilTappable:NO
                 thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *elementIsVisible = [NSString stringWithFormat:@"%@.isVisible()", uiaRepresentation];

        startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
        SLAssertTrue([[SLTerminal sharedTerminal] waitUntilTrue:elementIsVisible
                                                     retryDelay:kWaitUntilTrueRetryDelay
                                                        timeout:waitTimeInterval],
                     @"The expression should have evaluated to true within the timeout.");
        endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    } timeout:[SLElement defaultTimeout]];

    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

- (void)testWaitUntilTrueReturnsNOIfConditionIsStillFalseAtEndOfTimeout {
    NSTimeInterval expectedWaitTimeInterval = 2.0;
    __block NSTimeInterval startTimeInterval, endTimeInterval;

    SLElement *testElement = [SLElement elementWithAccessibilityLabel:@"Nothing to show here."];
    [testElement waitUntilTappable:NO
                 thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *elementIsVisible = [NSString stringWithFormat:@"%@.isVisible()", uiaRepresentation];

        startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        SLAssertFalse([[SLTerminal sharedTerminal] waitUntilTrue:elementIsVisible
                                                      retryDelay:kWaitUntilTrueRetryDelay
                                                         timeout:expectedWaitTimeInterval],
                     @"The expression should have evaluated to true within the timeout.");
        endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    } timeout:[SLElement defaultTimeout]];

    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, expectedWaitTimeInterval);
}

// this is just an example of how to use -waitUntilFunctionWithNameIsTrue...;
// it should behave exactly as the above test cases describe -waitUntilTrue:...,
// as waitUntilFunctionWithNameIsTrue... is just a wrapper around -waitUntilTrue:...
- (void)testWaitUntilFunctionWithNameIsTrue {
    [[SLTerminal sharedTerminal] loadFunctionWithName:_functionName
                                               params:@[ @"element" ]
                                                 body:@"return element.isVisible();"];

    NSTimeInterval waitTimeInterval = 2.0;
    NSTimeInterval expectedWaitTimeInterval = waitTimeInterval - [self waitDelayVariability] - 0.05;
    __block NSTimeInterval startTimeInterval, endTimeInterval;

    SLElement *testElement = [SLElement elementWithAccessibilityLabel:@"Nothing to show here."];
    [testElement waitUntilTappable:NO
                 thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        SLAskApp1(showTestViewAfterInterval:, @(expectedWaitTimeInterval));
        SLAssertTrue([[SLTerminal sharedTerminal] waitUntilFunctionWithNameIsTrue:_functionName
                                                            whenEvaluatedWithArgs:(@[ uiaRepresentation ])
                                                                       retryDelay:kWaitUntilTrueRetryDelay
                                                                          timeout:waitTimeInterval],
                     @"The expression should have evaluated to true within the timeout.");
        endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    } timeout:[SLElement defaultTimeout]];

    NSTimeInterval actualWaitTimeInterval = endTimeInterval - startTimeInterval;
    SLAssertTrue(actualWaitTimeInterval - expectedWaitTimeInterval < [self waitDelayVariability],
                 @"Test waited for %g but should not have waited appreciably longer than %g.",
                 actualWaitTimeInterval, waitTimeInterval);
}

@end
