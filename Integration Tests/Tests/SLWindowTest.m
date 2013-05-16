//
//  SLWindowTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/16/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

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
