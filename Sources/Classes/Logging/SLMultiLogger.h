//
//  SLMultiLogger.h
//  Subliminal
//
//  Created by John Detloff on 1/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLLogger.h"

@interface SLMultiLogger : NSProxy <SLThreadSafeLogger>

- (id)init;
- (void)addLogger:(SLLogger *)newLogger;
- (void)removeLogger:(SLLogger *)oldLogger;

@end
