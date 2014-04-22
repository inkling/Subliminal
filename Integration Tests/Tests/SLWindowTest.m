//
//  SLWindowTest.m
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

#import "SLIntegrationTest.h"
#import <Subliminal/SLTerminal.h>

@interface SLWindowTest : SLIntegrationTest

@end

@implementation SLWindowTest {
    NSString *_defaultKeyWindowValue;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLWindowTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    if (testCaseSelector == @selector(testMatchingMainWindow)) {
        _defaultKeyWindowValue = SLAskApp1(setKeyWindowValue:, @"main window");
    }
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    if (testCaseSelector == @selector(testMainWindow)) {
        (void)SLAskApp1(setKeyWindowValue:, _defaultKeyWindowValue);
    }
    
    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)testMatchingMainWindow {
    NSString *expectedMainWindowValue;
    SLAssertNoThrow(expectedMainWindowValue = [UIAElement([SLWindow mainWindow]) value],
                    @"Should not have thrown.");
    NSString *actualMainWindowValue = [[SLTerminal sharedTerminal] eval:@"UIATarget.localTarget().frontMostApp().mainWindow().value()"];
    SLAssertTrue([expectedMainWindowValue isEqualToString:actualMainWindowValue],
                 @"[SLWindow mainWindow] did not match expected object.");
}

@end
