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


static const NSTimeInterval kTargetLookupTimeout = 5.0;
static const NSTimeInterval kTargetLookupRetryDelay = 0.25;
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
    // sanity check
    NSAssert([target respondsToSelector:action], @"Target %@ does not respond to action: %@", target, NSStringFromSelector(action));

    // assert that action is of the proper format
    // we can't actually enforce that id-type arguments/return values conform to NSCopying, but oh well
    NSMethodSignature *actionSignature = [target methodSignatureForSelector:action];

    const char *actionReturnType = [actionSignature methodReturnType];
    NSAssert(strcmp(actionReturnType, @encode(void)) == 0 ||
             strcmp(actionReturnType, @encode(id<NSCopying>)) == 0, @"The action must return a value of either type void or id<NSCopying>.");

    NSUInteger numberOfArguments = [actionSignature numberOfArguments];
    // note that there are always at least two arguments, for self and _cmd
    NSAssert(numberOfArguments < 4, @"The action must identify a method which takes zero or one argument.");
    if (numberOfArguments == 3) {
        NSAssert(strcmp([actionSignature getArgumentTypeAtIndex:2], @encode(id<NSCopying>)) == 0,
                 @"If the action takes an argument, that argument must be of type id<NSCopying>.");
    }

    // register target
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
        [[self actionTargetMap] removeObjectForKey:mapKey];
    });
}

- (void)deregisterTarget:(id)target {
    // take care not to retain the target in the block
    // (this method may be called from the target's dealloc,
    // and our reference cannot at that point keep it alive,
    // but the release of that reference at block's close will cause a segfault)
    id __unsafe_unretained blockTarget = target;
    dispatch_async([self actionTargetMapQueue], ^{
        // first pass to find the objects
        NSMutableArray *actionsForTarget = [NSMutableArray array];
        [[self actionTargetMap] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (((SLWeakRef *)obj).value == blockTarget) {
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

// The target lookup timeout is factored as a method
// so that the SLTestController+AppContext tests can provide different values
// for different tests (using OCMock). It is not considered necessary or useful
// to expose it publicly for other purposes.
// Don't change the name of this method without updating the tests.
- (NSTimeInterval)targetLookupTimeout {
    return kTargetLookupTimeout;
}

- (id)sendAction:(SEL)action {
    NSAssert(![NSThread isMainThread], @"-sendAction: must not be called from the main thread.");

    __block id returnValue;
    // An autoreleasepool is used here to explicitely ensure that the target is not retained beyond
    // the message send
    @autoreleasepool {
        id target = nil;
        // wait for a target to be registered, if necessary
        NSDate *startDate = [NSDate date];
        do {
            if ((target = [self targetForAction:action])) break;
            [NSThread sleepForTimeInterval:kTargetLookupRetryDelay];
        } while ([[NSDate date] timeIntervalSinceDate:startDate] <= [self targetLookupTimeout]);
        if (!target) {
            [NSException raise:SLAppActionTargetDoesNotExistException
                        format:@"No target is currently registered for action %@. \
             (Either no target was ever registered, or a registered target has fallen out of scope.)",
             NSStringFromSelector(action)];
        }

        // perform the action on the main thread, for thread safety
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMethodSignature *actionSignature = [target methodSignatureForSelector:action];
            const char *actionReturnType = [actionSignature methodReturnType];
            if (strcmp(actionReturnType, @encode(void)) != 0) {
                // use objc_msgSend so that Clang won't complain about performSelector leaks
                returnValue = ((id(*)(id, SEL))objc_msgSend)(target, action);
            } else {
                ((void(*)(id, SEL))objc_msgSend)(target, action);
                returnValue = nil;
            }

            // return a copy, for thread safety
            // note: if actions return an object, that object is required to conform to NSCopying (see header)
            // no way for us to enforce that at compile-time, though
            returnValue = [returnValue copyWithZone:NULL];
        });
    }
    
    return returnValue;
}

- (id)sendAction:(SEL)action withObject:(id<NSCopying>)object {
    NSAssert(![NSThread isMainThread], @"-sendAction:withObject: must not be called from the main thread.");

    __block id returnValue;
    // An autoreleasepool is used here to explicitely ensure that the target is not retained beyond
    // the message send
    @autoreleasepool {
        id target = nil;
        // wait for a target to be registered, if necessary
        NSDate *startDate = [NSDate date];
        do {
            if ((target = [self targetForAction:action])) break;
            [NSThread sleepForTimeInterval:kTargetLookupRetryDelay];
        } while ([[NSDate date] timeIntervalSinceDate:startDate] <= [self targetLookupTimeout]);
        if (!target) {
            [NSException raise:SLAppActionTargetDoesNotExistException
                        format:@"No target is currently registered for action %@. \
             (Either no target was ever registered, or a registered target has fallen out of scope.)",
             NSStringFromSelector(action)];
        }

        // pass a copy of the argument, for thread safety
        id arg = [object copyWithZone:NULL];

        // perform the action on the main thread, for thread safety
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMethodSignature *actionSignature = [target methodSignatureForSelector:action];
            const char *actionReturnType = [actionSignature methodReturnType];
            if (strcmp(actionReturnType, @encode(void)) != 0) {
                // use objc_msgSend so that Clang won't complain about performSelector leaks
                returnValue = ((id(*)(id, SEL, id))objc_msgSend)(target, action, arg);
            } else {
                ((void(*)(id, SEL, id))objc_msgSend)(target, action, arg);
                returnValue = nil;
            }

            // return a copy, for thread safety
            // note: if actions return an object, that object is required to conform to NSCopying (see header)
            // no way for us to enforce that at compile-time, though
            returnValue = [returnValue copyWithZone:NULL];
        });
    }
    return returnValue;
}

@end
