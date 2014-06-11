//
//  SLStaticTextTestViewController.m
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

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLStaticTextTestViewController : SLTestCaseViewController

@end

@interface SLStaticTextTestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation SLStaticTextTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLStaticTextTestViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self webView] loadHTMLString:@"<html><body><div style=\"width: 240px; height: 240px; background-color: #ff0000; text-align: center; vertical-align: middle; line-height: 240px;\">WebViewLabelText</div></body></html>" baseURL:nil];
}

@end
