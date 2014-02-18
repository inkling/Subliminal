//
//  SISLLogParserTests.m
//  subliminal-instrument
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2014 Inkling Systems, Inc.
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

#import <SLLogger/SLLogger.h>
#import <OCMock/OCMock.h>

#import "SILoggingTerminal.h"
#import "SISLLogParser.h"
#import "SISLLogEvents.h"

/// A sample ISO 8601-formatted timestamp,
/// as would be expected to be output by an instance of `SISLLogParser`.
static NSString *const kSampleTimestamp = @"2014-02-10T12:59:54-08:00";

/// The time interval corresponding to the above timestamp,
/// used to reconstitute the corresponding date.
static NSTimeInterval kSampleTimeInterval = 413758794.502608;

@interface SISLLogParserTests : SenTestCase <SISLLogParserDelegate>

@end

@implementation SISLLogParserTests {
    SISLLogParser *_parser;
    id _dateMock;
    SILoggingTerminal *_terminal;
    NSDictionary *_lastEvent;
}

- (void)setUp
{
    [super setUp];

    _parser = [[SISLLogParser alloc] init];
    _parser.delegate = self;

    // fix the current date so that we can guarantee the timestamp used by log messages
    NSDate *sampleDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kSampleTimeInterval];
    _dateMock = [OCMockObject partialMockForClassObject:[NSDate class]];
    [[[_dateMock stub] andReturn:sampleDate] date];

    _terminal = [SILoggingTerminal sharedTerminal];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageLogged:)
                                                 name:SILoggingTerminalMessageLoggedNotification
                                               object:_terminal];
    [_terminal beginMocking];
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_terminal stopMocking];
    _terminal = nil;

    [_dateMock stopMocking];
    _dateMock = nil;

    _parser = nil;

    [super tearDown];
}

#pragma mark - Event Handling

- (void)messageLogged:(NSNotification *)notification {
    NSString *message = [notification userInfo][SILoggingTerminalMessageUserInfoKey];
    [_parser parseStdoutLine:message];
}

- (void)parser:(SISLLogParser *)parser didParseEvent:(NSDictionary *)event {
    _lastEvent = event;
}

#pragma mark - Utility Methods

+ (NSDictionary *)eventWithType:(SISLLogEventType)type subtype:(SISLLogEventSubtype)subtype
                           info:(NSDictionary *)info message:(NSString *)message {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"timestamp": kSampleTimestamp,
        @"type": @(type),
        @"subtype": @(subtype)
    }];
    if (info) event[@"info"] = info;
    if (message) event[@"message"] = message;
    return [event copy];
}

// for "test status" events, we don't care what the message is, so long as there is one
- (BOOL)consumeMessage {
    NSMutableDictionary *mutableEvent = [_lastEvent mutableCopy];
    NSString *message = mutableEvent[@"message"];
    [mutableEvent removeObjectForKey:@"message"];
    _lastEvent = [mutableEvent copy];

    return ([message length] > 0);
}

#pragma mark - Tests

#pragma mark -Parsing Messages of Different Types

- (void)testCanParseDefaultMessage {
    NSString *message = @"hi!";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeDefault
                                                      subtype:SISLLogEventSubtypeNone
                                                         info:nil
                                                      message:message];
    [[SLLogger sharedLogger] logMessage:message];
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseDebugMessage {
    NSString *message = @"a bug!";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeDebug
                                                      subtype:SISLLogEventSubtypeNone
                                                         info:nil
                                                      message:message];
    [[SLLogger sharedLogger] logDebug:message];
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseErrorMessage {
    NSString *message = @"boo";

    NSMutableDictionary *expectedEvent = [[[self class] eventWithType:SISLLogEventTypeError
                                                              subtype:SISLLogEventSubtypeNone
                                                                 info:nil
                                                              message:message] mutableCopy];

    [_parser parseStderrLine:message];
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseWarningMessage {
    NSString *message = @"be careful!";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeWarning
                                                      subtype:SISLLogEventSubtypeNone
                                                         info:nil
                                                      message:message];
    [[SLLogger sharedLogger] logWarning:message];
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

#pragma mark -Parsing Test Status Messages

- (void)testCanParseTestErrorFromUnexpectedException {
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestError
                                                         info:nil message:nil];

    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:nil userInfo:nil];
    [[SLLogger sharedLogger] logException:exception expected:NO];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestErrorFromUncaughtException {
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestError
                                                         info:nil message:nil];

    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:nil userInfo:nil];
    [[SLLogger sharedLogger] logUncaughtException:exception];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestFailure {
    NSString *fileName = @(__FILE__);
    int lineNumber = __LINE__;

    NSDictionary *eventInfo = @{
        @"fileName": fileName,
        @"lineNumber": @(lineNumber)
    };
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                              subtype:SISLLogEventSubtypeTestFailure
                                                 info:eventInfo
                                              message:nil];

    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:nil
                                                   userInfo:@{
        SLLoggerExceptionFilenameKey: fileName,
        SLLoggerExceptionLineNumberKey: @(lineNumber)
    }];
    [[SLLogger sharedLogger] logException:exception expected:YES];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestingStarted {
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestingStarted
                                                         info:nil message:nil];

    [[SLLogger sharedLogger] logTestingStart];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestStarted {
    NSString *test = @"FooTest";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestStarted
                                                         info:@{ @"test": test }
                                                      message:nil];

    [[SLLogger sharedLogger] logTestStart:test];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestCaseStarted {
    NSString *test = @"FooTest";
    NSString *testCase = @"testFoo";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestCaseStarted
                                                         info:@{ @"testCase": testCase }
                                                      message:nil];

    [[SLLogger sharedLogger] logTest:test caseStart:testCase];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestCasePassed {
    NSString *test = @"FooTest";
    NSString *testCase = @"testFoo";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestCasePassed
                                                         info:@{ @"testCase": testCase }
                                                      message:nil];

    [[SLLogger sharedLogger] logTest:test casePass:testCase];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestCaseFailed {
    NSString *test = @"FooTest";
    NSString *testCase = @"testFoo";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestCaseFailed
                                                         info:@{ @"testCase": testCase }
                                                      message:nil];

    [[SLLogger sharedLogger] logTest:test caseFail:testCase expected:YES];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestCaseFailedUnexpectedly {
    NSString *test = @"FooTest";
    NSString *testCase = @"testFoo";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestCaseFailedUnexpectedly
                                                         info:@{ @"testCase": testCase }
                                                      message:nil];

    [[SLLogger sharedLogger] logTest:test caseFail:testCase expected:NO];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestFinished {
    NSString *test = @"FooTest";
    NSInteger numCasesExecuted = 7, numCasesFailed = 3, numCasesFailedUnexpectedly = 1;
    NSDictionary *expectedEventInfo = @{
        @"test": test,
        @"numCasesExecuted": @(numCasesExecuted),
        @"numCasesFailed": @(numCasesFailed),
        @"numCasesFailedUnexpectedly": @(numCasesFailedUnexpectedly)
    };
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestFinished
                                                         info:expectedEventInfo
                                                      message:nil];

    [[SLLogger sharedLogger] logTestFinish:test
                      withNumCasesExecuted:numCasesExecuted
                            numCasesFailed:numCasesFailed
                numCasesFailedUnexpectedly:numCasesFailedUnexpectedly];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestTerminatedAbnormally {
    NSString *test = @"FooTest";
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestTerminatedAbnormally
                                                         info:@{ @"test": test }
                                                      message:nil];

    [[SLLogger sharedLogger] logTestAbort:test];

    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

- (void)testCanParseTestingFinished {
    NSInteger numTestsExecuted = 7, numTestsFailed = 3;
    NSDictionary *expectedEventInfo = @{
                                        @"numTestsExecuted": @(numTestsExecuted),
                                        @"numTestsFailed": @(numTestsFailed)
                                        };
    NSDictionary *expectedEvent = [[self class] eventWithType:SISLLogEventTypeTestStatus
                                                      subtype:SISLLogEventSubtypeTestingFinished
                                                         info:expectedEventInfo
                                                      message:nil];

    [[SLLogger sharedLogger] logTestingFinishWithNumTestsExecuted:numTestsExecuted numTestsFailed:numTestsFailed];
    
    STAssertTrue([self consumeMessage], @"");
    STAssertEqualObjects(expectedEvent, _lastEvent, @"");
}

@end
