//
//  SLGesture+Recording.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGesture+Recording.h"

@implementation SLTouchState (Recording)

+ (instancetype)stateAtTime:(NSTimeInterval)time withUITouches:(NSSet *)touches rect:(CGRect)rect {
    NSMutableSet *slTouches = [[NSMutableSet alloc] initWithCapacity:[touches count]];
    for (UITouch *touch in touches) {
        [slTouches addObject:[SLTouch touchWithUITouch:touch rect:rect]];
    }
    return [self stateAtTime:time withTouches:slTouches];
}

@end

@implementation SLTouch (Recording)

+ (instancetype)touchWithUITouch:(UITouch *)touch rect:(CGRect)rect {
    CGPoint locationInWindow = [touch locationInView:nil];
    CGPoint locationInScreen = [touch.window convertPoint:locationInWindow toWindow:nil];
    return [self touchAtPoint:locationInScreen inRect:rect];
}

@end
