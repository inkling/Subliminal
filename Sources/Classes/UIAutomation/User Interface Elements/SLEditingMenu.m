//
//  SLEditingMenu.m
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

#import "SLEditingMenu.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLEditingMenu

+ (instancetype)menu {
    return [[self alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().editingMenu()"];
}

@end


@implementation SLEditingMenuItem {
    NSString *_label;
}

+ (instancetype)itemWithAccessibilityLabel:(NSString *)label {
    return [[self alloc] initWithAccessibilityLabel:label];
}

- (instancetype)initWithAccessibilityLabel:(NSString *)label {
    NSParameterAssert([label length]);

    NSString *escapedLabel = [label slStringByEscapingForJavaScriptLiteral];
    NSString *UIARepresentation = [NSString stringWithFormat:@"((function(){\
        var items = UIATarget.localTarget().frontMostApp().editingMenu().elements();"
        // the editing menu may contain multiple items with the same name (one system, one custom),
        // only one of which is actually visible in the menu (has a non-zero size),
        // so we must search through the array rather than retrieving the item by name
        @"var item = null; \
        if (items.toArray().some(function(elem) {\
            item = elem;\
            return ((elem.name() === '%@') && (elem.rect().size.width > 0));\
        })) {\
            return item;\
        } else {"
            // return whatever element the menu would have returned
            @"return items['%@'];\
        }\
    })())", escapedLabel, escapedLabel];
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        _label = [label copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label:\"%@\">", NSStringFromClass([self class]), _label];
}

@end
