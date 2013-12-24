//
//  SLGesture.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLGesture : NSObject <NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, strong, readonly) NSArray *stateSequences;

+ (instancetype)gestureWithStateSequences:(NSArray *)stateSequences;

@end


@interface SLGesture (Serialization)

+ (instancetype)gestureWithContentsOfFile:(NSString *)path;

- (BOOL)writeToFile:(NSString *)path;

@end

@class SLTouchStateSequence;
@interface SLMutableGesture : SLGesture

- (void)addStateSequence:(SLTouchStateSequence *)state;

@end


#pragma mark -

@interface SLTouchStateSequence : NSObject <NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, strong, readonly) NSArray *states;

+ (instancetype)sequenceAtTime:(NSTimeInterval)time withStates:(NSArray *)states;

@end

@class SLTouchState;
@interface SLMutableTouchStateSequence : SLTouchStateSequence

- (instancetype)initAtTime:(NSTimeInterval)time;

- (void)addState:(SLTouchState *)state;

@end


@interface SLTouchState : NSObject <NSCoding>

@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, strong, readonly) NSSet *touches;

+ (instancetype)stateAtTime:(NSTimeInterval)time withTouches:(NSSet *)touches;

@end


@interface SLTouch : NSObject <NSCoding>

+ (instancetype)touchAtPoint:(CGPoint)point inRect:(CGRect)rect;

- (CGPoint)locationInRect:(CGRect)rect;

@end
