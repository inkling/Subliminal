//
//  SLUIAElement.m
//  Subliminal
//
//  Created by Jeffrey Wear on 9/4/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLUIAElement.h"
#import "SLUIAElement+Subclassing.h"

#import <objc/runtime.h>


// all exceptions thrown by SLUIAElement must have names beginning with this prefix
// so that -[SLTest logException:inTestCase:] uses the proper logging format
NSString *const SLUIAElementExceptionNamePrefix    = @"SLUIAElement";

NSString *const SLUIAElementInvalidException       = @"SLUIAElementInvalidException";
NSString *const SLUIAElementNotTappableException   = @"SLUIAElementNotTappableException";

const NSTimeInterval SLUIAElementWaitRetryDelay = 0.25;

const CGPoint SLCGPointNull = (CGPoint){ INFINITY, INFINITY };

BOOL SLCGPointIsNull(CGPoint point) {
    return CGPointEqualToPoint(point, SLCGPointNull);
}


@implementation SLUIAElement

static const void *const kDefaultTimeoutKey = &kDefaultTimeoutKey;
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
    if (defaultTimeout != [self defaultTimeout]) {
        // note that we explicitly associate with SLUIAElement
        // so that subclasses can reference the timeout too
        objc_setAssociatedObject([SLUIAElement class], kDefaultTimeoutKey, @(defaultTimeout), OBJC_ASSOCIATION_RETAIN);
    }
}

+ (NSTimeInterval)defaultTimeout {
    return (NSTimeInterval)[objc_getAssociatedObject([SLUIAElement class], kDefaultTimeoutKey) doubleValue];
}

- (id)waitUntilTappable:(BOOL)waitUntilTappable
        thenSendMessage:(NSString *)action, ... {
    va_list(args);
    va_start(args, action);
    NSString *formattedAction = [[NSString alloc] initWithFormat:action arguments:args];
    va_end(args);
    
    id __block returnValue = nil;
    [self waitUntilTappable:waitUntilTappable
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        returnValue = [[SLTerminal sharedTerminal] evalWithFormat:@"%@.%@", uiaRepresentation, formattedAction];
    } timeout:[[self class] defaultTimeout]];
    
    return returnValue;
}

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void (^)(NSString *UIARepresentation))block
                                       timeout:(NSTimeInterval)timeout {
    NSAssert(NO, @"Concrete subclasses of SLElement must implement %@", NSStringFromSelector(_cmd));
}

- (BOOL)isValid {
    NSAssert(NO, @"Concrete subclasses of SLElement must implement %@", NSStringFromSelector(_cmd));
    return NO;
}

- (BOOL)isVisible {
    __block BOOL isVisible;
    // isVisible evaluates the current state, no waiting to resolve the element
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        isVisible = [[[SLTerminal sharedTerminal] evalWithFormat:@"%@.isVisible()", UIARepresentation] boolValue];
    } timeout:0.0];
    return isVisible;
}

- (BOOL)isValidAndVisible {
    return [self isValid] && [self isVisible];
}

- (BOOL)isInvalidOrInvisible {
    return ![self isValidAndVisible];
}

+ (NSString *)SLElementIsTappableFunctionName {
    static NSString *const SLElementIsTappableFunctionName = @"SLElementIsTappable";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SLTerminal sharedTerminal] loadFunctionWithName:SLElementIsTappableFunctionName
                                                   params:@[ @"element" ]
                                                     body:@"return (element.hitpoint() != null);"];
    });
    return SLElementIsTappableFunctionName;
}

- (BOOL)isTappable {
    __block BOOL isTappable;
    // isTappable evaluates the current state, no waiting to resolve the element
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        isTappable = [[[SLTerminal sharedTerminal] evalFunctionWithName:[[self class] SLElementIsTappableFunctionName]
                                                               withArgs:@[ uiaRepresentation ]] boolValue];
    } timeout:0.0];
    return isTappable;
}

- (void)tap {
    [self waitUntilTappable:YES thenSendMessage:@"tap()"];
}

- (void)dragWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    [self waitUntilTappable:YES
           thenSendMessage:@"dragInsideWithOptions({startOffset:{x:%f, y:%f}, endOffset:{x:%f, y:%f}, duration:1.0})",
                             startPoint.x, startPoint.y, endPoint.x, endPoint.y];
}

- (NSString *)label {
    return [self waitUntilTappable:NO thenSendMessage:@"label()"];
}

- (NSString *)value {
    return [self waitUntilTappable:NO thenSendMessage:@"value()"];
}

- (CGPoint)hitpoint {
    NSString *__block CGHitpointString = nil;
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *hitpointString = [NSString stringWithFormat:@"%@.hitpoint()", uiaRepresentation];
        CGHitpointString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLCGPointStringFromJSPoint"
                                                                      params:@[ @"point" ]
                                                                        body:@"if (!point) return '';\
                                                                               else return '{' + point.x + ',' + point.y + '}';"
                                                                    withArgs:@[ hitpointString ]];
    } timeout:[[self class] defaultTimeout]];
    return ([CGHitpointString length] ? CGPointFromString(CGHitpointString) : SLCGPointNull);
}

- (CGRect)rect {
    NSString *__block CGRectString = nil;
    [self waitUntilTappable:NO
          thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *rectString = [NSString stringWithFormat:@"%@.rect()", uiaRepresentation];
        CGRectString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLCGRectStringFromJSRect"
                                                                  params:@[ @"rect" ]
                                                                    body:@"if (!rect) return '';\
                                                                           else return '{{' + rect.origin.x + ',' + rect.origin.y + '},\
                                                                                         {' + rect.size.width + ',' + rect.size.height + '}}';"
                                                                withArgs:@[ rectString ]];
    } timeout:[[self class] defaultTimeout]];
    return ([CGRectString length] ? CGRectFromString(CGRectString) : CGRectNull);
}

- (void)logElement {
    [self waitUntilTappable:NO thenSendMessage:@"logElement()"];
}

- (void)logElementTree {
    [self waitUntilTappable:NO thenSendMessage:@"logElementTree()"];
}

@end
