//
//  SLCutoutMaskView.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLCutoutMaskView : UIView

@property (nonatomic) BOOL masking;
@property (nonatomic) CGRect cutoutRect;

- (void)setMasking:(BOOL)masking animated:(BOOL)animated;

@end
