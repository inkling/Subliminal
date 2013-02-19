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


@interface AbstractTest : SLTest
@end


@interface TestNotSupportingCurrentPlatform : SLTest

- (void)testFoo;

@end

@interface TestWhichSupportsAllPlatforms : SLTest

- (void)testFoo;

@end

@interface TestWhichSupportsOnlyiPad_iPad : SLTest

- (void)testFoo;

@end

@interface TestWhichSupportsOnlyiPhone_iPhone : SLTest

- (void)testFoo;

@end


@interface TestWithPlatformSpecificTestCases : SLTest

- (void)testFoo;
- (void)testBar_iPad;
- (void)testBaz_iPhone;
- (void)testCaseNotSupportingCurrentPlatform;

@end


@interface AbstractTestWhichSupportsOnly_iPad : SLTest
@end

@interface ConcreteTestWhichSupportsOnlyiPad : AbstractTestWhichSupportsOnly_iPad

- (void)testFoo;

@end


@interface StartupTest : SLTest

- (void)testFoo;

@end


@interface TestThatIsNotFocused : SLTest

- (void)testFoo;

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


@interface Focus_AbstractTestThatIsFocused : SLTest
@end

@interface ConcreteTestThatIsFocused : Focus_AbstractTestThatIsFocused

- (void)testFoo;

@end
