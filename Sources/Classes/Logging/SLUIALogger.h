//
//  SLUIALogger.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/9/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLLogger.h"

/**
 SLUIALogger logs messages to the Automation instrument.
 
 SLUIALogger is the standard logger for Subliminal. Its output can be viewed in 
 Instruments when the tests are running locally. If SLUIALogger is used 
 when tests are running from the command line using the `instruments ` tool 
 (e.g. in a continuous integration setup), `instruments` will produce a `.trace` 
 file that can be opened in the Instruments application after the tests have 
 concluded.
 
 When [errors](-logError:) or [warnings](-logWarning:) are logged, 
 the SLUIALogger will direct the Automation instrument to take a screenshot 
 of the application. Those screenshots can be viewed in Instruments along 
 log messages when the tests are running locally or by opening the `.trace` 
 file produced by a run of the `instruments` command-line tool. The `instruments` 
 command-line tool will also save such screenshots to a directory specified 
 as part of the tool's invocation.
 */
@interface SLUIALogger : SLLogger

@end
