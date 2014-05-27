//
//  SLActionSheet.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLActionSheet.h"

#import "SLUIAElement+Subclassing.h"

@implementation SLActionSheet {
    SLStaticElement *_titleLabel;
    SLStaticElement *_cancelButton;
}

+ (instancetype)currentActionSheet {
    NSString *UIARepresentation;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIARepresentation = @"UIATarget.localTarget().frontMostApp().actionSheet()";
    } else {
        // on the iPad, action sheets are always presented in popovers
        // (even if they're not presented from a view inside a popover)
        // and `UIAApplication.actionSheet()` is nonfunctional
        UIARepresentation = @"UIATarget.localTarget().frontMostApp().mainWindow().popover().actionSheet()";
    }
    return [[self alloc] initWithUIARepresentation:UIARepresentation];
}

- (instancetype)initWithUIARepresentation:(NSString *)UIARepresentation {
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        _titleLabel = [[SLStaticElement alloc] initWithUIARepresentation:[UIARepresentation stringByAppendingString:@".staticTexts()[0]"]];
        _cancelButton = [[SLStaticElement alloc] initWithUIARepresentation:[UIARepresentation stringByAppendingString:@".cancelButton()"]];
    }
    return self;
}

- (NSString *)title {
    NSString *__block title;

    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        // The title label will not exist unless the view controller has a non-empty title.
        // The default value of `-[UIActionSheet title]` is `nil`.
        title = [_titleLabel isValid] ? [_titleLabel label] : nil;
    } timeout:[[self class] defaultTimeout]];

    return title;
}

- (NSArray *)buttons {
    __block NSUInteger numberOfButtons = 0;
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        numberOfButtons = [[[SLTerminal sharedTerminal] evalWithFormat:@"%@.buttons().length", UIARepresentation] unsignedIntegerValue];
    } timeout:[[self class] defaultTimeout]];

    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:numberOfButtons];
    for (NSUInteger buttonIndex = 0; buttonIndex < numberOfButtons; buttonIndex++) {
        NSString *buttonRepresentation = [_UIARepresentation stringByAppendingFormat:@".buttons()[%lu]", (unsigned long)buttonIndex];
        SLStaticElement *button = [[SLStaticElement alloc] initWithUIARepresentation:buttonRepresentation];
        [buttons addObject:button];
    }
    return [buttons copy];
}

- (SLUIAElement *)cancelButton {
    SLUIAElement *__block cancelButton;

    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        cancelButton = _cancelButton;
    } timeout:[[self class] defaultTimeout]];

    return cancelButton;
}

@end
