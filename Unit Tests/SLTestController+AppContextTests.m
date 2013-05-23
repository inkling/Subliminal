//
//  SLTestController+AppHooksTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 1/5/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Subliminal/Subliminal.h>
#import <OCMock/OCMock.h>

#import "SharedSLTests.h"
#import "TestUtilities.h"

#pragma mark - App Action Target

@interface SLAppTarget : NSObject

- (void)invalidActionTakingMoreThanOneArgument:(NSNumber *)one two:(NSNumber *)two;
- (void)invalidActionTakingAnArgumentNotOfTypeId:(BOOL)arg;
- (BOOL)invalidActionReturningNeitherVoidNorIdType;

- (void)actionTakingNoArgumentReturningVoid;
- (void)actionTakingAnArgumentReturningVoid:(NSNumber *)arg;
- (NSNumber *)actionTakingNoArgumentReturningAValue;
- (NSNumber *)actionTakingAnArgumentReturningAValue:(NSNumber *)arg;

- (NSNumber *)actionReturningABOOLValue;
- (NSNumber *)actionTakingAnArgumentReturningABOOLValue:(NSNumber *)arg;

@end

@implementation SLAppTarget

- (void)invalidActionTakingMoreThanOneArgument:(NSNumber *)one two:(NSNumber *)two {
    
}

- (void)invalidActionTakingAnArgumentNotOfTypeId:(BOOL)arg {
    
}

- (BOOL)invalidActionReturningNeitherVoidNorIdType {
    return NO;
}

- (void)actionTakingNoArgumentReturningVoid {

}

- (void)actionTakingAnArgumentReturningVoid:(NSNumber *)arg {

}

- (NSNumber *)actionTakingNoArgumentReturningAValue {
    return @YES;
}

- (NSNumber *)actionTakingAnArgumentReturningAValue:(NSNumber *)arg {
    return arg;
}

- (NSNumber *)actionReturningABOOLValue {
    return @YES;
}

- (NSNumber *)actionTakingAnArgumentReturningABOOLValue:(NSNumber *)arg {
    return arg;
}

@end


#pragma mark - Tests

@interface SLTestController_AppHooksTests : SenTestCase

@end

@implementation SLTestController_AppHooksTests {
    id _loggerMock, _terminalMock;

    SLTestController *_controller;
    id _controllerMock;
    id _targetMock;
    Class _testClass;
    id _testMock;
}

- (void)setUpTestWithSelector:(SEL)testMethod {
    // SLTestController will not run without a logger being set
    _loggerMock = [OCMockObject niceMockForClass:[SLLogger class]];
    [SLLogger setSharedLogger:_loggerMock];

    // ensure that Subliminal doesn't get hung up trying to talk to UIAutomation
    _terminalMock = [OCMockObject partialMockForObject:[SLTerminal sharedTerminal]];
    [[_terminalMock stub] eval:OCMOCK_ANY];

    // Set up objects used by tests
    _controller = [SLTestController sharedTestController];
    
    _targetMock = [OCMockObject mockForClass:[SLAppTarget class]];

    _testClass = [TestWithSomeTestCases class];
    _testMock = [OCMockObject partialMockForClass:_testClass];

    // suppress the controller's target lookup timeout except when specifically testing it
    // to speed the tests
    if (testMethod != @selector(testWaitsForTargetToBeRegisteredBeforeThrowing)) {
        _controllerMock = [OCMockObject partialMockForObject:_controller];

        // the targetLookupTimeout method is private because it's only of use to these tests
        SEL targetLookupTimeoutSel = @selector(targetLookupTimeout);
        NSAssert([_controller respondsToSelector:targetLookupTimeoutSel],
                 @"The name of the targetLookupTimeout method has changed and must be updated.");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSTimeInterval immediateTimeout = 0.0;
        [[[_controllerMock stub] andReturnValue:OCMOCK_VALUE(immediateTimeout)] performSelector:targetLookupTimeoutSel];
#pragma clang diagnostic pop
    }
}

- (void)tearDownTestWithSelector:(SEL)testMethod {
    _terminalMock = nil;

    [_controller deregisterTarget:_targetMock];
    _controllerMock = nil;
    _controller = nil;
    _targetMock = nil;
    _testMock = nil;
}

- (void)testThrowsOnRegistrationForActionNotHandledByTarget {
    NSLog(@"*** The assertion failure seen in the test output immediately below is an expected part of the tests.");
    STAssertThrows([_controller registerTarget:_targetMock forAction:_cmd],
                   @"Should have raised an exception because the target does not respond to the action.");
}

- (void)testThrowsOnRegistrationForActionThatTakesMoreThanOneArgument {
    NSLog(@"*** The assertion failure seen in the test output immediately below is an expected part of the tests.");
    STAssertThrows([_controller registerTarget:_targetMock forAction:@selector(invalidActionTakingMoreThanOneArgument:two:)],
                   @"Should have raised an exception because the action takes more than one argument.");
}

- (void)testThrowsOnRegistrationForActionTakingAnArgumentNotOfTypeId {
    NSLog(@"*** The assertion failure seen in the test output immediately below is an expected part of the tests.");
    STAssertThrows([_controller registerTarget:_targetMock forAction:@selector(invalidActionTakingAnArgumentNotOfTypeId:)],
                   @"Should have raised an exception because the action takes an argument not of type id.");
}

- (void)testThrowsOnRegistrationForActionThatReturnsNeitherVoidNorIdType {
    NSLog(@"*** The assertion failure seen in the test output immediately below is an expected part of the tests.");
    STAssertThrows([_controller registerTarget:_targetMock forAction:@selector(invalidActionReturningNeitherVoidNorIdType)],
                   @"Should have raised an exception because the action returns neither void nor id type.");
}

- (void)testSuccessfulRegistrationForActionTakingNoArgumentReturningVoid {
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received
    [[_targetMock expect] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
}

- (void)testSuccessfulRegistrationForActionTakingAnArgumentReturningVoid {
    SEL action = @selector(actionTakingAnArgumentReturningVoid:);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action with the given argument
    NSNumber *actionArg = @YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action withObject:actionArg],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received with the given argument
    [[_targetMock expect] actionTakingAnArgumentReturningVoid:actionArg];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
}

- (void)testSuccessfulRegistrationForActionTakingNoArgumentReturningAValue {
    SEL action = @selector(actionTakingNoArgumentReturningAValue);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action, and check to see that we got the expected value back
    NSNumber *expectedReturnValue = @YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        NSNumber *actualReturnValue = nil;
        STAssertNoThrow(actualReturnValue = [_controller sendAction:action],
                        @"Should not have thrown an exception.");
        STAssertEqualObjects(actualReturnValue, expectedReturnValue, @"Action did not return expected value.");
    }] testOne];

    // expect the action to be received, and return the expected value
    [[[_targetMock expect] andReturn:expectedReturnValue] actionTakingNoArgumentReturningAValue];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
}

- (void)testSuccessfulRegistrationForActionTakingAnArgumentReturningAValue {
    SEL action = @selector(actionTakingAnArgumentReturningAValue:);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action with the given argument, and check to see that we got the expected value back
    NSNumber *actionArg = @YES;
    NSNumber *expectedReturnValue = @YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        NSNumber *actualReturnValue = nil;
        STAssertNoThrow(actualReturnValue = [_controller sendAction:action withObject:actionArg],
                        @"Should not have thrown an exception.");
        STAssertEqualObjects(actualReturnValue, expectedReturnValue, @"Action did not return expected value.");
    }] testOne];

    // expect the action to be received with the given argument, and return the expected value
    [[[_targetMock expect] andReturn:expectedReturnValue] actionTakingAnArgumentReturningAValue:actionArg];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
}

- (void)testRegistrationIsIdempotent {
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");
    // register a second time
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received just once
    [[_targetMock expect] actionTakingNoArgumentReturningVoid];
    [[_targetMock reject] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
}

- (void)testThrowsOnNoTargetRegisteredForActionSent {
    // have testOne call the action
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertThrows([_controller sendAction:action],
                        @"Should have thrown an exception because no target was registered for the action.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
}

- (void)testWaitsForTargetToBeRegisteredBeforeThrowing {
    // have testOne call the action
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        // we register a target after we send the action but before sendAction: times out (5 sec, at present)
        double registrationDelayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(registrationDelayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                            @"Should not have thrown an exception.");
        });

        // and so sendAction: does not throw
        STAssertNoThrow([_controller sendAction:action],
                       @"Should have thrown an exception because no target was registered for the action.");
    }] testOne];

    [[_targetMock expect] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Should have received action.");
}

- (void)testSuccessfulDeregistrationForASingleAction {
    // first run with the action registered
    
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received
    [[_targetMock expect] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");


    // now run with the action deregistered
    
    [_controller deregisterTarget:_targetMock forAction:action];

    // try sending the action again
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertThrows([_controller sendAction:action],
                        @"Should have thrown an exception because no target is registered for the action.");
    }] testOne];

    // expect the action to not be received
    [[_targetMock reject] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should not have received action, because it deregistered.");
}

- (void)testSuccessfulDeregistrationForAllActions {
    // first run with two actions registered

    SEL actionOne = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:actionOne],
                    @"Should not have thrown an exception.");
    SEL actionTwo = @selector(actionTakingNoArgumentReturningAValue);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:actionTwo],
                    @"Should not have thrown an exception.");

    // have testOne call actionOne and testTwo call actionTwo
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:actionOne],
                        @"Should not have thrown an exception.");
    }] testOne];
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow((void)[_controller sendAction:actionTwo],
                        @"Should not have thrown an exception.");
    }] testTwo];

    // expect actionOne and actionTwo to be received
    [[_targetMock expect] actionTakingNoArgumentReturningVoid];
    [[_targetMock expect] actionTakingNoArgumentReturningAValue];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received actions.");


    // now run with all actions deregistered

    [_controller deregisterTarget:_targetMock];

    // try sending the actions again
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertThrows([_controller sendAction:actionOne],
                       @"Should have thrown an exception because no target is registered for the action.");
    }] testOne];
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertThrows((void)[_controller sendAction:actionTwo],
                        @"Should have thrown an exception because no target is registered for the action.");
    }] testTwo];

    // expect the actions to not be received
    [[_targetMock reject] actionTakingNoArgumentReturningVoid];
    [[_targetMock reject] actionTakingNoArgumentReturningAValue];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should not have received actions, because it deregistered.");
}

- (void)testOnlyOneTargetCanBeRegisteredForAnAction {
    // register the first target
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // now register a second target
    id secondTargetMock = [OCMockObject mockForClass:[SLAppTarget class]];
    STAssertNoThrow([_controller registerTarget:secondTargetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received by the second target, but not the first
    [[secondTargetMock expect] actionTakingNoArgumentReturningVoid];
    [[_targetMock reject] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([secondTargetMock verify], @"Second target should have received action.");
    STAssertNoThrow([_targetMock verify], @"First target should not have received action.");
}

- (void)testDeregisteringTargetForActionDoesNotDeregisterOtherTargets {
    // register the first target
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // now register a second target
    id secondTargetMock = [OCMockObject mockForClass:[SLAppTarget class]];
    STAssertNoThrow([_controller registerTarget:secondTargetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have the first target "deregister" for the action--this should be a no-op
    STAssertNoThrow([_controller deregisterTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received by the second target,
    // i.e it should not have been deregistered by the above call
    [[secondTargetMock expect] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([secondTargetMock verify], @"Second target should have received action.");
}

- (void)testTargetsAreNotRetained {
    // Use a local target, not another mock,
    // because we're going to nil it out partway through the test
    // and having _target be nil would be contrary to tearDown's expectations.
    // This needs to be an SLAppTarget * too, not a mock,
    // because mocks are autoreleased and we want to be able to force release by niling it out.
    SLAppTarget *localTarget = [[SLAppTarget alloc] init];
    // take a weak reference to the target prior to registration, to check later
    SLAppTarget *__weak weakLocalTarget = localTarget;
    
    SEL action = @selector(actionTakingNoArgumentReturningVoid);
    STAssertNoThrow([_controller registerTarget:localTarget forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action, and expect it to be received
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow([_controller sendAction:action],
                       @"Should not have thrown an exception.");
    }] testOne];

    id localTargetMock = [OCMockObject partialMockForObject:localTarget];
    [[localTargetMock expect] actionTakingNoArgumentReturningVoid];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([localTargetMock verify], @"Should have received action.");


    // now, release the †arget
    localTarget = nil;
    [localTargetMock stopMocking];
    // check that the target was released
    STAssertNil(weakLocalTarget, @"Target should not have been retained by the test controller.");

    // again, have testOne call the action, but expect the action send to fail
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertThrows([_controller sendAction:action],
                       @"Should have thrown an exception because the target dropped out of scope.");
    }] testOne];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
}

- (void)testSLAskAppIsShorthandForSendAction {
    // make the action name a macro so we can use the same value throughout the test
#undef actionName
#define actionName actionTakingNoArgumentReturningVoid
    SEL action = @selector(actionName);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow(SLAskApp(actionName),
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received
    // note: this causes the mock to expect the invocation of the selector, not that of performSelector:
    [[_targetMock expect] performSelector:@selector(actionName)];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
#undef actionName
}

- (void)testSLAskApp1IsShorthandForSendActionWithObject {
// make the action name a macro so we can use the same value throughout the test
#undef actionName
#define actionName actionTakingAnArgumentReturningVoid:
    SEL action = @selector(actionName);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action with the given argument
    NSNumber *actionArg = @YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        STAssertNoThrow(SLAskApp1(actionName, actionArg),
                        @"Should not have thrown an exception.");
    }] testOne];

    // expect the action to be received with the given argument
    // note: this causes the mock to expect the invocation of the selector, not that of performSelector:withObject:
    [[_targetMock expect] performSelector:@selector(actionName) withObject:actionArg];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
#undef actionName
}

- (void)testSLAskAppYesNoReturnsABOOL {
    // make the action name a macro so we can use the same value throughout the test
#undef actionName
#define actionName actionReturningABOOLValue
    SEL action = @selector(actionName);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action, and check to see that we got the expected value back
    BOOL expectedReturnValue = YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        BOOL actualReturnValue;
        STAssertNoThrow(actualReturnValue = SLAskAppYesNo(actionName),
                        @"Should not have thrown an exception.");
        STAssertEquals(actualReturnValue, expectedReturnValue, @"Action did not return expected value.");
    }] testOne];

    // expect the action to be received with the given argument, and return the expected value
    // note: this causes the mock to expect the invocation of the selector, not that of performSelector:
    [[[_targetMock expect] andReturn:@(expectedReturnValue)] performSelector:@selector(actionName)];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
#undef actionName
}

- (void)testSLAskAppYesNo1TakesAnArgAndReturnsABOOL {
    // make the action name a macro so we can use the same value throughout the test
#undef actionName
#define actionName actionTakingAnArgumentReturningABOOLValue:
    SEL action = @selector(actionName);
    STAssertNoThrow([_controller registerTarget:_targetMock forAction:action],
                    @"Should not have thrown an exception.");

    // have testOne call the action with the given argument, and check to see that we got the expected value back
    NSNumber *actionArg = @YES;
    BOOL expectedReturnValue = YES;
    [[[_testMock expect] andDo:^(NSInvocation *invocation) {
        BOOL actualReturnValue;
        STAssertNoThrow(actualReturnValue = SLAskAppYesNo1(actionName, actionArg),
                        @"Should not have thrown an exception.");
        STAssertEquals(actualReturnValue, expectedReturnValue, @"Action did not return expected value.");
    }] testOne];

    // expect the action to be received with the given argument, and return the expected value
    // note: this causes the mock to expect the invocation of the selector, not that of performSelector:
    [[[_targetMock expect] andReturn:@(expectedReturnValue)] performSelector:@selector(actionName) withObject:actionArg];

    SLRunTestsAndWaitUntilFinished([NSSet setWithObject:_testClass], nil);
    STAssertNoThrow([_testMock verify], @"Should have executed test.");
    STAssertNoThrow([_targetMock verify], @"Target should have received action.");
#undef actionName
}

@end
