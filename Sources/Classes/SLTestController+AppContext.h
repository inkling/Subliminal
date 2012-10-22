//
//  SLTestController+AppContext.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Subliminal/Subliminal.h>

extern NSString *const SLAppActionTargetDoesNotExistException;

@interface SLTestController (AppContext)

/**
 Allows application objects to register themselves as being able to perform arbitrary actions. 
 This allows SLTests to access and manipulate application state 
 while executing asynchronously.

 Actions must take no arguments. 
 Actions can return either nothing, or id-type values conforming to NSCopying.
 (Copying return values ensures thread safety, and encourages actions to return 
 simple values like strings, numbers, etc. into the testing context, rather than
 application objects).

 Actions will be performed on the main thread.
 Return values (if any) will be copied and the copy passed to the calling SLTest.
 
 Only one target may be registered for any given action:
 if a second target is registered for a given action,
 the first target will be deregistered for that action.
 Registering the same target for the same action twice has no effect.

 The SLTestController keeps weak references to targets. It's still recommended 
 for targets to deregister themselves at appropriate times, though.

 @param target The object to which the action message will be sent by an SLTest.
 @param action The message which will be sent to the target by an SLTest.
               It must take no arguments. It must return either nothing, or an id-type value
               conforming to NSCopying.
 
 @sa deregisterTarget:
 */
- (void)registerTarget:(id)target forAction:(SEL)action;

/**
 Deregisters the target for the specified actions.

 If target is not registered for the specified action, this method has no effect.

 @param target The object to be deregistered.
 @param action The action message for which the target should be deregistered.
 */
- (void)deregisterTarget:(id)target forAction:(SEL)action;

/**
 Deregisters the target for all actions.

 If target is not registered for any actions, this method has no effect.

 @param target The object to be deregistered.
 */
- (void)deregisterTarget:(id)target;

/**
 Causes an action message to be performed by a registered target.

 This method must not be called from the main thread (it is intended to be called 
 by SLTests). 
 
 The action will be performed on the main thread.
 The returned value will be copied and the copy passed to the calling SLTest.

 @param action The message to be performed.
 @return The result of action, if any; otherwise nil.
 
 @throw SLAppActionTargetDoesNotExistException If no target is registered for action, 
 or if the target has fallen out of scope.
 */
- (id<NSCopying>)sendAction:(SEL)action;

@end
