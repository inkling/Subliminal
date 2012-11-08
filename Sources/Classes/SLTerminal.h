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


@interface SLTerminal : NSObject

+ (SLTerminal *)sharedTerminal;

/** Evaluates JavaScript code within UIAutomation.
 
 @param javascript The input to eval(). May be an expression preceeded by zero or more statements.
 @return Returns the result of eval() as a string.
 @exception SLTerminalJavaScriptException Thrown if a JavaScript exception occurred in eval().
 */
- (NSString *)eval:(NSString *)javascript;
- (NSString *)evalWithFormat:(NSString *)javascript, ... NS_FORMAT_FUNCTION(1, 2);

@end
