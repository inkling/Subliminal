//
//  SLTestController+Internal.h
//  Subliminal
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

#import <Subliminal/Subliminal.h>

/**
 The methods in the `SLTestController (Internal)` category are to be used only 
 within Subliminal.
 */
@interface SLTestController (Internal)

#pragma mark - Internal Methods
/// ----------------------------------------
/// @name Internal Methods
/// ----------------------------------------

/**
 Given a set of tests, returns a new set filtered to those that should be run.
 
 The set of tests is filtered:
 
 1. to those that [are concrete](+[SLTest isAbstract]),
 2. that [support the current platform](+[SLTest supportsCurrentPlatform]),
 3. and that [are focused](+[SLTest isFocused]) (if any remaining are focused).
 
 @param tests The set of `SLTest` subclasses to process.
 @param withFocus If this is non-`NULL`, upon return, it will be set to `YES`
 if any of the tests [are focused](+[SLTest isFocused]), `NO` otherwise.
 @return A filtered set of tests to run.
 */
+ (NSSet *)testsToRun:(NSSet *)tests withFocus:(BOOL*)withFocus;

@end
