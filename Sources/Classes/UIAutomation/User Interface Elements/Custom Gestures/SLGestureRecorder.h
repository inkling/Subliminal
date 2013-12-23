//
//  SLGestureRecorder.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLGesture;
@protocol SLGestureRecorderDelegate;

@interface SLGestureRecorder : NSObject

/// may not be set while recording; must be set on the main thread
@property (nonatomic) CGRect rect;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, weak) id<SLGestureRecorderDelegate> delegate;

- (instancetype)initWithRect:(CGRect)rect;

@end


@protocol SLGestureRecorderDelegate <NSObject>

- (BOOL)gestureRecorder:(SLGestureRecorder *)recorder shouldReceiveTouch:(UITouch *)touch;

@required

- (void)gestureRecorder:(SLGestureRecorder *)recorder didRecordGesture:(SLGesture *)gesture;

@end
