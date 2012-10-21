//
//  STSubliminalTerminal.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTerminal.h"
#import "SLTest.h"


static NSString *const SLTerminalInvalidMessageException = @"SLTerminalInvalidMessageException";


static const NSTimeInterval kDefaultHeartbeatTimeout = 5.0;


@implementation SLTerminal {
    UIButton *_outputButton;
    NSUInteger _commandIndex;
        
    dispatch_semaphore_t _dispatchSemaphore;
    dispatch_semaphore_t _responseSemaphore;
    NSString *_responsePlistPath;
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

// returns the preferences plist UIAutomation uses to respond
+ (NSString *)UIAutomationResponsePlistPath {
    NSString *responsePlistPath = nil;
    NSString *plistRootPath = nil, *relativePlistPath = nil;
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", [[NSBundle mainBundle] bundleIdentifier]];
    
#if TARGET_IPHONE_SIMULATOR
    // in the simulator, UIAutomation uses a target-specific plist in ~/Library/Application Support/iPhone Simulator/[system version]/Library/Preferences/[bundle ID].plist
    // _not_ the NSUserDefaults plist, in the sandboxed Library
    // see http://stackoverflow.com/questions/4977673/reading-preferences-set-by-uiautomations-uiaapplication-setpreferencesvaluefork

    // 1. get into the simulator's app support directory by fetching the sandboxed Library's path
    NSString *userDirectoryPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
    // 2. get out of our application directory, back to the root support directory for this system version
    plistRootPath = [userDirectoryPath substringToIndex:([userDirectoryPath rangeOfString:@"Applications"].location)];

    // 3. locate, relative to here, /Library/Preferences/[bundle ID].plist
    relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];
#else
    // on the device, UIAutomation uses the NSUserDefaults plist, in the sandboxed Library
    plistRootPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
    relativePlistPath = [NSString stringWithFormat:@"Preferences/%@", plistName];
#endif
    
    // strip "file://localhost" at beginning of path, which will screw up file reads later
    static NSString *const localhostPrefix = @"file://localhost";
    if ([plistRootPath hasPrefix:localhostPrefix]) {
        plistRootPath = [plistRootPath substringFromIndex:NSMaxRange([plistRootPath rangeOfString:localhostPrefix])];
    }
    // and unescape spaces, if necessary (i.e. in the simulator)
    NSString *unsanitizedPlistPath = [plistRootPath stringByAppendingPathComponent:relativePlistPath];
    responsePlistPath = [unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return responsePlistPath;
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

        // cache the responsePlistPath to avoid looking it up afresh each time it's to be used
        _responsePlistPath = [[self class] UIAutomationResponsePlistPath];
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

- (void)startWithCompletionBlock:(void (^)(SLTerminal *))completionBlock {
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
    
    
    // clear an old response from UIAutomation if one exists
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:_responsePlistPath];
    if ([responseDictionary objectForKey:SLTerminalInputPreferencesKey]) {
        [responseDictionary removeObjectForKey:SLTerminalInputPreferencesKey];
        [responseDictionary writeToFile:_responsePlistPath atomically:YES];
    }

    
    // register defaults with UIAutomation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setJSHeartbeatTimeout:self.heartbeatTimeout];

        // and finish
        _hasStarted = YES;
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(self);
            });
        }
    });
}

- (void)setJSHeartbeatTimeout:(NSTimeInterval)heartbeatTimeout {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self send:@"_heartbeatMonitorTimeout += %g;", heartbeatTimeout];
        });
    } else {
        [self send:@"_heartbeatMonitorTimeout += %g;", heartbeatTimeout];
    }
}

- (void)setHeartbeatTimeout:(NSTimeInterval)heartbeatTimeout {
    if (heartbeatTimeout != _heartbeatTimeout) {
        _heartbeatTimeout = heartbeatTimeout;

        // if we've already started, update the timeout;
        // otherwise we'll do it when we start
        if ([self hasStarted]) {
            [self setJSHeartbeatTimeout:heartbeatTimeout];
        }
    }
}


#pragma mark - Communication

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
        _outputButton.accessibilityValue = [NSString stringWithFormat:@"%u", _commandIndex];
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

- (BOOL)sendAndReturnBool:(NSString *)message, ... {
    NSString *formattedMessage = SLStringWithFormatAfter(message);
    return [[self send:@"((%@) ? \"YES\" : \"NO\");", formattedMessage] boolValue];
}

// note that this callback comes in on the main thread
- (void)messageReceived:(id)sender {
    _outputButton.hidden = YES;
    [_outputButton setTitle:nil forState:UIControlStateNormal];
    _commandIndex++;

    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:_responsePlistPath];
    NSString *response = [responseDictionary objectForKey:SLTerminalInputPreferencesKey];
        
    _response = response;
    
    // clear the response (if it existed), now that we've read it
    if ([response length]) {
        [responseDictionary removeObjectForKey:SLTerminalInputPreferencesKey];
        [responseDictionary writeToFile:_responsePlistPath atomically:YES];
    }

    // signal thread waiting on UIAutomation's response (in send:) to continue
    dispatch_semaphore_signal(_responseSemaphore);
}

@end
