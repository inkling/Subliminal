//
//  SLUIAElement+Subclassing.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLUIAElement.h"
#import "SLElement.h"
#import "SLLogger.h"
#import "SLTerminal.h"
#import "SLTerminal+ConvenienceFunctions.h"
#import "SLStringUtilities.h"

@interface SLUIAElement (Subclassing)

- (id)waitUntilTappable:(BOOL)waitUntilTappable
        thenSendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(2, 3);

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void(^)(NSString *UIARepresentation))block
                                       timeout:(NSTimeInterval)timeout;

+ (NSString *)SLElementIsTappableFunctionName;

@end


/**
 The methods in the `SLElement (Subclassing)` category are to be called or
 overridden by subclasses of `SLElement`. Tests should not call these methods.
 */
@interface SLElement (Subclassing)

/**
 Determines if the specified element matches the specified object.

 Subclasses of `SLElement` can override this method to provide custom matching behavior.
 The default implementation evaluates the object against the predicate
 with which the element was constructed (i.e. the argument to
 `+elementMatching:withDescription:`, or a predicate derived from the arguments 
 to a higher-level constructor).
 
 If you override this method, you must call `super` in your implementation.

 @param object The object to which the instance of `SLElement` should be compared.
 @return `YES` if the specified element matches `object`, `NO` otherwise.
 */
- (BOOL)matchesObject:(NSObject *)object;

/**
 Allows the caller to interact with the actual object matched by the receiving SLElement.

 The block will be executed synchronously on the main thread.

 This method should be used only when UIAutomation offers no API providing 
 equivalent functionality: as a user interface element, the object should be 
 manipulated by the simulated user for the tests to be most accurate.

 @param block A block which takes the matching object as an argument and returns 
 `void`.
 
 @exception SLUIAElementInvalidException Raised if the element has not matched 
 an object by the end of the [default timeout](+defaultTimeout).
 */
- (void)examineMatchingObject:(void (^)(NSObject *object))block;

@end
