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

 Action messages must take either no arguments, or one id-type value conforming to NSCopying.
 Messages can return either nothing, or id-type values conforming to NSCopying.
 (Copying arguments and return values ensures thread safety, 
 and encourages communication between the tests and the application 
 using simple values like strings, numbers, etc., rather than application objects).

 Each action is performed on the main thread.
 The argument (if any) is copied, and the copy passed to the target.
 The return value (if any) is copied, and the copy passed to the calling SLTest.
 
 Only one target may be registered for any given action:
 if a second target is registered for a given action,
 the first target will be deregistered for that action.
 Registering the same target for the same action twice has no effect.

 The SLTestController keeps weak references to targets. It's still recommended 
 for targets to deregister themselves at appropriate times, though.

 @param target The object to which the action message will be sent by an SLTest.
 @param action The message which will be sent to the target by an SLTest.
               It must take either no arguments, or one id-type value conforming to NSCopying.
               It must return either nothing, or an id-type value conforming to NSCopying.
 
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
 Sends a specified action message to its registered target and returns the result of the message.

 This method must not be called from the main thread (it is intended to be called 
 by SLTests). 
 
 The message will be performed on the main thread.
 The returned value (if any) will be copied, and the copy passed to the calling SLTest.

 @param action The message to be performed.
 @return The result of the action, if any; otherwise nil.
 
 @throw SLAppActionTargetDoesNotExistException If no target is registered for action, 
 or if the target has fallen out of scope.
 */
- (id)sendAction:(SEL)action;

/**
 Sends a specified action message to its registered target with an object as the argument,
 and returns the result of the message.

 This method must not be called from the main thread (it is intended to be called
 by SLTests).

 The message will be performed on the main thread.
 The argument will be copied, and the copy passed to the target.
 The returned value (if any) will be copied, and the copy passed to the calling SLTest.

 @param action The message to be performed.
 @param object An object which is the sole argument of the action message.
 @return The result of the action, if any; otherwise nil.

 @throw SLAppActionTargetDoesNotExistException If no target is registered for action,
 or if the target has fallen out of scope.
 */
- (id)sendAction:(SEL)action withObject:(id<NSCopying>)object;

/**
 The SLAsk macro allows provides a more compact method for retrieving a bool 
 indicating some app state from an application hook
 
 @param selName The name of the app hook's action selector 
 */
#define SLAskApp(selName) [[[SLTestController sharedTestController] sendAction:@selector(selName)] boolValue]

/**
 The SLAsk macro allows provides a more compact method for retrieving a bool
 indicating some app state from an application hook
 
 @param selName The name of the app hook's action selector
 @param arg An argument to pass along with the app hook action
 */
#define SLAskApp1(selName, arg) [[[SLTestController sharedTestController] sendAction:@selector(selName) withObject:arg] boolValue]

@end
