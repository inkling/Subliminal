//
//  SLPopover.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLPopover.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLPopover

+ (instancetype)currentPopover {
    return [[SLPopover alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().mainWindow().popover()"];
}

- (void)dismiss {
    /*
     I don't know how to check whether dismissal requires tappability
     because I don't know how to make a popover not tappable: a popover
     is never both valid and hidden. But my inclination is to say
     that it doesn't require tappability, because a popover is dismissed
     by tapping _outside_ the popover.
     */
    [self waitUntilTappable:NO thenSendMessage:@"dismiss()"];
}

@end
