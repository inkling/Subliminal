//
//  SLGestureRecorder.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/3/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGestureRecorder.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "SLGesture.h"
#import "SLGesture+Recording.h"

@interface SLGestureRecorderRecognizer : UIGestureRecognizer

@property (nonatomic) CGRect rect;
@property (nonatomic, readonly, strong) SLGesture *gesture;

- (instancetype)initWithTarget:(id)target action:(SEL)action rect:(CGRect)rect;

@end


@interface SLGestureRecorder () <UIGestureRecognizerDelegate>
@end

@implementation SLGestureRecorder {
    CGRect _rect;

    SLGestureRecorderRecognizer *_gestureRecognizer;
}

- (instancetype)initWithRect:(CGRect)rect {
    self = [super init];
    if (self) {
        _rect = rect;

        _gestureRecognizer = [[SLGestureRecorderRecognizer alloc] initWithTarget:self
                                                                          action:@selector(didRecognizeGesture:)
                                                                            rect:rect];
        _gestureRecognizer.delegate = self;
    }
    return self;
}

- (void)dealloc {
    NSAssert(![self isRecording],
             @"%@ was freed without recording having been stopped.", self);
}

- (void)setRect:(CGRect)rect {
    NSAssert(![self isRecording],
             @"%@ must be stopped before its observed rect can be changed.", self);
    _rect = rect;
    _gestureRecognizer.rect = _rect;
}

- (void)setRecording:(BOOL)recording {
    NSAssert([NSThread isMainThread], @"Gesture recording must start and stop on the main thread.");

    if (recording != _recording) {
        if (recording) {
            [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:_gestureRecognizer];
            _gestureRecognizer.enabled = YES;
        } else {
            // disable before removing to cancel recognition in the approved way
            _gestureRecognizer.enabled = NO;
            [_gestureRecognizer.view removeGestureRecognizer:_gestureRecognizer];
        }
        _recording = recording;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL gestureRecognizerShouldReceiveTouch = YES;
    if ([self.delegate respondsToSelector:@selector(gestureRecorder:shouldReceiveTouch:)]) {
        gestureRecognizerShouldReceiveTouch = [self.delegate gestureRecorder:self shouldReceiveTouch:touch];
    }
    return gestureRecognizerShouldReceiveTouch;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didRecognizeGesture:(SLGestureRecorderRecognizer *)recognizer {
    // TODO: Handle discrete (multi-sequence) gestures too
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.delegate gestureRecorder:self didRecordGesture:recognizer.gesture];
    }
}

@end


#pragma mark -


@implementation SLGestureRecorderRecognizer {
    CGRect _rect;
    NSDate *_gestureStartDate;
    SLMutableGesture *_gesture;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action rect:(CGRect)rect {
    self = [self initWithTarget:target action:action];
    if (self) {
        _rect = rect;
        [self reset];
    }
    return self;
}

- (void)setRect:(CGRect)rect {
    // cancel any recognition in process
    self.enabled = NO;
    _rect = rect;
    self.enabled = YES;
}

- (void)reset {
    _gestureStartDate = nil;
    _gesture = [[SLMutableGesture alloc] init];
}

- (SLGesture *)gesture {
    return [_gesture copy];
}

- (void)recordTouches:(NSSet *)touches {
    NSDate *touchDate = [NSDate date];
    if (!_gestureStartDate) {
        _gestureStartDate = touchDate;
    }

    NSTimeInterval touchTime = [touchDate timeIntervalSinceDate:_gestureStartDate];
    [_gesture addState:[SLTouchState stateAtTime:touchTime withUITouches:touches rect:_rect]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches];

    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
}

@end
