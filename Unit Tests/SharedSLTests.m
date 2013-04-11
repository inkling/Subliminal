//
//  SharedSLTests.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SharedSLTests.h"

@implementation TestWithSomeTestCases

- (void)testOne{}
- (void)testTwo{}
- (void)testThree{}
- (BOOL)testThatIsntATestBecauseItsReturnTypeIsNonVoid{return NO;}
- (void)testThatIsntATestBecauseItTakesAnArgument:(NSString *)foo{}

@end


@implementation AbstractTest
@end


@implementation TestNotSupportingCurrentPlatform

+ (BOOL)supportsCurrentPlatform {
    return NO;
}

- (void)testFoo {}

@end

@implementation TestWhichSupportsAllPlatforms
// no need to override +supportsCurrentPlatform

- (void)testFoo {}

@end

@implementation TestWhichSupportsOnlyiPad_iPad

- (void)testFoo {}

@end

@implementation TestWhichSupportsOnlyiPhone_iPhone

- (void)testFoo {}

@end


@implementation TestWithPlatformSpecificTestCases

+ (BOOL)testCaseWithSelectorSupportsCurrentPlatform:(SEL)testCaseSelector {
    BOOL testCaseSupportsCurrentDevice = [super testCaseWithSelectorSupportsCurrentPlatform:testCaseSelector];
    return (testCaseSupportsCurrentDevice &&
            (testCaseSelector != @selector(testCaseNotSupportingCurrentPlatform)));
}

- (void)testFoo {}
- (void)testBar_iPad {}
- (void)testBaz_iPhone {}
- (void)testCaseNotSupportingCurrentPlatform {}

@end


@implementation AbstractTestWhichSupportsOnly_iPad
@end

@implementation ConcreteTestWhichSupportsOnlyiPad

- (void)testFoo {}

@end


@implementation TestThatIsNotFocused

- (void)testFoo {}

@end


@implementation TestWithAFocusedTestCase

- (void)testOne {}
- (void)focus_testTwo {}

@end


@implementation TestWithSomeFocusedTestCases

- (void)testOne {}
- (void)focus_testTwo {}
- (void)focus_testThree {}

@end


@implementation TestWithAFocusedPlatformSpecificTestCase

- (void)testFoo {}
- (void)focus_testBar_iPad {}

@end


@implementation Focus_TestThatIsFocused

- (void)testFoo {}

@end


@implementation Focus_TestWhereNarrowestFocusApplies

- (void)testOne {}
- (void)focus_testTwo {}

@end


@implementation Focus_TestThatIsFocusedButDoesntSupportCurrentPlatform

+ (BOOL)supportsCurrentPlatform {
    return NO;
}

- (void)testOne {}

@end


@implementation Focus_AbstractTestThatIsFocused
@end

@implementation ConcreteTestThatIsFocused

- (void)testFoo {}

@end
