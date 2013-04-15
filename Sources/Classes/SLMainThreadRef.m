//
//  SLMainThreadRef.m
//  Subliminal
//
//  Created by Jeffrey Wear on 4/15/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLMainThreadRef.h"

@implementation SLMainThreadRef {
    id __weak _target;
}

+ (instancetype)refWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

- (id)target {
    NSAssert([NSThread isMainThread],
             @"An SLMainThreadRef's target may only be accessed from the main thread.");
    return _target;
}

- (NSString *)description {
    // we intentionally allow for "(null)" to be formatted into the string
    // if the target's been released
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), _target];
}

@end
