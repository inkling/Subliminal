//
//  SLActionSheetTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLActionSheetTest : SLIntegrationTest

@end

@implementation SLActionSheetTest

+ (NSString *)testCaseViewControllerClassName {
    return @"SLActionSheetTestViewController";
}

- (void)tearDownTestCaseWithSelector:(SEL)testCaseSelector {
    SLAskApp(dismissActionSheet);

    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) &&
        ((testCaseSelector == @selector(testButtonsIncludesTheCancelButtonIfPresent)) ||
         (testCaseSelector == @selector(testCanMatchCancelButton)))) {
        SLAskApp(dismissPopover);
    }

    [super tearDownTestCaseWithSelector:testCaseSelector];
}

- (void)testCanMatchActionSheet {
    SLAskApp1(showActionSheetWithInfo:, @{ @"title": @"Action!" });

    CGRect actionSheetRect, expectedActionSheetRect = [SLAskApp(actionSheetFrameValue) CGRectValue];
    SLAssertNoThrow(actionSheetRect = [[SLActionSheet currentActionSheet] rect],
                    @"An action sheet should exist.");
    SLAssertTrue(CGRectEqualToRect(actionSheetRect, expectedActionSheetRect),
                 @"The action sheet's frame does not match the expected frame.");
}

- (void)testCanReadTitle {
    NSString *actualTitle, *expectedTitle = @"Action!";
    SLAskApp1(showActionSheetWithInfo:, @{ @"title": expectedTitle });

    SLAssertNoThrow(actualTitle = [[SLActionSheet currentActionSheet] title],
                    @"Should have been able to read the action sheet's title.");
    SLAssertTrue([actualTitle isEqualToString:expectedTitle],
                 @"The action sheet's title was not equal to the expected value.");
}

- (void)testCanMatchButtons {
    NSArray *actualButtonTitles, *expectedButtonTitles = @[ @"Other Button", @"Other Other Button" ];
    // Note: the action sheet should not be presented with a cancel button here,
    // for contrast with `-testThatButtonsIncludesTheCancelButtonIfPresent`.
    SLAskApp1(showActionSheetWithInfo:, (@{
        @"otherButtonTitle1": expectedButtonTitles[0],
        @"otherButtonTitle2": expectedButtonTitles[1]
    }));

    SLAssertNoThrow(actualButtonTitles = [[[SLActionSheet currentActionSheet] buttons] valueForKey:@"label"],
                    @"Should have been able to retrieve the titles of the action sheet buttons.");
    SLAssertTrue([actualButtonTitles isEqualToArray:expectedButtonTitles],
                 @"The titles of the action sheet buttons were not read as expected: %@", actualButtonTitles);
}

- (void)testButtonsIncludesTheCancelButtonIfPresent {
    NSArray *actualButtonTitles, *expectedButtonTitles = @[ @"Other Button", @"Other Other Button", @"Cancel" ];
    // `-testCanMatchButtons` verifies that the array will not include an invalid
    // cancel button element if the cancel button isn't present.
    SLAskApp1(showActionSheetWithInfo:, (@{
        @"otherButtonTitle1": expectedButtonTitles[0],
        @"otherButtonTitle2": expectedButtonTitles[1],
        @"cancelButtonTitle": expectedButtonTitles[2],
        // On the iPad, `UIActionSheet` will not show a cancel button unless it is shown in a popover.
        @"showInPopover": @([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    }));

    SLAssertNoThrow(actualButtonTitles = [[[SLActionSheet currentActionSheet] buttons] valueForKey:@"label"],
                    @"Should have been able to retrieve the titles of the action sheet buttons.");
    SLAssertTrue([actualButtonTitles isEqualToArray:expectedButtonTitles],
                 @"The titles of the action sheet buttons were not read as expected: %@", actualButtonTitles);
}

- (void)testCanMatchCancelButton {
    NSString *actualCancelButtonTitle, *expectedCancelButtonTitle = @"Get Out of Here";
    SLAskApp1(showActionSheetWithInfo:, (@{
        @"cancelButtonTitle": expectedCancelButtonTitle,
        // On the iPad, `UIActionSheet` will not show a cancel button unless it is shown in a popover.
        @"showInPopover": @([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    }));
    [self wait:5.0];

    SLAssertNoThrow(actualCancelButtonTitle = [[[SLActionSheet currentActionSheet] cancelButton] label],
                    @"Should have been able to retrieve the title of the action sheet's cancel button.");
    SLAssertTrue([actualCancelButtonTitle isEqualToString:expectedCancelButtonTitle],
                 @"The action sheet's cancel button did not have the expected title.");
}

- (void)testCancelButtonIsInvalidIfThereIsNoCancelButton {
    SLAskApp1(showActionSheetWithInfo:, @{ @"title": @"Action!" });

    BOOL cancelButtonIsValid = NO;
    SLAssertNoThrow(cancelButtonIsValid = [[[SLActionSheet currentActionSheet] cancelButton] isValid],
                    @"It should have been safe to access the action sheet's cancel button even though the button doesn't exist.");
    SLAssertFalse(cancelButtonIsValid,
                  @"The action sheet's cancel button should be invalid.");

}

@end
