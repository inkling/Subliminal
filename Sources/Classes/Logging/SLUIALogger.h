//
//  SLUIALogger.h
//  SubliminalTest
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
