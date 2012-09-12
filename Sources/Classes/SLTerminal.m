//
//  STSubliminalTerminal.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTerminal.h"
#import "SLTest.h"


static NSString *const SLTerminalDefaultsExistsKey = @"SLTerminalDefaultsExistsKey";

static NSString *const SLTerminalInvalidMessageException = @"SLTerminalInvalidMessageException";


@implementation SLTerminal {
    UIButton *_outputButton;
        
    dispatch_semaphore_t _dispatchSemaphore;
    dispatch_semaphore_t _responseSemaphore;
    NSString *_response;
}

static SLTerminal *__sharedTerminal = nil;
+ (id)sharedTerminal {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedTerminal = [[SLTerminal alloc] init];
    });
    return __sharedTerminal;
}

+ (NSException *)parseExceptionFromResponse:(NSString *)response toMessage:(NSString *)message {
    NSException *exception = nil;
    
    // UIAutomation will have prefixed the response if it was an exception
    if ([response hasPrefix:SLExceptionOccurredResponsePrefix]) {
        NSString *exceptionString = [response substringFromIndex:NSMaxRange([response rangeOfString:SLExceptionOccurredResponsePrefix])];

        NSString *exceptionReason = [NSString stringWithFormat:@"Message \"%@\" caused exception: \"%@\"", message, exceptionString];
        exception = [NSException exceptionWithName:SLTerminalInvalidMessageException reason:exceptionReason userInfo:nil];
    }

    return exception;
}

- (id)init {
    NSAssert(!__sharedTerminal, @"SLTerminal should not be initialized manually. Use +sharedTerminal instead.");
    
    self = [super init];
    if (self) {
        // the terminal can only send one message at a time
        _dispatchSemaphore = dispatch_semaphore_create(1);
        // the terminal waits for a message to be received before returning from send:
        _responseSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

// for completeness' sake
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyWindowDidChange:(NSNotification *)notification {
    UIWindow *newKeyWindow = [notification object];
    [_outputButton removeFromSuperview];
    [newKeyWindow addSubview:_outputButton];
}

- (void)startWithCompletionBlock:(void (^)(void))completionBlock {
    NSAssert(!_hasStarted, @"Terminal has already started.");
    
    // add output button to window
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSAssert(window, @"A window must be made key and visible before starting the terminal.");
    
    const CGFloat windowTop = CGRectGetMaxY([[UIApplication sharedApplication] statusBarFrame]);
    CGSize pixelSize = (CGSize){2,2};
    
    CGPoint upperRightPoint = CGPointMake(CGRectGetMaxX(window.bounds) - pixelSize.width,
                                          windowTop);
    _outputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // button must have background color to be guaranteed tappable
    _outputButton.backgroundColor = [UIColor whiteColor];
    [_outputButton addTarget:self action:@selector(messageReceived:) forControlEvents:UIControlEventTouchUpInside];
    _outputButton.frame = (CGRect){ .origin=upperRightPoint, .size=pixelSize };
    _outputButton.accessibilityIdentifier = SLTerminalOutputButtonAccessibilityIdentifier;
    _outputButton.hidden = YES;
    [window addSubview:_outputButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWindowDidChange:) name:UIWindowDidBecomeKeyNotification object:nil];
    
    
    // register the defaults plist (used for input) with UIAutomation
    
    // ensure that the plist exists (it won't if there are no preferences stored)
    BOOL defaultsExists = [[NSUserDefaults standardUserDefaults] boolForKey:SLTerminalDefaultsExistsKey];
    if (!defaultsExists) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SLTerminalDefaultsExistsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // in the background ('cause it'll block) tell UIAutomation to retrieve the path to the preferences
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self send:@"registerOutputDefaultsPath();"];
        
        // clear response key in defaults, in case it's there
        if ([[NSUserDefaults standardUserDefaults] objectForKey:SLTerminalInputDefaultsKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SLTerminalInputDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        _hasStarted = YES;
        if (completionBlock) completionBlock();
    });
}

- (NSString *)send:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *response = [self send:message args:args];
    va_end(args);
    
    return response;
}

- (NSString *)send:(NSString *)message args:(va_list)args {
    NSAssert(![NSThread isMainThread], @"-send: must not be called from the main thread.");
        
    // wait for terminal to become available: only one message can be sent at a time
    dispatch_semaphore_wait(_dispatchSemaphore, DISPATCH_TIME_FOREVER);
    
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_outputButton setTitle:formattedMessage forState:UIControlStateNormal];
        _outputButton.hidden = NO;
    });
    
    // block calling thread (not the main thread) on UIAutomation's response
    // in messageReceived:, below
    dispatch_semaphore_wait(_responseSemaphore, DISPATCH_TIME_FOREVER);
    
    NSString *response = _response;
    // now that we've saved and will return the response, the terminal is now available
    dispatch_semaphore_signal(_dispatchSemaphore);
    
    // before returning, we "re-throw" exceptions that occurred during evaluation
    NSException *evaluationException = [[self class] parseExceptionFromResponse:response toMessage:formattedMessage];
    if (evaluationException) [evaluationException raise];
        
    return response;
}

// note that this callback comes in on the main thread
- (void)messageReceived:(id)sender {
    _outputButton.hidden = YES;
    [_outputButton setTitle:nil forState:UIControlStateNormal];
    
    // synchronize to have NSUserDefaults read the response from the file system
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *response = [[NSUserDefaults standardUserDefaults] stringForKey:SLTerminalInputDefaultsKey];
    
    // "defaults write", used by UIAutomation, sometimes encapsulates values in single quotes; here we extract the contents
    if ([response hasPrefix:@"'"]) {
        response = [response substringFromIndex:NSMaxRange([response rangeOfString:@"'"])];
    }
    if ([response hasSuffix:@"'"]) {
        response = [response substringWithRange:NSMakeRange(0, [response length] - 1)];
    }
    
    _response = response;
    
    // clear the response now that we've read it
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SLTerminalInputDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // signal thread waiting on UIAutomation's response (in send:) to continue
    dispatch_semaphore_signal(_responseSemaphore);
}

@end
