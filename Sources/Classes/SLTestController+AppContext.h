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

 Actions must take no arguments. Actions can return either nothing, or id-type values.

 Actions will be performed on the main thread; 
 any subsequent invocations on the objects returned by those actions 
 (and the call graph therefrom), will also be performed on the main thread.
 
 Only one target may be registered for any given action:
 if a second target is registered for a given action,
 the first target will be deregistered for that action.
 
 Registering the same target for the same action twice has no effect.

 @warning Targets are retained. They should thus deregister themselves when appropriate.

 @param target The object to which the action message will be sent by an SLTest.
 @param action The message which will be sent to the target by an SLTest.
               It must take no arguments. It must return either nothing, or an id-type value.
 
 @sa deregisterTarget:
 */
- (void)registerTarget:(id)target forAction:(SEL)action;

/**
 Deregisters the target for the specified actions.

 When the target has been deregistered for all actions, the target will be released.

 If target is not registered for the specified action, this method has no effect.

 @param target The object to be deregistered.
 @param action The action message for which the target should be deregistered.
 */
- (void)deregisterTarget:(id)target forAction:(SEL)action;

/**
 Deregisters the target for all actions.

 When the target has been deregistered for all actions, the target will be released.

 If target is not registered for any actions, this method has no effect.

 @param target The object to be deregistered.
 */
- (void)deregisterTarget:(id)target;

/**
 Causes an action message to be performed by a registered target.
 This method is to be used by the SLTests.

 Actions will be performed on the main thread;
 any subsequent invocation on the object returned by action
 (and the call graph therefrom), will also be performed on the main thread.
 Ownership semantics for the returned objects work as normal.
 This means that returned objects may be used as normal, without special regard 
 to memory or thread safety.

 @param action The message to be performed.
 @return The result of action, if any; otherwise nil.
 
 @throw SLAppActionTargetDoesNotExistException If no target is registered for action.
 */
- (id)sendAction:(SEL)action;

@end
