//
//  SLStaticElement.m
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
