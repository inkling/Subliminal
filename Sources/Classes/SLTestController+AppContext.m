//
//  SLTestController+AppContext.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTestController+AppContext.h"

#import <objc/runtime.h>
#import <objc/message.h>


@interface SLWeakRef : NSObject
@property (nonatomic, weak) id value;
@end

@implementation SLWeakRef
@end


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
    dispatch_async([self actionTargetMapQueue], ^{
        SLWeakRef *existingRef = [self actionTargetMap][mapKey];
        if (existingRef.value != target) {
            SLWeakRef *weakRef = [[SLWeakRef alloc] init];
            weakRef.value = target;
            [self actionTargetMap][mapKey] = weakRef;
        }
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
            if (((SLWeakRef *)obj).value == target) {
                [actionsForTarget addObject:key];
            }
        }];
        [[self actionTargetMap] removeObjectsForKeys:actionsForTarget];
    });
}

- (id)targetForAction:(SEL)action {
    __block id target;
    id mapKey = [[self class] actionTargetMapKeyForAction:action];
    dispatch_sync([self actionTargetMapQueue], ^{
        target = ((SLWeakRef *)[self actionTargetMap][mapKey]).value;
    });
    return target;
}

- (id<NSCopying>)sendAction:(SEL)action {
    NSAssert(![NSThread isMainThread], @"-sendAction: must not be called from the main thread.");

    id target = [self targetForAction:action];
    if (!target) {
        [NSException raise:SLAppActionTargetDoesNotExistException
                    format:@"No target is currently registered for action %@. \
                            (Either no target was ever registered, or a registered target has fallen out of scope.)",
                            NSStringFromSelector(action)];
    }

    // perform the action on the main thread, for thread safety
    __block id<NSCopying> returnValue;
    dispatch_sync(dispatch_get_main_queue(), ^{
        // use objc_msgSend so that Clang won't complain about performSelector leaks
        returnValue = ((id<NSCopying>(*)(id, SEL))objc_msgSend)(target, action);

        // return a copy, for thread safety
        returnValue = [returnValue copyWithZone:NULL];
    });

    return returnValue;
}

@end
