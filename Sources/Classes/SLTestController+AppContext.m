//
//  SLTestController+AppContext.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTestController+AppContext.h"
#import "SLAppProxy.h"

#import <objc/runtime.h>

NSString *const SLAppActionTargetDoesNotExistException = @"SLAppActionTargetDoesNotExistException";

@implementation SLTestController (AppContext)

+ (id)actionTargetMapKeyForAction:(SEL)action {
    return NSStringFromSelector(action);
}

// even though the SLTestController is a singleton,
// these really should be instance variables rather than statics
- (NSMutableDictionary *)actionTargetMap {
    static const void *const kActionTargetMapKey = &kActionTargetMapKey;
    NSMutableDictionary *actionTargetMap = objc_getAssociatedObject(self, kActionTargetMapKey);
    if (!actionTargetMap) {
        // actionTargetMap initialization must be thread-safe
        // but we only take the lock if we need to
        @synchronized(self) {
            // check again to make sure that the map is nil
            // (in case we're a second thread that got inside the if above)
            actionTargetMap = objc_getAssociatedObject(self, kActionTargetMapKey);
            if (!actionTargetMap) {
                actionTargetMap = [[NSMutableDictionary alloc] init];
                objc_setAssociatedObject(self, kActionTargetMapKey, actionTargetMap, OBJC_ASSOCIATION_RETAIN);
            }
        }
    }
    return actionTargetMap;
}

- (dispatch_queue_t)actionTargetMapQueue {
    static const void *const kActionTargetMapQueueKey = &kActionTargetMapQueueKey;
    NSValue *actionTargetMapQueueValue = objc_getAssociatedObject(self, kActionTargetMapQueueKey);
    if (!actionTargetMapQueueValue) {
        // actionTargetMapQueue initialization must be thread-safe
        // but we only take the lock if we need to
        @synchronized(self) {
            // check again to make sure that the queue is nil
            // (in case we're a second thread that got inside the if above)
            actionTargetMapQueueValue = objc_getAssociatedObject(self, kActionTargetMapQueueKey);
            if (!actionTargetMapQueueValue) {
                NSString *queueName = [NSString stringWithFormat:@"com.subliminal.SLTestController+AppContext-%p.actionTargetMapQueue", self];
                dispatch_queue_t actionTargetMapQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
                actionTargetMapQueueValue = [NSValue value:&actionTargetMapQueue withObjCType:@encode(typeof(actionTargetMapQueue))];
                objc_setAssociatedObject(self, kActionTargetMapQueueKey, actionTargetMapQueueValue, OBJC_ASSOCIATION_RETAIN);
            }
        }
    }
    dispatch_queue_t actionTargetMapQueue;
    [actionTargetMapQueueValue getValue:&actionTargetMapQueue];
    return actionTargetMapQueue;
}

- (void)registerTarget:(id)target forAction:(SEL)action {
    // assert that action is of the proper format
    NSString *actionString = NSStringFromSelector(action);
    NSAssert(![actionString hasSuffix:@":"], @"The action must identify a method which takes no arguments.");

    // sanity check
    NSAssert([target respondsToSelector:action], @"Target %@ does not respond to action: %@", target, NSStringFromSelector(action));

    id mapKey = [[self class] actionTargetMapKeyForAction:action];

    // storing the targets as SLAppProxy's allows us to ensure:
    // 1. that we can safely send the action across threads, below
    // 2. that the action's return value (and values therefrom derived) can be safely used across threads
    id targetProxy = [SLAppProxy proxyForObject:target];
    dispatch_async([self actionTargetMapQueue], ^{
        [self actionTargetMap][mapKey] = targetProxy;
    });
}

- (void)deregisterTarget:(id)target forAction:(SEL)action {
    id mapKey = [[self class] actionTargetMapKeyForAction:action];
    dispatch_async([self actionTargetMapQueue], ^{
        [self actionTargetMap][mapKey] = nil;
    });
}

- (void)deregisterTarget:(id)target {
    dispatch_async([self actionTargetMapQueue], ^{
        // first pass to find the objects
        NSMutableArray *actionsForTarget = [NSMutableArray array];
        [[self actionTargetMap] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            // must use isEqual: because the dictionary objects are proxies, not the targets themselves
            if ([obj isEqual:target]) {
                [actionsForTarget addObject:key];
            }
        }];
        [[self actionTargetMap] removeObjectsForKeys:actionsForTarget];
    });
}

- (id)targetForAction:(SEL)action {
    __block id targetProxy;
    id mapKey = [[self class] actionTargetMapKeyForAction:action];
    dispatch_sync([self actionTargetMapQueue], ^{
        targetProxy = [self actionTargetMap][mapKey];
    });
    return targetProxy;
}

- (id)sendAction:(SEL)action {
    id targetProxy = [self targetForAction:action];
    if (!targetProxy) {
        [NSException raise:SLAppActionTargetDoesNotExistException format:@"No target has been registered for action %@.", NSStringFromSelector(action)];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [targetProxy performSelector:action];
#pragma clang diagnostic pop
}

@end
