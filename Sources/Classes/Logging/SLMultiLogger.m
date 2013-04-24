//
//  SLMultiLogger.m
//  Subliminal
//
//  Created by John Detloff on 1/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLMultiLogger.h"

@implementation SLMultiLogger {
    NSMutableSet *_loggers;
    dispatch_queue_t _loggingQueue;
}

- (id)init {
    _loggers = [[NSMutableSet alloc] init];
    _loggingQueue = dispatch_queue_create("com.subliminal.SLMultiLogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (void)dealloc {
    dispatch_release(_loggingQueue);
}

- (dispatch_queue_t)loggingQueue {
    return _loggingQueue;
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
    if (dispatch_get_current_queue() != _loggingQueue) {
        dispatch_sync(_loggingQueue, ^{
            [self forwardInvocation:invocation];
        });
        return;
    }

    for (SLLogger *logger in _loggers) {
        if ([logger respondsToSelector:[invocation selector]]) {
            [invocation invokeWithTarget:logger];
        }
    }
}

@end
