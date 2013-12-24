//
//  SLAppliedGesture+Evaluation.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLAppliedGesture+Evaluation.h"

#import "SLTerminal.h"
#import "SLTerminal+ConvenienceFunctions.h"

@implementation SLAppliedGesture (Evaluation)

- (void)evaluate {
    // serialize the gesture altogether and loop over the state sequences in JS rather than in Obj-C
    // so that there's no transmission delay between sequences
    (void)[[SLTerminal sharedTerminal] evalFunctionWithName:@"SLAppliedGestureEvaluate"
                                                     params:@[@"gesture"]
                                                       body:@""
               @"var gestureStartTimeInSeconds = null;\
                 for (var sequenceIndex = 0; sequenceIndex < gesture.length; sequenceIndex++) {\
                     var stateSequence = gesture[sequenceIndex];\
                     var currentTimeInSeconds = Date.now() / 1000;\
                     if (gestureStartTimeInSeconds) {\
                         var gestureTime = currentTimeInSeconds - gestureStartTimeInSeconds;\
                         if (gestureTime < stateSequence.time) {\
                            var delayInterval = stateSequence.time - gestureTime;\
                            UIATarget.localTarget().delay(delayInterval);\
                         }\
                     } else {\
                        gestureStartTimeInSeconds = currentTimeInSeconds;\
                     }\
                     UIATarget.localTarget().touch(stateSequence.states);\
                 }"
                                                   withArgs:@[[self UIARepresentation]]];
}

- (NSString *)UIARepresentation {
    NSString *stateSequenceRepresentations = [[self.stateSequences valueForKey:@"UIARepresentation"] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"[%@]", stateSequenceRepresentations];
}

@end


@implementation SLAppliedTouchStateSequence (Evaluation)

- (NSString *)UIARepresentation {
    NSString *stateRepresentations = [[self.states valueForKey:@"UIARepresentation"] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"{time:%g, states:[%@]}", self.time, stateRepresentations];
}

@end


@implementation SLAppliedTouchState (Evaluation)

- (NSString *)UIARepresentation {
    NSString *touchRepresentations = [[[self.touches valueForKey:@"UIARepresentation"] allObjects] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"{time:%g, touch:[%@]}", self.time, touchRepresentations];
}

@end


@implementation SLAppliedTouch (Evaluation)

- (NSString *)UIARepresentation {
    return [NSString stringWithFormat:@"{x:%g, y:%g}", self.location.x, self.location.y];
}

@end
