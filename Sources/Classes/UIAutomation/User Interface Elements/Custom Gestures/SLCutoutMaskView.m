//
//  SLCutoutMaskView.m
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLCutoutMaskView.h"

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
        [UIView transitionWithView:self
                          duration:(animated ? 0.5 : 0.0)
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.layer displayIfNeeded];
                        } completion:nil];
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
