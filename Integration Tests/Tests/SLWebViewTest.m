//
//  SLWebViewTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/11/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLWebViewTest : SLIntegrationTest

@end

@implementation SLWebViewTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLWebViewTestViewController";
}

- (void)setUpTestCaseWithSelector:(SEL)testCaseSelector {
    [super setUpTestCaseWithSelector:testCaseSelector];

    SLAssertTrueWithTimeout(SLAskAppYesNo(webViewDidFinishLoad), 5.0,
                            @"Webview did not load test HTML.");
}

- (void)testMatchingWebView {
    NSString *expectedWebViewLabel;
    SLAssertNoThrow(expectedWebViewLabel = [UIAElement([SLWebView anyElement]) label],
                    @"Should not have thrown.");
    NSString *actualWebViewLabel = SLAskApp(webViewLabel);
    SLAssertTrue([expectedWebViewLabel isEqualToString:actualWebViewLabel],
                 @"Did not match web view as expected.");
}

@end
