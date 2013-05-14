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

@end
