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
// ???: Are both the below necessary?
extern NSString *const SLElementAccessException;
extern NSString *const SLElementUIAMessageSendException;



@interface SLElement : NSObject

@property (nonatomic, strong, readonly) NSString *label;

// Defaults - to be set by the test controller, from the testing thread.
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout;


+ (id)elementWithAccessibilityLabel:(NSString *)label;

// If the UIAccessibilityElement corresponding to the receiver does not exist,
// isValid and isVisible will return NO.
// All other methods below will throw an SLElementAccessException.
- (BOOL)isValid;
- (void)waitUntilVisible:(NSTimeInterval)timeout;
- (void)waitUntilInvisible:(NSTimeInterval)timeout;

- (void)tap;

- (NSString *)value;

- (void)logElement;
- (void)logElementTree;

@end


#pragma mark - SLElement Subclasses

@interface SLAlert : SLElement
- (void)dismiss;
@end

@interface SLButton : SLElement
@end

@interface SLTextField : SLElement
@property (nonatomic, strong) NSString *text;
@end

// Instances always refer to mainWindow()
@interface SLWindow : SLElement
+ (SLWindow *)mainWindow;
@end
