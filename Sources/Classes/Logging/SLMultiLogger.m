//
//  SLMultiLogger.m
//  Subliminal
//
//  Created by John Detloff on 1/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLMultiLogger.h"
#import <Subliminal.h>


@implementation SLMultiLogger {
    NSMutableSet *_loggers;
}


- (id)init {
    _loggers = [[NSMutableSet alloc] init];
    
    return self;
}


- (void)addLogger:(SLLogger *)newLogger {
    [_loggers addObject:newLogger];
}


- (void)removeLogger:(SLLogger *)oldLogger {
    [_loggers removeObject:oldLogger];
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    for (SLLogger *logger in _loggers) {
        if ([logger respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    for (SLLogger *logger in _loggers) {
        if ([logger respondsToSelector:selector]) {
            // if *any* delegate responds to this selector, return a valid method signature
            return [[logger class] instanceMethodSignatureForSelector:selector];
        }
    }
    return nil;
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    for (SLLogger *logger in _loggers) {
        if ([logger respondsToSelector:[invocation selector]]) {
            [invocation invokeWithTarget:logger];
        }
    }
}


@end
