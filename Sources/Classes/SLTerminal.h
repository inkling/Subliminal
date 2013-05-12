//
//  STSubliminalTerminal.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/1/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern NSString *const SLTerminalJavaScriptException;

extern const NSTimeInterval SLTerminalReadRetryDelay;


@interface SLTerminal : NSObject

+ (SLTerminal *)sharedTerminal;

/**
 Evaluates the specified JavaScript within UIAutomation and returns the 
 result as an Objective-C object.

 The evaluation is done using eval().

 @param script The script to evaluate. May be a JavaScript expression, statement, 
 or sequence of statements.
 @return Returns the value of the last expression evaluated, as an Objective-C object:
 
 - If the value is of type "string", -eval: will return an NSString * that is
 equal to the value.
 - If the value is of type "boolean", -eval: will return an NSNumber * whose
 -boolValue is equal to the value.
 - If the value is of type "number", -eval: will return an NSNumber * whose 
 primitive value (using an accessor appropriate to the value's format) is equal 
 to the value.
 - Otherwise, -eval: will return nil.

 @exception SLTerminalJavaScriptException if the script could not be evaluated,
 or if the script threw an exception when evaluated.
 */
- (id)eval:(NSString *)script;
- (id)evalWithFormat:(NSString *)script, ... NS_FORMAT_FUNCTION(1, 2);

/**
 Causes SLTerminal.js to finish evaluating commands.

 The terminal starts up automatically when the UIAutomation instrument is attached
 and evaluating SLTerminal.js. SLTerminal.js then evaluates commands (scripts) 
 sent through this terminal until this method is called, at which point 
 SLTerminal.js will exit, and UIAutomation will terminate the application.
 
 This method is called by the shared test controller when testing has finished.

 */
- (void)shutDown;

@end


@interface SLTerminal (Internal)

/** The namespace (in SLTerminal.js) in which the SLTerminal defines variables. */
@property (nonatomic, readonly) NSString *scriptNamespace;

/** The serial queue on which the receiver evaluates all Javascript. */
@property (nonatomic, readonly) dispatch_queue_t evalQueue;

@end
