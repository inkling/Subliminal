//
//  SLGestureRecordingSession.m
//  Subliminal
//
//  Created by Jeffrey Wear on 11/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGestureRecordingSession.h"

#import <QuartzCore/QuartzCore.h>

#import "SLGesture.h"
#import "SLGesture+SLUIAElement.h"
#import "SLUIAElement.h"
#import "SLGestureRecorder.h"
#import "SLCutoutMaskView.h"
#import "SLRecordingToolbar.h"

typedef NS_ENUM(NSInteger, SLGestureRecordingSessionState) {
    SLGestureRecordingSessionStateReady,
    SLGestureRecordingSessionStateRecordingPreflight,
    SLGestureRecordingSessionStateRecording,
    SLGestureRecordingSessionStatePlayingBack,
    SLGestureRecordingSessionStateFinished
};

@interface SLGestureRecordingSession () <SLGestureRecorderDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) SLGesture *recordedGesture;
// `state` is atomic because it may be read by both the testing and the main threads,
// though it may only be updated by the main thread
@property (atomic) SLGestureRecordingSessionState state;
@end

@implementation SLGestureRecordingSession {
    SLUIAElement *_element;
    SLGestureRecorder *_recorder;
    // used to synchronize communication between the testing thread that starts the session
    // and the main thread that receives callbacks from the user interacting with the recording UI
    dispatch_semaphore_t _sessionSemaphore;

    SLCutoutMaskView *_elementHighlightView;
    UITapGestureRecognizer *_elementHighlightViewDismissRecognizer;

    SLRecordingToolbar *_toolbar;
}
@synthesize state = _state;

+ (SLGesture *)recordGestureWithElement:(SLUIAElement *)element {
    return [[[self alloc] initWithElement:element] recordGesture];
}

- (instancetype)initWithElement:(SLUIAElement *)element {
    self = [super init];
    if (self) {
        _element = element;

        _sessionSemaphore = dispatch_semaphore_create(0);

        _elementHighlightView = [[SLCutoutMaskView alloc] initWithFrame:CGRectZero];
        // ensure that the app will be able to be manipulated behind the highlight view
        _elementHighlightView.userInteractionEnabled = NO;

        // a gesture recognizer must have a target or it will not receive touches,
        // but the real work is done in `-gestureRecognizer:shouldReceiveTouch:`
        // so that we can dismiss the element highlight view in response to any touch, not just taps
        _elementHighlightViewDismissRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHighlightView:)];
        _elementHighlightViewDismissRecognizer.delegate = self;
        // the recognizer must not cancel touches (i.e. upon the toolbar items)
        _elementHighlightViewDismissRecognizer.cancelsTouchesInView = NO;
        _elementHighlightViewDismissRecognizer.delaysTouchesEnded = NO;
        // recognizer will be added to a view when recording begins (on the main thread)

        _toolbar = [[SLRecordingToolbar alloc] initWithFrame:CGRectZero];

        for (UIBarButtonItem *toolbarItem in @[ _toolbar.playButtonItem, _toolbar.recordButtonItem,
                                                _toolbar.stopButtonItem, _toolbar.doneButtonItem ]) {
            toolbarItem.target = self;
        }
        _toolbar.playButtonItem.action = @selector(play:);
        _toolbar.recordButtonItem.action = @selector(record:);
        _toolbar.stopButtonItem.action = @selector(stop:);
        _toolbar.doneButtonItem.action = @selector(finishSession:);
    }
    return self;
}

- (void)dealloc {
    NSAssert(![_recorder isRecording],
             @"%@ was freed without recording having been stopped.", self);

    if (_sessionSemaphore) dispatch_release(_sessionSemaphore);
}

- (SLGesture *)recordGesture {
    [self startSession];

    return self.recordedGesture;
}

- (void)startSession {
    NSAssert(![NSThread isMainThread], @"Gesture recording must begin on a background thread.");

    CGRect rect = [_element rect];

    dispatch_async(dispatch_get_main_queue(), ^{
        _recorder = [[SLGestureRecorder alloc] initWithRect:rect];
        _recorder.delegate = self;

        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        _elementHighlightView.frame = keyWindow.bounds;
        [keyWindow addSubview:_elementHighlightView];

        // focus the user's attention by highlighting the element
        CGRect referenceRectInWindow = [keyWindow convertRect:rect fromWindow:nil];
        _elementHighlightView.cutoutRect = [_elementHighlightView convertRect:referenceRectInWindow fromView:keyWindow];

        // dismiss the highlight view if the user interacts with the app before recording begins
        // we can't add the gesture recognizer to the element highlight view itself
        // because it has user interaction disabled (see `-initWithElement:`)
        [keyWindow addGestureRecognizer:_elementHighlightViewDismissRecognizer];

        // horizontally center the toolbar just under the status bar
        CGRect toolbarFrame = (CGRect){
            .origin.y = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]),
            .size = [_toolbar sizeThatFits:CGSizeZero]
        };
        toolbarFrame.origin.x = roundf((CGRectGetWidth(keyWindow.bounds) - CGRectGetWidth(toolbarFrame)) / 2.0);
        _toolbar.frame = toolbarFrame;
        [keyWindow addSubview:_toolbar];

        self.state = SLGestureRecordingSessionStateReady;
    });
    dispatch_semaphore_wait(_sessionSemaphore, DISPATCH_TIME_FOREVER);

    // we may be reawakened temporarily to evaluate some action on the testing queue;
    // if so, we perform that action and then go back to sleep
    while ([self continueSession]) dispatch_semaphore_wait(_sessionSemaphore, DISPATCH_TIME_FOREVER);
}

// we may be reawakened on the testing queue in order to update the recorded rect
// or to play back a gesture
- (BOOL)continueSession {
    BOOL sessionDidContinue = NO;

    switch (self.state) {
        case SLGestureRecordingSessionStateRecordingPreflight: {
            _recorder.rect = [_element rect];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self recordingPreflightDidComplete];
            });
            sessionDidContinue = YES;
            break;
        }
        case SLGestureRecordingSessionStatePlayingBack: {
            [self.recordedGesture applyToElement:_element];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self playbackDidComplete];
            });
            sessionDidContinue = YES;
            break;
        }
        default: {
            break;
        }
    }

    return sessionDidContinue;
}

- (void)finishSession:(id)sender {
    NSAssert([NSThread isMainThread], @"Gesture recording must stop on the main thread.");

    self.state = SLGestureRecordingSessionStateFinished;
    [_recorder setRecording:NO];
    _recorder = nil;
    
    [_elementHighlightView removeFromSuperview];
    [_elementHighlightViewDismissRecognizer.view removeGestureRecognizer:_elementHighlightViewDismissRecognizer];

    [_toolbar removeFromSuperview];

    dispatch_semaphore_signal(_sessionSemaphore);
}

#pragma mark - Dismissing the Element Highlight View on Touch

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((gestureRecognizer == _elementHighlightViewDismissRecognizer) &&
        (CGRectContainsPoint(_elementHighlightView.bounds, [touch locationInView:_elementHighlightView]))) {
        // dismiss the element highlight view immediately in response to a user's touch
        [_elementHighlightView setMasking:NO animated:NO];
    }
    return YES;
}

- (void)dismissHighlightView:(UITapGestureRecognizer *)recognizer {
    // nothing to do here--the view is dismissed in `gestureRecognizer:shouldReceiveTouch:`
    // (see discussion in `-initWithElement:`
}

#pragma mark - Recording and Playback

- (SLGestureRecordingSessionState)state {
    SLGestureRecordingSessionState state;
    @synchronized(self) {
        state = _state;
    }
    return _state;
}

- (void)setState:(SLGestureRecordingSessionState)state {
    NSAssert([NSThread isMainThread],
             @"The recording session's state should only be updated on the main thread.");

    // even though `state` may only be modified from the main thread,
    // we must still synchronize it because it can be read from the testing thread
    @synchronized(self) {
        // disallow a transition (e.g. in response to a testing queue callback)
        // if we've already finished
        if (self.state == SLGestureRecordingSessionStateFinished) return;

        BOOL recordingShown = NO;
        BOOL playbackEnabled = NO, recordingEnabled = NO, stoppingEnabled = NO, doneEnabled = NO;

        switch (state) {
            case SLGestureRecordingSessionStateReady:
                playbackEnabled = (self.recordedGesture != nil);
                recordingShown = YES;
                recordingEnabled = YES;
                doneEnabled = YES;
                break;
            case SLGestureRecordingSessionStateRecordingPreflight:
                // we're preparing to transition to record, but we could be canceled
                stoppingEnabled = YES;
                doneEnabled = YES;
                break;
            case SLGestureRecordingSessionStateRecording:
                stoppingEnabled = YES;
                doneEnabled = YES;
                break;
            case SLGestureRecordingSessionStatePlayingBack:
                // UIAutomation can't be directed to stop playing back a gesture
                // so we don't bother enabling the stop or done buttons
                // we show recording because that's the next action the user would take,
                // if they don't end the session
                recordingShown = YES;
                break;
            case SLGestureRecordingSessionStateFinished:
                // everything disabled
                break;
        }

        _toolbar.showsRecordButton = recordingShown;
        _toolbar.playButtonItem.enabled = playbackEnabled;
        _toolbar.recordButtonItem.enabled = recordingEnabled;
        _toolbar.stopButtonItem.enabled = stoppingEnabled;
        _toolbar.doneButtonItem.enabled = doneEnabled;
        
        _state = state;
    }
}

- (void)play:(id)sender {
    self.state = SLGestureRecordingSessionStatePlayingBack;

    // awake the testing queue (blocked in `-startSession`) to apply the recorded gesture
    dispatch_semaphore_signal(_sessionSemaphore);
}

- (void)playbackDidComplete {
    self.state = SLGestureRecordingSessionStateReady;
}

- (void)record:(id)sender {
    self.recordedGesture = nil;
    self.state = SLGestureRecordingSessionStateRecordingPreflight;

    // awake the testing queue (blocked in `-startSession`) to update the recorded rect
    dispatch_semaphore_signal(_sessionSemaphore);
}

- (void)recordingPreflightDidComplete {
    self.state = SLGestureRecordingSessionStateRecording;

    // dismiss the element highlight view without animation to suggest that recording begins immediately
    [_elementHighlightView setMasking:NO animated:NO];

    [_recorder setRecording:YES];
}

- (void)stop:(id)sender {
    [_recorder setRecording:NO];
    self.recordedGesture = _recorder.recordedGesture;

    self.state = SLGestureRecordingSessionStateReady;
}

- (BOOL)gestureRecorder:(SLGestureRecorder *)recorder shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:_toolbar];
}

@end
