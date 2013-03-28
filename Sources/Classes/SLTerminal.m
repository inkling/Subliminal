//
//  STSubliminalTerminal.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLTerminal.h"
#import "SLTest.h"


NSString *const SLTerminalJavaScriptException = @"SLTerminalJavaScriptException";

static NSString *const SLTerminalPreferencesKeyCommandIndex = @"commandIndex";
static NSString *const SLTerminalPreferencesKeyCommand      = @"command";
static NSString *const SLTerminalPreferencesKeyResultIndex  = @"resultIndex";
static NSString *const SLTerminalPreferencesKeyResult       = @"result";
static NSString *const SLTerminalPreferencesKeyException    = @"exception";

const NSTimeInterval SLTerminalReadRetryDelay = 0.1;


@implementation SLTerminal {
    dispatch_queue_t _evalQueue;
    NSUInteger _commandIndex;
}

+ (void)initialize {
    // initialize shared terminal, to prevent an SLTerminal
    // from being manually initialized prior to +sharedTerminal being invoked,
    // bypassing the assert at the top of -init
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [SLTerminal sharedTerminal];
#pragma clang diagnostic pop
}

static SLTerminal *__sharedTerminal = nil;
+ (SLTerminal *)sharedTerminal {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedTerminal = [[SLTerminal alloc] init];
    });
    return __sharedTerminal;
}

- (id)init {
    NSAssert(!__sharedTerminal, @"SLTerminal should not be initialized manually. Use +sharedTerminal instead.");
    
    self = [super init];
    if (self) {
        NSString *evalQueueName = [NSString stringWithFormat:@"com.inkling.subliminal.SLTerminal-%p.evalQueue", self];
        _evalQueue = dispatch_queue_create([evalQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_evalQueue);
}

#if TARGET_IPHONE_SIMULATOR
// in the simulator, UIAutomation uses a target-specific plist in ~/Library/Application Support/iPhone Simulator/[system version]/Library/Preferences/[bundle ID].plist
// _not_ the NSUserDefaults plist, in the sandboxed Library
// see http://stackoverflow.com/questions/4977673/reading-preferences-set-by-uiautomations-uiaapplication-setpreferencesvaluefork
- (NSString *)simulatorPreferencesPath {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *plistRootPath = nil, *relativePlistPath = nil;
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", [[NSBundle mainBundle] bundleIdentifier]];

        // 1. get into the simulator's app support directory by fetching the sandboxed Library's path
        NSString *userDirectoryPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
        // 2. get out of our application directory, back to the root support directory for this system version
        plistRootPath = [userDirectoryPath substringToIndex:([userDirectoryPath rangeOfString:@"Applications"].location)];

        // 3. locate, relative to here, /Library/Preferences/[bundle ID].plist
        relativePlistPath = [NSString stringWithFormat:@"Library/Preferences/%@", plistName];
        
        // strip "file://localhost" at beginning of path, which will screw up file reads later
        static NSString *const localhostPrefix = @"file://localhost";
        if ([plistRootPath hasPrefix:localhostPrefix]) {
            plistRootPath = [plistRootPath substringFromIndex:NSMaxRange([plistRootPath rangeOfString:localhostPrefix])];
        }
        // and unescape spaces, if necessary (i.e. in the simulator)
        NSString *unsanitizedPlistPath = [plistRootPath stringByAppendingPathComponent:relativePlistPath];
        path = [unsanitizedPlistPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    });
    return path;
}
#endif // TARGET_IPHONE_SIMULATOR


#pragma mark - Communication

/**
 * Performs a round trip to SLTerminal.js by eval'ing the javascript and returning the result of eval() or throwing an exception
 *
 * The app and script execute in lock-step order by waiting for each other to update their respective keys. The scripts polls the "commandIndex" key and
 *  waits for it to increment before eval'ing the "command" key. The app waits for the result by polling for the existence of the "resultIndex" key. The app
 *  then checks the "result" and "exception" keys for the result of eval().
 *
 * Preferences Keys
 * ----------------
 *
 * Application
 *   "commandIndex": The scripts waits for this number to increment
 *        "command": The input to eval()
 *
 * Script
 *    "resultIndex": The app waits for this number to appear
 *         "result": The output of eval(), may be empty
 *      "exception": The textual representation of a javascript exception, will be empty if no exceptions occurred.
 *
 */
- (NSString *)eval:(NSString *)javascript {
    NSAssert(![NSThread isMainThread], @"-eval: must not be called from the main thread.");

    __block NSString *exceptionMessage;
    __block NSString *result;
    dispatch_sync(_evalQueue, ^{
        // Step 1: Write the command to UIAutomation
#if TARGET_IPHONE_SIMULATOR
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[self simulatorPreferencesPath]];
        if (!prefs) {
            prefs = [NSMutableDictionary dictionary];
        }
        [prefs setObject:@( _commandIndex ) forKey:SLTerminalPreferencesKeyCommandIndex];
        [prefs setObject:javascript forKey:SLTerminalPreferencesKeyCommand];
        [prefs removeObjectForKey:SLTerminalPreferencesKeyResultIndex];
        [prefs removeObjectForKey:SLTerminalPreferencesKeyResult];
        [prefs removeObjectForKey:SLTerminalPreferencesKeyException];
        [prefs writeToFile:[self simulatorPreferencesPath] atomically:YES];
#else
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@( _commandIndex ) forKey:SLTerminalPreferencesKeyCommandIndex];
        [defaults setObject:javascript forKey:SLTerminalPreferencesKeyCommand];
        [defaults removeObjectForKey:SLTerminalPreferencesKeyResultIndex];
        [defaults removeObjectForKey:SLTerminalPreferencesKeyResult];
        [defaults removeObjectForKey:SLTerminalPreferencesKeyException];
        [defaults synchronize];
#endif

        // Step 2: Wait for the result
        NSDictionary *resultPrefs = nil;
        while (1) {
#if TARGET_IPHONE_SIMULATOR
            resultPrefs = [NSDictionary dictionaryWithContentsOfFile:[self simulatorPreferencesPath]];
#else
            [defaults synchronize];
            resultPrefs = [defaults dictionaryRepresentation];
#endif

            if (resultPrefs[SLTerminalPreferencesKeyResultIndex]) {
                NSAssert([resultPrefs[SLTerminalPreferencesKeyResultIndex] intValue] == _commandIndex, @"Result index is out of sync with command index");
                break;
            }
            [NSThread sleepForTimeInterval:SLTerminalReadRetryDelay];
        }
        _commandIndex++;

        // Step 3: Rethrow the javascript exception or return the result
        exceptionMessage = resultPrefs[SLTerminalPreferencesKeyException];
        result = resultPrefs[SLTerminalPreferencesKeyResult];
    });
    
    if (exceptionMessage) {
        @throw [NSException exceptionWithName:SLTerminalJavaScriptException reason:exceptionMessage userInfo:nil];
    } else {
        return result;
    }
}

- (NSString *)evalWithFormat:(NSString *)javascript, ... {
    va_list args;
    va_start(args, javascript);
    NSString *statement = [[NSString alloc] initWithFormat:javascript arguments:args];
    va_end(args);

    return [self eval:statement];
}

@end
