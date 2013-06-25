//
//  SLKeyboard.m
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

#import "SLKeyboard.h"
#import "SLUIAElement+Subclassing.h"

@implementation SLKeyboard

+ (SLKeyboard *)keyboard {
    return [[self alloc] initWithUIARepresentation:@"UIATarget.localTarget().frontMostApp().keyboard()"];
}

- (void)typeString:(NSString *)string {
    // There appears to be a bug in versions of iOS prior to 6.0 which prevents
    // UIAKeyboard.typeString from working correctly for strings longer than one
    // character.  To work around this issue on older versions of iOS we send a
    // separate typeString message for each character of the string to be typed.
    NSString *escapedString = [string slStringByEscapingForJavaScriptLiteral];
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) {
        [self waitUntilTappable:YES
                thenSendMessage:@"typeString('%@')", escapedString];
    } else {
        NSString *quotedString = [NSString stringWithFormat:@"'%@'", escapedString];
        [self waitUntilTappable:YES thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
            // execute the typeString loop entirely within JavaScript, for improved performance
            [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLKeyboardTypeString"
                                                       params:@[ @"keyboard", @"string" ]
                                                         body:@"for (var i = 0; i < string.length; i++) {\
                                                                    keyboard.typeString(string[i]);\
                                                                }"
                                                     withArgs:@[ UIARepresentation, quotedString ]];
        } timeout:[[self class] defaultTimeout]];
    }
}

@end


@implementation SLKeyboardKey {
    NSString *_keyLabel;
}

+ (instancetype)elementWithAccessibilityLabel:(NSString *)label
{
    return [[self alloc] initWithAccessibilityLabel:label];
}

- (instancetype)initWithAccessibilityLabel:(NSString *)label {
    NSParameterAssert([label length]);
    
    NSString *UIARepresentation = [NSString stringWithFormat:@"UIATarget.localTarget().frontMostApp().keyboard().elements()['%@']", label];
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        _keyLabel = [label copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ label:\"%@\">", NSStringFromClass([self class]), _keyLabel];
}

@end
