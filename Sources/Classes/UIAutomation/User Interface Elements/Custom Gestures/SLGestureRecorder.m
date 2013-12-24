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

        // a gesture recognizer must be initialized with a target in order to receive touches
        // but the recorder never recognizes (finishes evaluating) a gesture,
        // as we wish to receive all touches until we're directed to stop recording
        _gestureRecognizer = [[SLGestureRecorderRecognizer alloc] initWithTarget:self
                                                                          action:@selector(didFinishRecognition:)
                                                                            rect:rect];
        // in order to freely manipulate the app, the recognizer must not cancel nor delay touches
        _gestureRecognizer.cancelsTouchesInView = NO;
        _gestureRecognizer.delaysTouchesEnded = NO;
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
            _recordedGesture = nil;

            [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:_gestureRecognizer];
            _gestureRecognizer.enabled = YES;
        } else {
            // disable before removing to cancel recognition in the approved way
            _gestureRecognizer.enabled = NO;
            [_gestureRecognizer.view removeGestureRecognizer:_gestureRecognizer];

            _recordedGesture = _gestureRecognizer.gesture;
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

- (void)didFinishRecognition:(SLGestureRecorderRecognizer *)recognizer {
    // nothing to do here; we don't expect this to be called anyway
}

@end


#pragma mark -


@implementation SLGestureRecorderRecognizer {
    CGRect _rect;
    NSDate *_gestureStartDate, *_touchSequenceStartDate;
    SLMutableGesture *_gesture;
    SLMutableTouchStateSequence *_currentStateSequence;
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
    _gestureStartDate = nil, _touchSequenceStartDate = nil;
    _gesture = [[SLMutableGesture alloc] init];
}

- (SLGesture *)gesture {
    return [_gesture copy];
}

- (void)recordTouches:(NSSet *)touches atDate:(NSDate *)date {
    NSTimeInterval touchTime = [date timeIntervalSinceDate:_touchSequenceStartDate];
    [_currentStateSequence addState:[SLTouchState stateAtTime:touchTime withUITouches:touches rect:_rect]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSDate *touchDate = [NSDate date];
    if (!_gestureStartDate) _gestureStartDate = touchDate;
    _touchSequenceStartDate = touchDate;

    NSTimeInterval touchTime = [touchDate timeIntervalSinceDate:_gestureStartDate];
    _currentStateSequence = [[SLMutableTouchStateSequence alloc] initAtTime:touchTime];

    // record the first touch state as occurring exactly at the start of the sequence
    [self recordTouches:touches atDate:touchDate];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches atDate:[NSDate date]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches atDate:[NSDate date]];

    [_gesture addStateSequence:_currentStateSequence];
    _currentStateSequence = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
}

@end
