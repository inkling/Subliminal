//
//  SLSlider.m
//  Subliminal
//
//  Created by Maximilian Tagher on 4/27/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLSlider.h"

@implementation SLSlider

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object]
            && [object isKindOfClass:[UISlider class]]);
}

- (void)dragToValue:(float)value
{
    NSAssert(value >= 0 && value <= 1, @"SLSlider values must be between 0 and 1.");
    [self waitUntilTappable:NO thenSendMessage:@"dragToValue(%f)", value];
}

- (float)floatValue
{
    // @"100%" -> 100 -> 1
    return [[self value] floatValue] / 100.0f;
}

- (NSString *)value
{
    return [super value];
}

@end
