//
//  SLElementVisibilityTest.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/23/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLIntegrationTest.h"

@interface SLElementVisibilityTest : SLIntegrationTest

@end

@implementation SLElementVisibilityTest {
    SLElement *_testElement;
}

+ (NSString *)testCaseViewControllerClassName {
    return @"SLElementVisibilityTestViewController";
}

- (void)setUpTest {
    [super setUpTest];
    
    _testElement = [SLElement elementWithAccessibilityLabel:@"test"];
}

#pragma mark - Test isVisible for elements that are views

- (void)testViewIsNotVisibleIfItIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(showTestView);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfSuperviewIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(showTestViewSuperview);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItHasAlphaBelow0_01 {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(increaseTestViewAlpha);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(moveTestViewOnscreen);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testViewIsNotVisibleIfItsCenterIsCovered {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(uncoverTestView);
    
    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

#pragma mark - Test isVisible for elements that are not views

- (void)testAccessibilityElementIsNotVisibleIfContainerIsHidden {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(showTestView);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItIsOffscreen {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(moveTestViewOnscreen);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByView {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    // the test view is the container of the test element
    SLAskApp(uncoverTestView);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

- (void)testAccessibilityElementIsNotVisibleIfItsCenterIsCoveredByElement {
    SLAssertFalse([_testElement isVisible], @"Test element should not be visible.");

    SLAskApp(uncoverTestElement);

    SLAssertTrue([_testElement isVisible], @"Test element should be visible.");
}

@end
