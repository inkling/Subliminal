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
@property (nonatomic, readwrite) NSArray *stateSequences;
@end

@implementation SLGesture {
    NSMutableArray *_mutableStateSequences;
}

+ (instancetype)gestureWithStateSequences:(NSArray *)stateSequences {
    SLGesture *gesture = [[self alloc] init];
    for (SLTouchStateSequence *stateSequence in stateSequences) {
        [gesture addStateSequence:stateSequence];
    }
    return gesture;
}

- (id)init {
    self = [super init];
    if (self) {
        _mutableStateSequences = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.stateSequences = [aDecoder decodeObjectForKey:@"stateSequences"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.stateSequences forKey:@"stateSequences"];
}

- (id)copyWithZone:(NSZone *)zone {
    SLGesture *gesture = [[[self class] allocWithZone:zone] init];
    gesture.stateSequences = self.stateSequences;
    return gesture;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    // `SLMutableGesture` overrides `-mutableCopyWithZone:` to enable subclassing
    SLMutableGesture *mutableGesture = [[SLMutableGesture allocWithZone:zone] init];
    mutableGesture.stateSequences = self.stateSequences;
    return mutableGesture;
}

- (void)setStateSequences:(NSArray *)stateSequences {
    [_mutableStateSequences removeAllObjects];
    [_mutableStateSequences addObjectsFromArray:stateSequences];
}

- (NSArray *)stateSequences {
    return [_mutableStateSequences copy];
}

- (void)addStateSequence:(SLTouchStateSequence *)stateSequence {
    NSParameterAssert(stateSequence);

    SLTouchStateSequence *lastStateSequence = [_mutableStateSequences lastObject];
    NSParameterAssert(!lastStateSequence || (stateSequence.time > lastStateSequence.time));

    if (!lastStateSequence || ((stateSequence.time - lastStateSequence.time) >= kMinimumStateInterval)) {
        [_mutableStateSequences addObject:[stateSequence copy]];
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

// the compiler requires that `SLMutableGesture` provides an implementation of `-addStateSequence:`
// because it's declared in `SLMutableGesture`'s interface
- (void)addStateSequence:(SLTouchStateSequence *)stateSequence {
    [super addStateSequence:stateSequence];
}

// `SLMutableGesture` overrides `-mutableCopyWithZone:` to support subclassing
// (by alloc'ing an instance of `[self class]` below)
- (id)mutableCopyWithZone:(NSZone *)zone {
    SLMutableGesture *mutableGesture = [[[self class] allocWithZone:zone] init];
    mutableGesture.stateSequences = self.stateSequences;
    return mutableGesture;
}

@end


@implementation SLTouchStateSequence {
    NSMutableArray *_mutableStates;
}

+ (instancetype)sequenceAtTime:(NSTimeInterval)time withStates:(NSArray *)states {
    SLTouchStateSequence *stateSequence = [[self alloc] initAtTime:time];
    for (SLTouchState *state in states) {
        [stateSequence addState:state];
    }
    return stateSequence;
}

- (instancetype)initAtTime:(NSTimeInterval)time {
    self = [super init];
    if (self) {
        _time = time;
        _mutableStates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSTimeInterval time = [aDecoder decodeDoubleForKey:@"time"];
    self = [self initAtTime:time];
    if (self) {
        self.states = [aDecoder decodeObjectForKey:@"states"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:(double)self.time forKey:@"time"];
    [aCoder encodeObject:self.states forKey:@"states"];
}

- (id)copyWithZone:(NSZone *)zone {
    SLTouchStateSequence *stateSequence = [[[self class] allocWithZone:zone] initAtTime:self.time];
    stateSequence.states = self.states;
    return stateSequence;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    // `SLMutableTouchStateSequence` overrides `-mutableCopyWithZone:` to enable subclassing
    SLMutableTouchStateSequence *mutableStateSequence = [[SLMutableTouchStateSequence allocWithZone:zone] initAtTime:self.time];
    mutableStateSequence.states = self.states;
    return mutableStateSequence;
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

    // we must allow 2 states even if within the minimum state interval:
    // UIAutomation doesn't appear to drop a quick second state if there's only two,
    // and the second state is necessary to establish the duration of the first
    if (([_mutableStates count] < 2) ||
        ((state.time - lastState.time) >= kMinimumStateInterval)) {
        [_mutableStates addObject:state];
    }
}

@end


@implementation SLMutableTouchStateSequence

// the compiler requires that `SLMutableTouchStateSequence` provides an implementation of `-initAtTime:`
// because it's declared in `SLMutableTouchStateSequence`'s interface
- (instancetype)initAtTime:(NSTimeInterval)time {
    return [super initAtTime:time];
}

// the compiler requires that `SLMutableTouchStateSequence` provides an implementation of `-addState:`
// because it's declared in `SLMutableTouchStateSequence`'s interface
- (void)addState:(SLTouchState *)state {
    [super addState:state];
}

// `SLMutableGesture` overrides `-mutableCopyWithZone:` to support subclassing
// (by alloc'ing an instance of `[self class]` below)
- (id)mutableCopyWithZone:(NSZone *)zone {
    SLMutableTouchStateSequence *mutableStateSequence = [[[self class] allocWithZone:zone] initAtTime:self.time];
    mutableStateSequence.states = self.states;
    return mutableStateSequence;
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
