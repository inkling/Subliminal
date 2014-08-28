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

+ (NSString *)SLElementIsTappableFunctionName {
    // UIAutomation reports that picker views are never tappable on iOS 6,
    // but we can check the first wheel instead. If there is no wheel
    // then we've just got to return `NO` but there'd be nothing to tap anyway.
    if (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1) {
        static NSString *const SLPickerViewIsTappableFunctionName = @"SLPickerViewIsTappable";
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[SLTerminal sharedTerminal] loadFunctionWithName:SLPickerViewIsTappableFunctionName
                                                       params:@[ @"element" ]
                                                         body:@"return (element.wheels().length &&\
                                                                       (element.wheels()[0].hitpoint() != null));"];
        });
        return SLPickerViewIsTappableFunctionName;
    } else {
        return [super SLElementIsTappableFunctionName];
    }
}

- (BOOL)matchesObject:(NSObject *)object {
    return ([object isKindOfClass:[UIPickerView class]] && [super matchesObject:object]);
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

- (void)selectValue:(NSString *)title forComponent:(NSUInteger)componentIndex {
    [self waitUntilTappable:YES thenSendMessage:@"wheels()[%lu].selectValue(\"%@\")",
                                    (unsigned long)componentIndex, title];
}

@end
