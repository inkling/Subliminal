//
//  SharedTests.h
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

@interface EmptyTest : SLTest

@end

@interface TestNotSupportingCurrentPlatform : SLTest

@end