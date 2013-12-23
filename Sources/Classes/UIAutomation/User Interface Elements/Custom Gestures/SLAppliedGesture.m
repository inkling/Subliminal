//
//  SLAppliedGesture.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLAppliedGesture.h"

#import "SLGesture.h"

@implementation SLAppliedGesture {
    NSMutableArray *_states;
}

- (instancetype)initWithGesture:(SLGesture *)gesture inRect:(CGRect)rect {
    self = [super init];
    if (self) {
        _states = [[NSMutableArray alloc] initWithCapacity:[gesture.states count]];
        for (SLTouchState *state in gesture.states) {
            NSMutableSet *touches = [[NSMutableSet alloc] initWithCapacity:[state.touches count]];
            for (SLTouch *touch in state.touches) {
                CGPoint point = [touch locationInRect:rect];
                [touches addObject:[SLAppliedTouch touchAtPoint:point]];
            }
            [_states addObject:[SLAppliedTouchState stateAtTime:state.time withTouches:touches]];
        }
    }
    return self;
}

- (NSArray *)states {
    return [_states copy];
}

@end


@implementation SLAppliedTouchState

+ (instancetype)stateAtTime:(NSTimeInterval)time withTouches:(NSSet *)touches {
    SLAppliedTouchState *state = [[self alloc] init];
    state->_time = time;
    state->_touches = [touches copy];
    return state;
}

@end


@implementation SLAppliedTouch

+ (instancetype)touchAtPoint:(CGPoint)point {
    SLAppliedTouch *touch = [[self alloc] init];
    touch->_location = point;
    return touch;
}

@end
