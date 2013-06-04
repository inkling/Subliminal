//
//  SLUIAElement.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013 Inkling Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
+ (void)setDefaultTimeout:(NSTimeInterval)timeout {
    if (timeout != [self defaultTimeout]) {
        // note that we explicitly associate with SLUIAElement
        // so that subclasses can reference the timeout too
        objc_setAssociatedObject([SLUIAElement class], kDefaultTimeoutKey, @(timeout), OBJC_ASSOCIATION_RETAIN);
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

- (BOOL)isEnabled {
    return [[self waitUntilTappable:NO thenSendMessage:@"isEnabled()"] boolValue];
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

/*
 We must rely on UIAutomation to simulate user interaction, and so use 
 UIAutomation to determine tappability. Unfortunately, UIAutomation appears 
 to use `UIAElement.isVisible` to determine the availability of an element's 
 `hitpoint` (which in turn determines its tappability), and so `isTappable`
 exhibits some of the same issues as `UIAElement.isVisible` (see the class 
 description of `SLElementVisibilityTest`).
 
 Instances of `SLElement` could constrain this method's response by true visibility,
 but that would inflict a performance penalty on every message that involved user 
 interaction, when `UIAElement.isVisible` is mostly correct. Also, while 
 `-isVisible` must reflect visibility as truly as possible, tappability need not.
 */
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

- (void)dragWithStartOffset:(CGPoint)startOffset endOffset:(CGPoint)endOffset
{
    // Points must be passed in floating point format for UIAutomation
    // to interpret them as relative offsets.
    // If they were passed as integers, it would interpret them as absolute positions.
    [self waitUntilTappable:YES
           thenSendMessage:@"dragInsideWithOptions({startOffset:{x:%f, y:%f}, endOffset:{x:%f, y:%f}, duration:1.0})",
                             startOffset.x, startOffset.y, endOffset.x, endOffset.y];
}

- (void)scrollToVisible {
    [self waitUntilTappable:NO thenSendMessage:@"scrollToVisible()"];
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
