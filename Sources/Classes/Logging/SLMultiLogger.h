//
//  SLMultiLogger.h
//  Subliminal
//
//  Created by John Detloff on 1/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLLogger.h"

/**
 SLMultiLogger is effectively a concrete subclass of SLLogger 
 that logs messages to one or more other "target" loggers.
 
 It is especially useful when using Subliminal with continuous integration, 
 so that Subliminal can log messages to the CI test runner and to the Automation 
 instrument. That way, if a failure occurs, the artifacts of the Automation instrument 
 --a `.trace` file that can be opened in Instruments, as well as the screenshots 
 that the instrument takes on warnings/errors--will be available for examination.
 
 To do this, you would configure Subliminal as following, in your application 
 delegate's implementation of -application:didFinishLaunchingWithOptions:
 
    SLMultiLogger *multiLogger = [[SLMultiLogger alloc] init];
 
    // Log to the Automation instrument
    SLUIALogger *uiaLogger = [[SLUIALogger alloc] init];
    [multiLogger addLogger:uiaLogger];
 
    // Log to the CI runner
    SLLogger *ciLogger = // some logger that logs to e.g. a file
    [multiLogger addLogger:ciLogger];
 
    [SLLogger setSharedLogger:(SLLogger *)multiLogger];

 */
@interface SLMultiLogger : NSProxy

/**
 Initializes and returns a newly allocated multi logger.
 
 This is the designated initializer for instances of SLMultiLogger.
 
 @return An initialized multi logger.
 */
- (id)init;

/**
 Adds a logger to the receiver's target loggers.
 
 After a logger has been added, it will begin receiving log messages 
 directed to the multi logger.

 @param logger The logger to add to the receiver's targets.
 */
- (void)addLogger:(SLLogger *)logger;

/**
 Removes the specified logger from the receiver's targets.
 
 After a logger has been removed, it will no longer receive log messages 
 directed to the multi logger.

 If `logger` is not one of the receiver's targets, this method has no effect 
 (though it does incur the overhead of searching the receiver's targets).
 
 @param logger The logger to remove from the receiver's targets.
 */
- (void)removeLogger:(SLLogger *)logger;

@end
