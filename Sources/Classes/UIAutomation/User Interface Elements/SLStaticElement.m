//
//  SLStaticElement.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/15/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLStaticElement.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLStaticElement {
    NSString *_UIARepresentation;
}

- (instancetype)initWithUIARepresentation:(NSString *)UIARepresentation {
    NSParameterAssert([UIARepresentation length]);

    self = [super init];
    if (self) {
        _UIARepresentation = [UIARepresentation copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>", NSStringFromClass([self class])];
}

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void (^)(NSString *UIARepresentation))block
                                       timeout:(NSTimeInterval)timeout {
    NSString *isValid = [NSString stringWithFormat:@"%@.isValid()", _UIARepresentation];
    NSTimeInterval resolutionStart = [NSDate timeIntervalSinceReferenceDate];
    if (![[SLTerminal sharedTerminal] waitUntilTrue:isValid
                                         retryDelay:SLUIAElementWaitRetryDelay
                                            timeout:timeout]) {
        [NSException raise:SLUIAElementInvalidException
                    format:@"Element '%@' does not exist.", self];
    }
    NSTimeInterval resolutionEnd = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval resolutionDuration = resolutionEnd - resolutionStart;
    NSTimeInterval remainingTimeout = timeout - resolutionDuration;
    
    if (waitUntilTappable) {
        if (![[SLTerminal sharedTerminal] waitUntilFunctionWithNameIsTrue:[[self class] SLElementIsTappableFunctionName]
                                                    whenEvaluatedWithArgs:@[ _UIARepresentation ]
                                                               retryDelay:SLUIAElementWaitRetryDelay
                                                                  timeout:remainingTimeout]) {
            [NSException raise:SLUIAElementNotTappableException format:@"Element '%@' is not tappable.", self];
        }
    }

    block(_UIARepresentation);
}

- (BOOL)isValid {
    // isValid evaluates the current state, no waiting to resolve the element
    return [[[SLTerminal sharedTerminal] evalWithFormat:@"%@.isValid()", _UIARepresentation] boolValue];
}

@end
