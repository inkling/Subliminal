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

@implementation SLPickerView

- (BOOL)matchesObject:(NSObject *)object {
    return ([super matchesObject:object] && [object isKindOfClass:[UIPickerView class]]);
}

- (UIWindow *)accessibilityPathSearchRootElement {
    NSAssert([NSThread isMainThread],
             @"accessibilityPathSearchRootElement may only be accessed from the main thread.");

    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([[[window class] description] isEqualToString:@"UITextEffectsWindow"]) {
            return window;
        }
    };
    
    return nil;
}

- (int)numberOfComponentsInPickerView {
    return [(NSString *)[self waitUntilTappable:YES thenSendMessage:@"wheels().length"] intValue];
}

- (NSArray *)valueOfPickerComponents {
    __block NSArray *pickerComponenValues;

    [self waitUntilTappable:NO thenPerformActionWithUIARepresentation:^(NSString *uiaRepresentation) {
        NSString *responseString = [[SLTerminal sharedTerminal] evalWithFormat:@"var values = [];\n"
                                                                                "var wheels = %@.wheels();\n"
                                                                                "for (var i = 0; i < wheels.length; i++) {\n"
                                                                                "    values.push(wheels[i].value());\n"
                                                                                "}\n"
                                                                                "JSON.stringify(values);", uiaRepresentation];
        NSData *jsonDataFromString = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        pickerComponenValues =  (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonDataFromString options:0 error:nil];
    } timeout:[[self class] defaultTimeout]];

    return pickerComponenValues;
}

- (BOOL)selectValue:(NSString *)value forComponent:(int)wheelNumber {
    return [self waitUntilTappable:YES thenSendMessage:@"wheels()[%d].selectValue(\"%@\")", wheelNumber, value] == nil;
}

@end
