//
//  SLGestureRecordingSession.h
//  Subliminal
//
//  Created by Jeffrey Wear on 11/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SLGesture, SLUIAElement;
@interface SLGestureRecordingSession : NSObject

+ (SLGesture *)recordGestureWithElement:(SLUIAElement *)element;

- (instancetype)initWithElement:(SLUIAElement *)element;

- (SLGesture *)record;

@end
