//
//  SLElement+Subclassing.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"
#import "SLLogger.h"
#import "SLTerminal.h"
#import "NSString+SLJavaScript.h"

@interface SLElement (Subclassing)

/** Returns YES if the instance of SLElement should 'match' object, no otherwise.

 Subclasses of SLElement can override this method to provide custom matching behavior.
 The default implementation evaluates the object against the predicate
 with which the element was constructed (i.e. the argument to
 +elementMatching:withDescription:, or a predicate derived from the arguments 
 to higher-level constructor).

 @param object The object to which the instance of SLElement should be compared.
 @return a BOOL indicating whether or not the instance of SLElement matches object.
 */
- (BOOL)matchesObject:(NSObject *)object;

- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);

- (void)performActionWithUIASelf:(void(^)(NSString *uiaSelf))block;
- (NSString *)staticUIASelf;

/**
 Allows the caller to interact with the actual object matched by the receiving SLElement.

 If a matching object cannot be found, the search will be retried
 until the defaultTimeout expires.

 The block will be executed synchronously on the main thread.

 @param block A block which takes the matching object as an argument and returns void.
 @exception SLElementInvalidException If no matching object has been found
 after the defaultTimeout has elapsed.
 */
- (void)examineMatchingObject:(void (^)(NSObject *object))block;

/**
 Waits for an arbitrary Javascript expression to evaluate to true
 within a specified timeout.

 The expression will be re-evaluated at small intervals.
 If and when the expression evaluates to true, the method will immediately return
 YES; if the expression is still false at the end of the timeout, this method
 will return NO.

 This method is designed to wait efficiently by performing the waiting/re-evaluation
 entirely within UIAutomation's (Javascript) context.

 @warning This method does not itself throw an exception if the condition fails
 to become true within the timeout. Rather, the caller should throw a suitably
 specific exception if this method returns NO.

 @param timeout The interval for which to wait.
 @param expr A boolean expression in Javascript, on whose truth the method should wait.
 @return YES if and when the expression evaluates to true within the timeout;
 otherwise, NO.
 */
- (BOOL)waitFor:(NSTimeInterval)timeout untilTrue:(NSString *)condition;

@end
