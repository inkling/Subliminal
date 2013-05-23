//
//  SLDevice.h
//  Subliminal
//
//  Created by William Green on 11/30/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


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

@end
