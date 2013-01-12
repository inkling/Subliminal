//
//  SharedSLTests.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>

/*
 All SLTests linked against the Unit Tests target should be defined here,
 for discoverability, as -[SLTestTests testAllTestsReturnsExpected] depends 
 on knowing what tests there are.
 
 If you add a new SLTest, please remember to update -[SLTestTests testAllTestsReturnsExpected].
 */

@interface TestWithSomeTestCases : SLTest

- (void)testOne;
- (void)testTwo;
- (void)testThree;
- (BOOL)testThatIsntATestBecauseItsReturnTypeIsNonVoid;
- (void)testThatIsntATestBecauseItTakesAnArgument:(NSString *)foo;

@end


@interface TestWithNoTestCases : SLTest
@end


@interface TestNotSupportingCurrentPlatform : SLTest

- (void)testFoo;

@end

@interface TestWhichSupportsAllPlatforms : SLTest
@end

@interface TestWhichSupportsOnlyiPad_iPad : SLTest
@end

@interface TestWhichSupportsOnlyiPhone_iPhone : SLTest
@end


@interface TestWithPlatformSpecificTestCases : SLTest

- (void)testFoo;
- (void)testBar_iPad;
- (void)testBaz_iPhone;
- (void)testCaseNotSupportingCurrentPlatform;

@end


@interface StartupTest : SLTest
@end


@interface TestThatIsNotFocused : SLTest
@end


@interface TestWithAFocusedTestCase : SLTest

- (void)testOne;
- (void)focus_testTwo;

@end


@interface TestWithSomeFocusedTestCases : SLTest

- (void)testOne;
- (void)focus_testTwo;
- (void)focus_testThree;

@end


@interface TestWithAFocusedPlatformSpecificTestCase : SLTest

- (void)testFoo;
- (void)focus_testBar_iPad;

@end


@interface Focus_TestThatIsFocused : SLTest

- (void)testOne;
- (void)focus_testTwo;

@end


@interface Focus_TestThatIsFocusedButDoesntSupportCurrentPlatform : SLTest

- (void)testOne;

@end
