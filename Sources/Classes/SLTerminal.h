//
//  STSubliminalTerminal.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


static NSString *const SLTerminalOutputButtonAccessibilityIdentifier = @"SLTerminal_outputButton";
static NSString *const SLTerminalInputPreferencesKey = @"SLTerminal_input";

static NSString *const SLExceptionOccurredResponsePrefix = @"SLTerminalExceptionOccurred: ";


@interface SLTerminal : NSObject

@property (nonatomic, readonly) BOOL hasStarted;

@property (nonatomic) NSTimeInterval heartbeatTimeout;

+ (SLTerminal *)sharedTerminal;

- (void)startWithCompletionBlock:(void (^)(SLTerminal *))completionBlock;

// these messages should be valid JS statements
- (NSString *)eval:(NSString *)javascript;
- (NSString *)evalWithFormat:(NSString *)javascript, ... NS_FORMAT_FUNCTION(1, 2);

// this message should be a valid JS expression, but _not_ a statement
// (i.e. not semicolon-terminated)
- (BOOL)sendAndReturnBool:(NSString *)message, ... NS_FORMAT_FUNCTION(1, 2);

@end
