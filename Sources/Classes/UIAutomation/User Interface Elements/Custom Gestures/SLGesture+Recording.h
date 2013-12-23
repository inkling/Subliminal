//
//  SLGesture+Recording.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGesture.h"

#import <UIKit/UIKit.h>

@interface SLTouchState (Recording)

+ (instancetype)stateAtTime:(NSTimeInterval)time withUITouches:(NSSet *)touches rect:(CGRect)rect;

@end

@interface SLTouch (Recording)

+ (instancetype)touchWithUITouch:(UITouch *)touch rect:(CGRect)rect;

@end

