//
//  SLDevice.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 The singleton `SLDevice` instance allows you to access and manipulate
 the device on which your application is running.
 */
@interface SLDevice : NSObject

/**
 Returns an object representing the current device.
 
 @return A singleton object that represents the current device.
 */
+ (SLDevice *)currentDevice;

/**
 Deactivates your application for the specified duration.
 
 By pushing the Home button, waiting for the specified duration, 
 and then using the app switcher to reactivate the application.
 
 This method will not return until the app reactivates.

 Note that the time spent inactive will actually be a few seconds longer than specified.
 UIAutomation lingers upon the app switcher for several seconds before actually 
 tapping the app.
 
 @param duration The time, in seconds, for the app to remain inactive 
 (subject to the caveat in the discussion).
 */
- (void)deactivateAppForDuration:(NSTimeInterval)duration;

/** 
 Changes the device orientation to the specified new `deviceOrientation` value.
 
 You can access the current device orientation using `[[UIDevice currentDevice] orientation]`
 
 @param deviceOrientation The device orientation to rotate to.
 */
- (void)setOrientation:(UIDeviceOrientation)deviceOrientation;

@end
