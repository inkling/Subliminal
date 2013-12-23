//
//  SLGesture+SLUIAElement.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGesture.h"

@class SLUIAElement;
@interface SLGesture (SLUIAElement)

- (void)applyToElement:(SLUIAElement *)element;

@end
