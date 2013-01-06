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

@interface TestNotSupportingCurrentPlatform : SLTest
@end

@interface TestWithPlatformSpecificTestCases : SLTest

- (void)testFoo;
- (void)testBar_iPad;
- (void)testBaz_iPhone;

@end

@interface StartupTest : SLTest
@end
