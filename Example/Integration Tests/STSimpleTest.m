//
//  STSimpleTest.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 10/17/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
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
