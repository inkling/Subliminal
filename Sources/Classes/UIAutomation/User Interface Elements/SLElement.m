//
//  SLElement.m
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

#import "SLElement.h"
#import "SLUIAElement+Subclassing.h"
#import "NSObject+SLAccessibilityHierarchy.h"
#import "SLAccessibilityPath.h"
#import "NSObject+SLVisibility.h"


// The real value (set in `+load`) is not a compile-time constant,
// so we provide a placeholder here.
UIAccessibilityTraits SLUIAccessibilityTraitAny = 0;


@implementation SLElement {
    BOOL (^_matchesObject)(NSObject*);
    NSString *_description;
}

+ (void)load {
    // We create a unique `UIAccessibilityTraits` mask
    // from a combination of traits that should never occur in reality.
    // This value is not a compile-time constant, so we declare it as we load
    // (which is guaranteed to be after UIKit loads, by Subliminal linking UIKit).
    SLUIAccessibilityTraitAny = UIAccessibilityTraitNone | UIAccessibilityTraitButton;
}

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return [obj.accessibilityLabel isEqualToString:label];
    } description:label];
}

+ (id)elementWithAccessibilityLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits {
    NSString *traitsString;
    if (traits == SLUIAccessibilityTraitAny) {
        traitsString = @"(any)";
    } else {
        NSMutableArray *traitNames = [NSMutableArray array];
        
        if (traits & UIAccessibilityTraitButton)                  [traitNames addObject:@"Button"];
        if (traits & UIAccessibilityTraitLink)                    [traitNames addObject:@"Link"];
        if (traits & UIAccessibilityTraitHeader)                  [traitNames addObject:@"Header"];
        if (traits & UIAccessibilityTraitSearchField)             [traitNames addObject:@"Search Field"];
        if (traits & UIAccessibilityTraitImage)                   [traitNames addObject:@"Image"];
        if (traits & UIAccessibilityTraitSelected)                [traitNames addObject:@"Selected"];
        if (traits & UIAccessibilityTraitPlaysSound)              [traitNames addObject:@"Plays Sound"];
        if (traits & UIAccessibilityTraitKeyboardKey)             [traitNames addObject:@"Keyboard Key"];
        if (traits & UIAccessibilityTraitStaticText)              [traitNames addObject:@"Static Text"];
        if (traits & UIAccessibilityTraitSummaryElement)          [traitNames addObject:@"Summary Element"];
        if (traits & UIAccessibilityTraitNotEnabled)              [traitNames addObject:@"Not Enabled"];
        if (traits & UIAccessibilityTraitUpdatesFrequently)       [traitNames addObject:@"Updates Frequently"];
        if (traits & UIAccessibilityTraitStartsMediaSession)      [traitNames addObject:@"Starts Media Session"];
        if (traits & UIAccessibilityTraitAdjustable)              [traitNames addObject:@"Adjustable"];
        if (traits & UIAccessibilityTraitAllowsDirectInteraction) [traitNames addObject:@"Allows Direct Interaction"];
        if (traits & UIAccessibilityTraitCausesPageTurn)          [traitNames addObject:@"Causes Page Turn"];

        if ([traitNames count]) {
            traitsString = [NSString stringWithFormat:@"(%@)", [traitNames componentsJoinedByString:@", "]];
        } else {
            traitsString = @"(none)";
        }
    }

    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        BOOL matchesLabel   = ((label == nil) || [obj.accessibilityLabel isEqualToString:label]);
        BOOL matchesValue   = ((value == nil) || [obj.accessibilityValue isEqualToString:value]);
        BOOL matchesTraits  = ((traits == SLUIAccessibilityTraitAny) || ((obj.accessibilityTraits & traits) == traits));
        return (matchesLabel && matchesValue && matchesTraits);
    } description:[NSString stringWithFormat:@"label: %@; value: %@; traits: %@", label, value, traitsString]];
}

+ (instancetype)elementWithAccessibilityIdentifier:(NSString *)identifier {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        if (![obj respondsToSelector:@selector(accessibilityIdentifier)]) return NO;

        return [[obj performSelector:@selector(accessibilityIdentifier)] isEqualToString:identifier];
    } description:identifier];
}

+ (instancetype)elementMatching:(BOOL (^)(NSObject *obj))predicate withDescription:(NSString *)description {
    return [[self alloc] initWithPredicate:predicate description:description];
}

+ (instancetype)anyElement {
    return [[self alloc] initWithPredicate:^BOOL(NSObject *obj) {
        return YES;
    } description:@"any element"];
}

- (instancetype)initWithPredicate:(BOOL (^)(NSObject *))predicate description:(NSString *)description {
    self = [super init];
    if (self) {
        _matchesObject = predicate;
        _description = [description copy];
    }
    return self;
}

- (BOOL)matchesObject:(NSObject *)object
{
    NSAssert(_matchesObject, @"matchesObject called on %@, which has no _matchesObject predicate", self);
    BOOL matchesObject = _matchesObject(object);

    return (matchesObject && [object willAppearInAccessibilityHierarchy]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ description:\"%@\">", NSStringFromClass([self class]), _description];
}

- (SLAccessibilityPath *)accessibilityPathWithTimeout:(NSTimeInterval)timeout {
    __block SLAccessibilityPath *accessibilityPath = nil;
    NSDate *startDate = [NSDate date];
    // a timeout of 0 means check once--but then return immediately, no waiting
    do {
        dispatch_sync(dispatch_get_main_queue(), ^{
            accessibilityPath = [[[UIApplication sharedApplication] keyWindow] slAccessibilityPathToElement:self];
        });
        if (accessibilityPath || !timeout) break;

        [NSThread sleepForTimeInterval:SLUIAElementWaitRetryDelay];
    } while ([[NSDate date] timeIntervalSinceDate:startDate] < timeout);
    return accessibilityPath;
}

- (void)waitUntilTappable:(BOOL)waitUntilTappable
        thenPerformActionWithUIARepresentation:(void(^)(NSString *UIARepresentation))block
                                       timeout:(NSTimeInterval)timeout {
    NSTimeInterval resolutionStart = [NSDate timeIntervalSinceReferenceDate];
    SLAccessibilityPath *accessibilityPath = [self accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        [NSException raise:SLUIAElementInvalidException format:@"Element '%@' does not exist.", self];
    }

    NSTimeInterval resolutionEnd = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval resolutionDuration = resolutionEnd - resolutionStart;
    NSTimeInterval remainingTimeout = timeout - resolutionDuration;

    // It's possible, if unlikely, that one or more path components could have dropped
    // out of scope between the path's construction and its binding/serialization
    // here. If the representation is invalid, UIAutomation will throw an exception,
    // and it will be caught by Subliminal.
    NSException *__block actionException = nil;
    [accessibilityPath bindPath:^(SLAccessibilityPath *boundPath) {
        // catch and rethrow exceptions so that we can unbind the path
        @try {
            NSString *UIARepresentation = [boundPath UIARepresentation];
            if (waitUntilTappable) {
                if (![[SLTerminal sharedTerminal] waitUntilFunctionWithNameIsTrue:[[self class]SLElementIsTappableFunctionName]
                                                            whenEvaluatedWithArgs:@[ UIARepresentation ]
                                                                       retryDelay:SLUIAElementWaitRetryDelay
                                                                          timeout:remainingTimeout]) {
                    [NSException raise:SLUIAElementNotTappableException format:@"Element '%@' is not tappable.", self];
                }
            }

            block(UIARepresentation);
        }
        @catch (NSException *exception) {
            actionException = exception;
        }
    }];
    if (actionException) @throw actionException;
}

- (void)examineMatchingObject:(void (^)(NSObject *object))block {
    [self examineMatchingObject:block timeout:[[self class] defaultTimeout]];
}

- (void)examineMatchingObject:(void (^)(NSObject *))block timeout:(NSTimeInterval)timeout {
    NSParameterAssert(block);

    SLAccessibilityPath *accessibilityPath = [self accessibilityPathWithTimeout:timeout];
    if (!accessibilityPath) {
        [NSException raise:SLUIAElementInvalidException
                    format:@"Element %@ does not exist.", self];
    }

    // It's possible, if unlikely, that the matching object could have dropped
    // out of scope between the path's construction and its examination here
    __block BOOL matchingObjectWasOutOfScope = NO;
    [accessibilityPath examineLastPathComponent:^(NSObject *lastPathComponent) {
        if (!lastPathComponent) {
            matchingObjectWasOutOfScope = YES;
            return;
        }
        block(lastPathComponent);
    }];

    if (matchingObjectWasOutOfScope) {
        [NSException raise:SLUIAElementInvalidException
                    format:@"Element %@ does not exist.", self];
    }
}

- (BOOL)isValid {
    // isValid evaluates the current state, no waiting to resolve the element
    return ([self accessibilityPathWithTimeout:0.0] != nil);
}

/*
 Subliminal's implementation of -isVisible does not rely upon UIAutomation to check
 visibility of UIViews or UIAccessibilityElements, because UIAElement.isVisible()
 has a number of bugs. See SLElementVisibilityTest for more information. For some classes,
 for example those vended by UIWebBrowserView, we cannot fully determine whether or not
 they will be visible, and must depend on UIAutomation to confirm visibility.
 */
- (BOOL)isVisible {
    __block BOOL isVisible = NO;
    __block BOOL matchedObjectOfUnknownClass = NO;
    // isVisible evaluates the current state, no waiting to resolve the element
    [self examineMatchingObject:^(NSObject *object) {
        isVisible = [object slAccessibilityIsVisible];
        matchedObjectOfUnknownClass = ![object isKindOfClass:[UIView class]] && ![object isKindOfClass:[UIAccessibilityElement class]];
    } timeout:0.0];

    if (isVisible && matchedObjectOfUnknownClass) {
        isVisible = [[self waitUntilTappable:NO thenSendMessage:@"isVisible()"] boolValue];
    }

    return isVisible;
}

@end
