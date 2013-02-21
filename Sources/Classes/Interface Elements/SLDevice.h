//
//  SLDevice.h
//  Subliminal
//
//  Created by William Green on 11/30/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SLDevice : NSObject

+ (SLDevice *)currentDevice;

/**
 Renders the app inactive for the specified duration.

 This method will not return until the app reactivates.

 Note that the time spent inactive will actually be a few seconds longer than specified.
 UIAutomation reactivates the app using the app switcher, but lingers thereupon 
 for several seconds before actually tapping the app in the switcher.
 
 @param duration The time, in seconds, for the app to remain inactive 
 (subject to the caveat in the discussion).
 */
- (void)deactivateAppForDuration:(NSTimeInterval)duration;

@end
