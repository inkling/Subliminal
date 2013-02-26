//
//  SLTestController+Internal.h
//  Subliminal
//
//  Created by Jeffrey Wear on 2/19/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>

@interface SLTestController (Internal)

/**
 Given a set of tests, returns a new set filtered to those that should be run.
 
 The set of tests is filtered:
 
    1. to those that [are concrete](+[SLTest isAbstract]),
    2. that [support the current platform](+[SLTest supportsCurrentPlatform]),
    3. and that [are focused](+[SLTest isFocused]) (if any remaining are focused).
 
 @param tests The set of SLTest subclasses to process.
 @param withFocus If this is non-NULL, upon return, it will be set to YES
 if any of the tests [are focused](+[SLTest isFocused]), NO otherwise.
 @return A filtered set of tests to run.
 */
+ (NSSet *)testsToRun:(NSSet *)tests withFocus:(BOOL*)withFocus;

@end
