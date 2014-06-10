//
//  SLStaticTextTest.m
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

@interface SLStaticTextTest : SLIntegrationTest

@end

@implementation SLStaticTextTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLStaticTextTestViewController";
}

- (void)testLabelCanBeFound {
    NSString *textValue = @"UILabelText";

    // SLStaticText matches UILabel control
    SLStaticText *label = [SLStaticText elementWithAccessibilityLabel:textValue];

    SLAssertTrue([[UIAElement(label) value] isEqualToString:textValue],
                 @"SLStaticText should have matched the UILabel. Actual: %@", label.value);
    SLAssertTrue([[UIAElement(label) label] isEqualToString:textValue],
                 @"SLStaticText should have matched the UILabel. Actual: %@", label.label);
    SLAssertTrue([UIAElement(label) isValidAndVisible],
                 @"SLStaticText should be valid and visible for the UILabel.");
}

- (void)testWebViewLabelCanBeFound {
    NSString *textValue = @"WebViewLabelText";

    // SLStaticText matches <div> element within a UIWebView control
    SLStaticText *webViewLabel = [SLStaticText elementWithAccessibilityLabel:textValue];

    SLAssertTrue([[UIAElement(webViewLabel) label] isEqualToString:textValue],
                 @"SLStaticText should have matched the div within the webview. Actual: %@", webViewLabel.label);
    SLAssertTrue([UIAElement(webViewLabel) isValidAndVisible],
                 @"SLStaticText should be valid and visible for the webview label.");

    // NOTE: The value of the WebView control's text element is an empty string, asserting we have consistent behavior across platforms
    SLAssertTrue([[UIAElement(webViewLabel) value] isEqualToString:@""],
                 @"SLStaticText should have matched the div within the webview. Actual: %@", webViewLabel.label);
}

@end
