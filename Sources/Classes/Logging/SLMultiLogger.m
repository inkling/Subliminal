//
//  SLMultiLogger.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SLMultiLogger.h"

@implementation SLMultiLogger {
    NSMutableSet *_loggers;
    dispatch_queue_t _loggingQueue;
}

- (id)init {
    // There is no -[super init], because we are a proxy
    _loggers = [[NSMutableSet alloc] init];
    _loggingQueue = dispatch_queue_create("com.inkling.subliminal.SLMultiLogger.loggingQueue", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (void)dealloc {
    dispatch_release(_loggingQueue);
}

- (dispatch_queue_t)loggingQueue {
    return _loggingQueue;
}

- (void)addLogger:(SLLogger *)logger {
    [_loggers addObject:logger];
}

- (void)removeLogger:(SLLogger *)logger {
    [_loggers removeObject:logger];
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
