//
//  SLDevice.m
//  Subliminal
//
//  Created by William Green on 11/30/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLDevice.h"

#import "SLTerminal.h"


@implementation SLDevice

+ (SLDevice *)currentDevice {
    static SLDevice *device;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = [[SLDevice alloc] init];
    });
    return device;
}

- (void)deactivateAppForDuration:(NSTimeInterval)duration {
    [[SLTerminal sharedTerminal] evalWithFormat:@"UIATarget.localTarget().deactivateAppForDuration(%g)", duration];
}

@end
