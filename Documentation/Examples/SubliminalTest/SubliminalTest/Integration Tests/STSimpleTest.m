//
//  STSimpleTest.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 10/17/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "STSimpleTest.h"

@implementation STSimpleTest {
    SLTextField *_usernameField;
}

- (void)setUpTestCaseWithSelector:(SEL)testSelector {
    _usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
}

- (void)testThatWeCanEnterSomeText {
    NSString *username = @"Jeff";
    // this shouldn't throw an exception
    [UIAElement(_usernameField) setText:username];
    // and this should be true
    SLAssertTrue([[UIAElement(_usernameField) text] isEqualToString:username], @"Username was not set to %@", username);
}

- (void)tearDownTestCaseWithSelector:(SEL)testSelector {
    if (testSelector == @selector(testThatWeCanEnterSomeText)) {
        [self.testController sendAction:@selector(resetLogin)];
    }
}

@end
