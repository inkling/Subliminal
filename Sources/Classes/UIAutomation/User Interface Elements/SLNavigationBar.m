//
//  SLNavigationBar.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLNavigationBar.h"

#import "SLUIAElement+Subclassing.h"

@implementation SLNavigationBar {
    SLStaticElement *_titleLabel;
    SLStaticElement *_leftButton, *_rightButton;
}

+ (instancetype)currentNavigationBar {
    /*
     On iOS 6, UIAutomation can get confused if there are multiple nav bars on-screen
     (for instance, on the iPad with one in a modal controller and one in the background)
     so rather than use `UIATarget.localTarget().frontMostApp().navigationBar()`,
     we use the last (frontmost) nav bar within the main window.
     
     We define the navigation bar getter as a standalone function
     (rather than an immediately-evaluated function expression) so that
     the `-description` of the navigation bar will be more concise.
     */
    static NSString *const kCurrentNavigationBarFunctionName = @"SLNavigationBarCurrentNavigationBar";
    [[SLTerminal sharedTerminal] loadFunctionWithName:kCurrentNavigationBarFunctionName
                                               params:nil
                                                 body:[NSString stringWithFormat:@"\
        var navigationBars = UIATarget.localTarget().frontMostApp().mainWindow().navigationBars().toArray();\
        if (navigationBars.length) {\
            return navigationBars[navigationBars.length - 1];\
        } else {"
            // return `UIAElementNil`
            // I don't know how to create it,
            // so get a reference to it by attempting to retrieve an element guaranteed not to exist
            @"return UIATarget.localTarget().frontMostApp().elements()['%@: %p'];\
        }\
        ", NSStringFromClass(self), self]];
    
    NSString *namespacedCurrentComposeViewFunctionName = [NSString stringWithFormat:@"%@.%@",
                                                          [[SLTerminal sharedTerminal] scriptNamespace], kCurrentNavigationBarFunctionName];
    return [[self alloc] initWithUIARepresentation:[NSString stringWithFormat:@"%@()", namespacedCurrentComposeViewFunctionName]];
}

- (instancetype)initWithUIARepresentation:(NSString *)UIARepresentation {
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        _titleLabel = [[SLStaticElement alloc] initWithUIARepresentation:[UIARepresentation stringByAppendingString:@".staticTexts()[0]"]];
        _leftButton = [[SLStaticElement alloc] initWithUIARepresentation:[UIARepresentation stringByAppendingString:@".leftButton()"]];
        _rightButton = [[SLStaticElement alloc] initWithUIARepresentation:[UIARepresentation stringByAppendingString:@".rightButton()"]];
    }
    return self;
}

- (NSString *)title {
    NSString *__block title;

    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        // The title label will not exist unless the view controller has a non-empty title.
        // The default value of `-[UIViewController title]` is `nil`.
        title = [_titleLabel isValid] ? [_titleLabel label] : nil;
    } timeout:[[self class] defaultTimeout]];

    return title;
}

- (SLUIAElement *)leftButton {
    SLUIAElement *__block leftButton;

    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        leftButton = _leftButton;
    } timeout:[[self class] defaultTimeout]];

    return leftButton;
}

- (SLUIAElement *)rightButton {
    SLUIAElement *__block rightButton;

    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        rightButton = _rightButton;
    } timeout:[[self class] defaultTimeout]];

    return rightButton;
}

@end
