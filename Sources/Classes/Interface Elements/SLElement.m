//
//  SLElement.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLElement.h"

#import "SLTerminal.h"
#import "SLUtilities.h"

#import <objc/runtime.h>


NSString *const SLElementExceptionPrefix = @"SLElement";
NSString *const SLElementAccessException = @"SLElementAccessException";
NSString *const SLElementUIAMessageSendException = @"SLElementUIAMessageSendException";


#pragma mark SLElement

@interface SLElement ()

@property (nonatomic, strong, readonly) NSString *label; 

+ (void)setTerminal:(SLTerminal *)terminal;

- (id)initWithAccessibilityLabel:(NSString *)label;

- (NSString *)sendMessage:(NSString *)action, ... NS_FORMAT_FUNCTION(1, 2);

@end

@interface SLElement (Subclassing)

+ (NSString *)uiaClass;
- (NSString *)uiaSelf;

@end


@implementation SLElement

static const void *const kTerminalKey = &kTerminalKey;
+ (void)setTerminal:(SLTerminal *)terminal {
    NSAssert([terminal hasStarted], @"SLElement's terminal has not yet started.");
    if (terminal != [self terminal]) {
        // note that we explicitly associate with SLElement 
        // so that subclasses can use the terminal too
        objc_setAssociatedObject([SLElement class], kTerminalKey, terminal, OBJC_ASSOCIATION_RETAIN);
    }
}

+ (SLTerminal *)terminal {
    return objc_getAssociatedObject([SLElement class], kTerminalKey);
}

+ (id)elementWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithAccessibilityLabel:label];
}

+ (NSString *)uiaPrefix {
    return @"UIATarget.localTarget().frontMostApp().mainWindow()";
}

+ (NSString *)uiaClass {
    return @"elements()";
}

- (id)initWithAccessibilityLabel:(NSString *)label {
    self = [super init];
    if (self) {
        _label = label;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label:\"%@\">", NSStringFromClass([self class]), _label];
}

#pragma mark Sending Actions

- (NSString *)uiaSelf {
    return [NSString stringWithFormat:@"%@.%@[\"%@\"]",
            [[self class] uiaPrefix], [[self class] uiaClass], _label];
}

- (BOOL)sendMessageReturningBool:(NSString *)action, ... {
    SLTerminal *terminal = [[self class] terminal];
    NSAssert(terminal, @"SLElement does not have a terminal.");

    NSString *formattedAction = SLStringWithFormatAfter(action);
    BOOL response = NO;
    @try {
        response = [[terminal send:@"(%@.%@ ? \"YES\" : \"NO\")", [self uiaSelf], formattedAction] boolValue];
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:SLElementUIAMessageSendException reason:[exception reason] userInfo:nil];
    }
    return response;
}

- (NSString *)sendMessage:(NSString *)action, ... {
    SLTerminal *terminal = [[self class] terminal];
    NSAssert(terminal, @"SLElement does not have a terminal.");
    
    NSString *formattedAction = SLStringWithFormatAfter(action);
    NSString *response = nil;
    @try {
        response = [terminal send:@"%@.%@;", [self uiaSelf], formattedAction];
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:SLElementUIAMessageSendException reason:[exception reason] userInfo:nil];
    }
    return response;
}

- (BOOL)isValid {
    return [self sendMessageReturningBool:@"isValid()"];

}

- (BOOL)isVisible {
    return [self sendMessageReturningBool:@"isVisible()"];
}

- (BOOL)waitFor:(NSTimeInterval)timeout untilCondition:(NSString *)condition, ... NS_FORMAT_FUNCTION(2, 3) {
    static const NSTimeInterval kDefaultRetryDelay = 0.25;
    BOOL conditionDidBecomeTrue =
    [[[[self class] terminal] send:
          @"(wait(function() { return (%@); }, %g, %g) ? \"YES\" : \"NO\");",
          SLStringWithFormatAfter(condition), timeout, kDefaultRetryDelay] boolValue];

    return conditionDidBecomeTrue;
}

- (void)waitUntilVisible:(NSTimeInterval)timeout {    
    if (![self waitFor:timeout untilCondition:@"%@.isVisible()", [self uiaSelf]]) {
        [NSException raise:SLElementAccessException format:@"Element %@ did not become visible within %g seconds.", self, timeout];
    }
}

- (void)waitUntilInvisible:(NSTimeInterval)timeout {
    if (![self waitFor:timeout untilCondition:@"!%@.isVisible()", [self uiaSelf]]) {
        [NSException raise:SLElementAccessException format:@"Element %@ was still visible after %g seconds.", self, timeout];
    }
}

- (void)tap {
    (void)[self sendMessage:@"tap()"];
}

- (NSString *)value {
    // must check validity before checking value:
    // UIAutomation will not warn if this element does not exist
    if (![self isValid]) {
        [NSException raise:SLElementAccessException format:@"Element %@ is not valid.", self];
    }
    
    return [self sendMessage:@"value()"];
}

@end


#pragma mark - SLAlert

@implementation SLAlert

// only one alert shows at a time, and it doesn't have an accessibility label
// -- we match the title of the alert instead
- (NSString *)uiaSelf {
    return [NSString stringWithFormat:
            @"((UIATarget.localTarget().frontMostApp().alert().staticTexts()[0].label() == \"%@\") \
                            ? UIATarget.localTarget().frontMostApp().alert() : null)", self.label];
}

- (void)dismiss {
    (void)[self sendMessage:@"defaultButton().tap()"];
}

@end

#pragma mark - SLTextField

@interface SLSecureTextField : SLTextField
@end

@implementation SLTextField

+ (id)elementWithAccessibilityLabel:(NSString *)label isSecure:(BOOL)isSecureTextField {
    Class elementClass = (isSecureTextField ? [SLSecureTextField class] : self);
    return [elementClass elementWithAccessibilityLabel:label];
}

+ (NSString *)uiaClass {
    return @"textFields()";
}

- (NSString *)text {
    return [self value];
}

- (void)setText:(NSString *)text {
    (void)[self sendMessage:@"setValue(\"%@\")", text];
}

@end

@implementation SLSecureTextField

+ (NSString *)uiaClass {
    return @"secureTextFields()";
}

@end
