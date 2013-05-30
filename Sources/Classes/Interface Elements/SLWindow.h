//
//  SLWindow.h
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLElement.h"

/**
 `SLWindow` matches instances of `UIWindow`.
 
 In particular, the singleton `+mainWindow` instance matches the application's 
 main window.
 */
@interface SLWindow : SLElement

/**
 Returns an object that represent's the application's main window.
 
 This is the window that is currently the key window (`-[[UIApplication sharedApplication] keyWindow]`).
 */
+ (SLWindow *)mainWindow;

@end
