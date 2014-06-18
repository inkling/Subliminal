//
//  SLDatePicker.m
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

#import "SLDatePicker.h"
#import "SLUIAElement+Subclassing.h"

#import "SLPickerView.h"
#import "NSObject+SLAccessibilityHierarchy.h"

/**
 The UIDatePicker element contains a child UIAPicker subclass (_UIDatePickerView). We match on the
 UIDatePicker control, and then find the pickerView beneath it to interact with.
 */
@implementation SLDatePicker {
    SLPickerView *_pickerView;
}

- (instancetype)initWithPredicate:(BOOL (^)(NSObject *))predicate description:(NSString *)description {
    self = [super initWithPredicate:predicate description:description];
    if (self) {
        __typeof(self) __weak weakSelf = self;
        _pickerView = [SLPickerView elementMatching:^BOOL(NSObject *obj) {
            id parent = [obj slAccessibilityParent];
            do {
                if ([weakSelf matchesObject:parent]) return YES;
            } while ((parent = [parent slAccessibilityParent]));
            return NO;
        } withDescription:@"UIDatePicker's internal UIPickerView subclass"];
    }
    return self;
}

- (BOOL)matchesObject:(NSObject *)object {
    return [super matchesObject:object] && [object isKindOfClass:[UIDatePicker class]];
}

- (NSUInteger)numberOfComponentsInPickerView {
    return [_pickerView numberOfComponentsInPickerView];
}

- (NSArray *)valueOfPickerComponents {
    return [_pickerView valueOfPickerComponents];
}

- (void)selectValue:(NSString *)title forComponent:(NSUInteger)componentIndex {
    [_pickerView selectValue:title forComponent:componentIndex];
}

@end
