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
    NSMutableArray *_stateSequences;
}

- (instancetype)initWithGesture:(SLGesture *)gesture inRect:(CGRect)rect {
    self = [super init];
    if (self) {
        _stateSequences = [[NSMutableArray alloc] initWithCapacity:[gesture.stateSequences count]];
        for (SLTouchStateSequence *stateSequence in gesture.stateSequences) {
            NSMutableArray *states = [[NSMutableArray alloc] initWithCapacity:[stateSequence.states count]];
            for (SLTouchState *state in stateSequence.states) {
                NSMutableSet *touches = [[NSMutableSet alloc] initWithCapacity:[state.touches count]];
                for (SLTouch *touch in state.touches) {
                    CGPoint point = [touch locationInRect:rect];
                    [touches addObject:[SLAppliedTouch touchAtPoint:point]];
                }
                [states addObject:[SLAppliedTouchState stateAtTime:state.time withTouches:touches]];
            }
            [_stateSequences addObject:[SLAppliedTouchStateSequence sequenceAtTime:stateSequence.time withStates:states]];
        }
    }
    return self;
}

- (NSArray *)stateSequences {
    return [_stateSequences copy];
}

@end


@implementation SLAppliedTouchStateSequence

+ (instancetype)sequenceAtTime:(NSTimeInterval)time withStates:(NSArray *)states {
    SLAppliedTouchStateSequence *stateSequence = [[self alloc] init];
    stateSequence->_time = time;
    stateSequence->_states = [states copy];
    return stateSequence;
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
