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

+ (id)sharedTerminal;

- (void)startWithCompletionBlock:(void (^)(SLTerminal *))completionBlock;

- (NSString *)send:(NSString *)message, ... NS_FORMAT_FUNCTION(1,2);
- (NSString *)send:(NSString *)message args:(va_list)args;

@end
