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
#import "SLTerminal+ConvenienceFunctions.h"
#import "SLStringUtilities.h"

@interface SLElement (Subclassing)

/** Returns YES if the instance of SLElement should 'match' object, no otherwise.

 Subclasses of SLElement can override this method to provide custom matching behavior.
 The default implementation evaluates the object against the predicate
 with which the element was constructed (i.e. the argument to
 +elementMatching:withDescription:, or a predicate derived from the arguments 
 to higher-level constructor).
 
 If you override this method, you must call `super` in your implementation.

 @param object The object to which the instance of SLElement should be compared.
 @return a BOOL indicating whether or not the instance of SLElement matches object.
 */
- (BOOL)matchesObject:(NSObject *)object;

- (id)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);

- (void)performActionWithUIARepresentation:(void(^)(NSString *uiaRepresentation))block;
- (NSString *)staticUIARepresentation;

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

@end
