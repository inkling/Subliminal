//
//  SLAppliedGesture+Evaluation.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/22/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLAppliedGesture+Evaluation.h"

#import "SLTerminal.h"

@implementation SLAppliedGesture (Evaluation)

- (void)evaluate {
    (void)[[SLTerminal sharedTerminal] evalWithFormat:@"UIATarget.localTarget().touch(%@);", [self UIARepresentation]];
}

- (NSString *)UIARepresentation {
    NSString *stateRepresentations = [[self.states valueForKey:@"UIARepresentation"] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"[%@]", stateRepresentations];
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
