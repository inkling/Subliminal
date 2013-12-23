//
//  SLGesture.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGesture.h"

static const NSTimeInterval kMinimumStateInterval = 0.1;

@interface SLGesture ()
@property (nonatomic, readwrite) NSArray *states;
@end

@implementation SLGesture {
    NSMutableArray *_mutableStates;
}

+ (instancetype)gestureWithStates:(NSArray *)states {
    SLGesture *gesture = [[self alloc] init];
    for (SLTouchState *state in states) {
        [gesture addState:state];
    }
    return gesture;
}

- (id)init {
    self = [super init];
    if (self) {
        _mutableStates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.states = [aDecoder decodeObjectForKey:@"states"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.states forKey:@"states"];
}

- (id)copyWithZone:(NSZone *)zone {
    SLGesture *gesture = [[[self class] allocWithZone:zone] init];
    gesture.states = self.states;
    return gesture;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    // `SLMutableGesture` overrides `-mutableCopyWithZone:` to enable subclassing
    SLMutableGesture *mutableGesture = [[SLMutableGesture allocWithZone:zone] init];
    mutableGesture.states = self.states;
    return mutableGesture;
}

- (void)setStates:(NSArray *)states {
    [_mutableStates removeAllObjects];
    [_mutableStates addObjectsFromArray:states];
}

- (NSArray *)states {
    return [_mutableStates copy];
}

- (void)addState:(SLTouchState *)state {
    NSParameterAssert(state);

    SLTouchState *lastState = [_mutableStates lastObject];
    NSParameterAssert(!lastState || (state.time > lastState.time));

    if (!lastState || ((state.time - lastState.time) >= kMinimumStateInterval)) {
        [_mutableStates addObject:state];
    }
}

@end


@implementation SLGesture (Serialization)

+ (instancetype)gestureWithContentsOfFile:(NSString *)path {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (BOOL)writeToFile:(NSString *)path {
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

@end


@implementation SLMutableGesture

// the compiler requires that `SLMutableGesture` provides an implementation of `addState:`
// because it's declared in `SLMutableGesture`'s interface
- (void)addState:(SLTouchState *)state {
    [super addState:state];
}

// `SLMutableGesture` overrides `-mutableCopyWithZone:` to support subclassing
// (by alloc'ing an instance of `[self class]` below)
- (id)mutableCopyWithZone:(NSZone *)zone {
    SLMutableGesture *mutableGesture = [[[self class] allocWithZone:zone] init];
    mutableGesture.states = self.states;
    return mutableGesture;
}

@end


@implementation SLTouchState

+ (instancetype)stateAtTime:(NSTimeInterval)time withTouches:(NSSet *)touches {
    SLTouchState *state = [[self alloc] init];
    state->_time = time;
    state->_touches = [touches copy];
    return state;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        _time = (NSTimeInterval)[aDecoder decodeDoubleForKey:@"time"];
        _touches = [aDecoder decodeObjectForKey:@"touches"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:(double)_time forKey:@"time"];
    [aCoder encodeObject:_touches forKey:@"touches"];
}

@end


@implementation SLTouch {
    CGPoint _offset;
}

+ (instancetype)touchAtPoint:(CGPoint)point inRect:(CGRect)rect {
    SLTouch *touch = [[self alloc] init];
    touch->_offset = (CGPoint){
        .x = (point.x - CGRectGetMinX(rect)) / CGRectGetWidth(rect),
        .y = (point.y - CGRectGetMinY(rect)) / CGRectGetHeight(rect)
    };
    return touch;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        _offset = [aDecoder decodeCGPointForKey:@"offset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:_offset forKey:@"offset"];
}

- (CGPoint)locationInRect:(CGRect)rect {
    return (CGPoint){
        .x = CGRectGetMinX(rect) + (_offset.x * CGRectGetWidth(rect)),
        .y = CGRectGetMinY(rect) + (_offset.y * CGRectGetHeight(rect))
    };
}

@end
