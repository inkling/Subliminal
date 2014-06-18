//
//  SLPickerView.m
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

#import "SLPickerView.h"
#import "SLUIAElement+Subclassing.h"

@interface SLPickerView ()
@end

@implementation SLPickerView

- (BOOL)matchesObject:(NSObject *)object {
    return ([object isKindOfClass:[UIPickerView class]] && [super matchesObject:object]);
}

- (BOOL)isVisible {
    return [[self waitUntilTappable:NO
                    thenSendMessage:@"wheels()[0].isVisible()"] boolValue];
}

- (NSUInteger)numberOfComponentsInPickerView {
    return [[self waitUntilTappable:NO
                    thenSendMessage:@"wheels().length"] unsignedIntegerValue];
}

- (NSArray *)valueOfPickerComponents {
    __block NSArray *pickerComponentValues;

    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *responseString = [[SLTerminal sharedTerminal] evalWithFormat:
                                       @"var values = [];\n"
                                        "var wheels = %@.wheels();\n"
                                        "for (var i = 0; i < wheels.length; i++) {\n"
                                        "    values.push(wheels[i].value());\n"
                                        "}\n"
                                        "JSON.stringify(values);",
                                        uiaRepresentation];
        NSData *jsonDataFromString = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSAssert(jsonDataFromString, @"`%s script failed or JSON response is malformed.", __PRETTY_FUNCTION__);
        pickerComponentValues =  (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonDataFromString
                                                                            options:0
                                                                              error:nil];
    } timeout:[[self class] defaultTimeout]];

    return pickerComponentValues;
}

// We should be waiting until the element is tappable before setting the value, but it doesn't
// fit with the existing infrastructure to get the waitUntilTappable:thenSendMessage: method
// to use an overloaded isTappable method.
- (void)selectValue:(NSString *)title forComponent:(NSUInteger)componentIndex {
    [self waitUntilTappable:NO thenSendMessage:@"wheels()[%lu].selectValue(\"%@\")",
                                    (unsigned long)componentIndex, title];
}

// Overload behavior of SLUIAElement, because testTextInputPickerViewCanBeFoundAfterTappingText
// fails saying that the element isn't tappable on iOS 6.
- (BOOL)isTappable {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        return [self isVisible];
    } else {
        return [super isTappable];
    }
}

@end
