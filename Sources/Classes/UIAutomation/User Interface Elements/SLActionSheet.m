//
//  SLActionSheet.m
//  Subliminal
//
//  For details and documentation:
//  http://github.com/inkling/Subliminal
//
//  Copyright 2013-2014 Inkling Systems, Inc.
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

#import "SLActionSheet.h"
#import "SLUIAElement+Subclassing.h"
#import "SLPopover.h"

@implementation SLActionSheet

+ (instancetype)currentActionSheet {
    return [[SLActionSheet alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().mainWindow().popover().actionSheet()"];
}

- (void)dismiss {
    /*
     This action sheet is inside the current popover, so dismiss that popover
     */
    [[SLPopover currentPopover] dismiss];
}

- (void)clickButtonWithAccessibilityLabel:(NSString *)label
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0.0" options:NSNumericSearch] != NSOrderedAscending) {
        [self waitUntilTappable:NO thenSendMessage:@"collectionViews()[0].cells()[\"%@\"].buttons()[\"%@\"].tap()", label, label];
    } else {
        [self waitUntilTappable:NO thenSendMessage:@"buttons()[\"%@\"].tap()", label];
    }

    // wait for the dismissal animation to finish
    [NSThread sleepForTimeInterval:0.5];
}

@end
