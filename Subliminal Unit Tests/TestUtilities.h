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
 This category provides a way for the SLTestTests to tell SLTests 
 to use their various macros, where it is not possible for the SLTestTests
 to use them directly because they make reference to SLTest members when expanded.
 */
@interface SLTest (SLTestTestsMacroHelpers)

- (void)slAssertFailAtFilename:(NSString *__autoreleasing*)filename lineNumber:(int *)lineNumber;
- (void)slAssertTrue:(BOOL (^)(void))condition;
- (void)slAssertFalse:(BOOL (^)(void))condition;
- (void)slWaitOnCondition:(BOOL (^)(void))condition withTimeout:(NSTimeInterval)timeout;

@end
