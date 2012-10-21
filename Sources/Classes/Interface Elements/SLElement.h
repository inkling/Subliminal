//
//  SLElement.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - SLElement

extern NSString *const SLElementExceptionPrefix;
extern NSString *const SLElementAccessException;
extern NSString *const SLElementUIAMessageSendException;


@class SLTerminal;

@interface SLElement : NSObject

@property (nonatomic, strong, readonly) NSString *label;

+ (void)setTerminal:(SLTerminal *)terminal;

+ (id)elementWithAccessibilityLabel:(NSString *)label;

- (BOOL)isValid;
- (BOOL)isVisible;
- (void)waitUntilVisible:(NSTimeInterval)timeout;
- (void)waitUntilInvisible:(NSTimeInterval)timeout;

- (void)tap;

- (NSString *)value;

@end


#pragma mark - SLElement Subclasses

@interface SLAlert : SLElement
- (void)dismiss;
@end

@interface SLButton : SLElement
@end

@interface SLTextField : SLElement
@property (nonatomic, strong) NSString *text;
+ (id)elementWithAccessibilityLabel:(NSString *)label isSecure:(BOOL)isSecureTextField;
@end