//
//  SLGesture+SLUIAElement.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGesture+SLUIAElement.h"

#import "SLUIAElement.h"
#import "SLAppliedGesture.h"
#import "SLAppliedGesture+Evaluation.h"

@implementation SLGesture (SLUIAElement)

- (void)applyToElement:(SLUIAElement *)element {
    // translate ourselves to the element's coordinate space
    SLAppliedGesture *appliedGesture = [[SLAppliedGesture alloc] initWithGesture:self inRect:[element rect]];
    // play the gesture
    [appliedGesture evaluate];
}

@end
