//
//  STSimpleTest.m
//  SubliminalTest
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


#import <Subliminal/Subliminal.h>


@interface STSimpleTest : SLTest
@end


@implementation STSimpleTest {
    SLTextField *_usernameField;
}

- (void)setUpTest {
    _usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
}

- (void)testThatWeCanEnterSomeText {
    NSString *const kUsername = @"Jeff";

    // use the UIAElement macro so Subliminal will log where this threw an exception (if it did)
    [UIAElement(_usernameField) setText:kUsername];

    SLAssertTrue([[UIAElement(_usernameField) text] isEqualToString:kUsername],
                 @"Username was not set to %@", kUsername);

    // wait just so the user can see that the text was entered,
    // before tear-down clears it
    [self wait:1.0];
}

- (void)tearDownTest {
    // ask the STLoginViewController to clear the login UI
    [[SLTestController sharedTestController] sendAction:@selector(resetLogin)];
}

@end
