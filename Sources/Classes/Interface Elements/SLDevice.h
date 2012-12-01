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

- (void)lockForDuration:(NSTimeInterval)duration;

@end
