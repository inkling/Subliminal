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

@implementation TestWithNoTestCases
@end

@implementation TestNotSupportingCurrentPlatform

+ (BOOL)supportsCurrentPlatform {
    return NO;
}

- (void)testFoo {}

@end

@implementation TestWhichSupportsAllPlatforms
// no need to override +supportsCurrentPlatform
@end

@implementation TestWhichSupportsOnlyiPad_iPad
@end

@implementation TestWhichSupportsOnlyiPhone_iPhone
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

@implementation StartupTest

+ (BOOL)isStartUpTest {
    return YES;
}

@end
