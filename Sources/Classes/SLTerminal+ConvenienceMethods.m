//
//  SLTerminal+ConvenienceMethods.m
//  Subliminal
//
//  Created by Jeffrey Wear on 4/9/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTerminal+ConvenienceMethods.h"

@implementation SLTerminal (ConvenienceMethods)

- (BOOL)waitUntilTrue:(NSString *)condition
           retryDelay:(NSTimeInterval)retryDelay
              timeout:(NSTimeInterval)timeout {
    NSString *retryFunction = [NSString stringWithFormat:@"\
                            (function () {\
                                var cond = function() { return (%@); };\
                                var retryDelay = %g;\
                                var timeout = %g;\
                                \
                                var startTime = (Date.now() / 1000);\
                                var condTrue = false;\
                                while (!(condTrue = cond()) && (((Date.now() / 1000) - startTime) < timeout)) {\
                                    UIATarget.localTarget().delay(retryDelay);\
                                };\
                                return condTrue;\
                            })()", condition, retryDelay, timeout];
    
    return [[self eval:retryFunction] boolValue];
}

@end
