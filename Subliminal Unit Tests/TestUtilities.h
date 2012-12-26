//
//  TestUtilities.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/26/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Runs the specified tests and waits, without blocking, for them to finish.
 
 @param tests The SLTest classes to run.
 @param completionBlock The optional completion block to execute after testing finishes.
 */
extern void SLRunTestsAndWaitUntilFinished(NSSet *tests, void (^completionBlock)());
