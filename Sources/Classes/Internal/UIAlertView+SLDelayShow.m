//
// Created by Tadeas Kriz on 06/04/14.
// Copyright (c) 2014 Inkling. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+SLDelayShow.h"
#import "SLAlert.h"
#import "SLLogger.h"

@implementation UIAlertView (SLDelayShow)

+ (void)load {
    Method show = class_getInstanceMethod(self, @selector(show));
    Method originalShow = class_getInstanceMethod(self, @selector(original_show));
    Method delayedShow = class_getInstanceMethod(self, @selector(delayed_show));

    IMP original = method_getImplementation(show);
    IMP delayed = method_getImplementation(delayedShow);

    // We need to swap implementations of the original UIAlertView's show and our delayed_show methods.
    method_setImplementation(originalShow, original);
    method_setImplementation(show, delayed);
}

- (void)original_show {
    // This method should have no implementation, because it is used to store original implementation of show method
}

- (void)delayed_show {
    if ([SLAlertHandler UIAAlertHandlingLoaded]) {
        if ([SLAlertHandler loggingEnabled]) {
            SLLogAsync(@"UIAAlertHandling is loaded.");
        }
        [self original_show];
        return;
    }


    if ([SLAlertHandler loggingEnabled]) {
        SLLogAsync(@"UIAALertHandling is not loaded. Waiting.");
    }
    // We wait 100 ms and then try to show again.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if ([SLAlertHandler loggingEnabled]) {
            SLLogAsync(@"Retrying [UIAlertView show]");
        }
        [self show];
    });

}

@end