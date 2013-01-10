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

@implementation TestNotSupportingCurrentPlatform

+ (BOOL)supportsCurrentPlatform {
    return NO;
}

@end

@implementation TestWithPlatformSpecificTestCases

- (void)testFoo {}
- (void)testBar_iPad {}
- (void)testBaz_iPhone {}

@end

@implementation StartupTest

+ (BOOL)isStartUpTest {
    return YES;
}

@end
