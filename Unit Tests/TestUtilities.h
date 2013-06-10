//
//  TestUtilities.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/26/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Subliminal/Subliminal.h>

/**
 Runs the specified tests and waits, without blocking, for them to finish.
 
 @param tests The SLTest classes to run.
 @param completionBlock The optional completion block to execute after testing finishes.
 */
extern void SLRunTestsAndWaitUntilFinished(NSSet *tests, void (^completionBlock)());


/**
 On load, this category sets an environment variable, SL_UNIT_TESTING, 
 that indicates that unit tests are running. Subliminal can check this variable
 to conditionalize code for the unit testing environment without 
 having to be built specially for the unit tests (e.g. using a build configuration):
 
    BOOL isUnitTesting = (getenv("SL_UNIT_TESTING") != NULL);

 */
@interface SLTestController (UnitTestingEnv)
@end


/**
 This category provides a way for the SLTestTests to tell SLTests
 to use their various macros, where it is not possible for the SLTestTests
 to use them directly because they make reference to SLTest members when expanded.
 */
@interface SLTest (SLTestTestsMacroHelpers)

- (void)slAssertFailAtFilename:(NSString *__autoreleasing*)filename lineNumber:(int *)lineNumber;
- (void)slAssertTrue:(BOOL (^)(void))condition;
- (void)slAssertFalse:(BOOL (^)(void))condition;
- (void)slAssertTrueWithUnsignedInteger:(NSUInteger (^)(void))expression;
- (void)SLAssertTrueWithTimeout:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout;
- (BOOL)SLWaitUntilTrue:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout;

- (void)slAssertThrows:(void (^)(void))expression;
- (void)slAssertThrows:(void (^)(void))expression named:(NSString *)exceptionName;
- (void)slAssertNoThrow:(void (^)(void))expression;

@end
