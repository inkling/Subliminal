//
//  SLCutoutMaskView.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLCutoutMaskView.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kMaskShowHideDuration = 0.5;

@implementation SLCutoutMaskView

+ (UIColor *)maskColor {
    return [UIColor colorWithWhite:0.0f alpha:0.3f];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        _masking = YES;
    }
    return self;
}

- (void)setCutoutRect:(CGRect)cutoutRect {
    if (!CGRectEqualToRect(cutoutRect, _cutoutRect)) {
        _cutoutRect = cutoutRect;
        [self setNeedsDisplay];
    }
}

- (void)setMasking:(BOOL)masking {
    [self setMasking:masking animated:NO];
}

- (void)setMasking:(BOOL)masking animated:(BOOL)animated {
    if (masking != _masking) {
        _masking = masking;
        [self setNeedsDisplay];
        if (animated) {
            [UIView transitionWithView:self
                              duration:kMaskShowHideDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.layer displayIfNeeded];
                            } completion:nil];
        } else {
            // if we don't want to use an animation, we mustn't use an animation block even with `duration == 0.0`
            // because `CALayer` will try to apply a default transition duration within an animation block
            [self.layer displayIfNeeded];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    UIColor *backgroundColor = self.masking ? [[self class] maskColor] : [UIColor clearColor];
    [backgroundColor setFill];
    UIRectFill(rect);

    [[UIColor clearColor] setFill];
    UIRectFill(self.cutoutRect);
}

@end
