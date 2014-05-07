//
//  SLEditingMenu.h
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

#import "SLStaticElement.h"

/**
 The singleton `SLEditingMenu` instance allows you to manipulate your application's editing menu
 --the menu that shows commands like Cut, Copy, and Paste when the user selects text.
 */
@interface SLEditingMenu : SLStaticElement

/**
 Returns an element representing the application's editing menu.
 
 @return An element representing the application's editing menu.
 */
+ (instancetype)menu;

@end


/**
 Instances of `SLEditingMenuItem` refer to items shown by the application's editing menu.
 */
@interface SLEditingMenuItem : SLStaticElement

/**
 Creates and returns an element which represents the menu item with the specified label.
 
 This is the designated initializer for a menu item.
 
 @param label The item's accessibility label.
 @return A newly created element representing the menu item with the specified label.
 */
+ (instancetype)itemWithAccessibilityLabel:(NSString *)label;

@end
