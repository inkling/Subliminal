//
//  SLTerminal+ConvenienceMethods.h
//  Subliminal
//
//  Created by Jeffrey Wear on 4/9/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>

@interface SLTerminal (ConvenienceMethods)

/**
 Waits for an arbitrary Javascript expression to evaluate to true
 within a specified timeout.

 The expression will be re-evaluated at small intervals.
 If and when the expression evaluates to true, the method will immediately return
 YES; if the expression is still false at the end of the timeout, this method
 will return NO.

 This method is designed to wait efficiently by performing the waiting/re-evaluation
 entirely within UIAutomation's (Javascript) context.

 @warning This method does not itself throw an exception if the condition fails
 to become true within the timeout. Rather, the caller should throw a suitably
 specific exception if this method returns NO.

 @param condition A boolean expression in Javascript, on whose truth the method should wait.
 @param retryDelay The interval at which to re-evaluate condition.
 @param timeout The interval for which to wait.
 @return YES if and when the expression evaluates to true within the timeout;
 otherwise, NO.
 */
- (BOOL)waitUntilTrue:(NSString *)condition
           retryDelay:(NSTimeInterval)retryDelay
              timeout:(NSTimeInterval)timeout;

@end
