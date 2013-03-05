//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppContext.h>

@interface ___FILEBASENAMEASIDENTIFIER___ViewController : SLTestCaseViewController

@end

@implementation ___FILEBASENAMEASIDENTIFIER___ViewController

/**
 For every test case, EITHER return a non-nil value from nibNameForTestCase: 
 OR set self.view in loadViewForTestCase:.
 */

+ (NSString *)nibNameForTestCase:(SEL)testCase {
#warning Potentially incomplete method implementation.
    // Return the name of the nib file which contains the view
    // to be exercised by testCase.
    return nil;
}

- (void)loadViewForTestCase:(SEL)testCase {
#warning Potentially incomplete method implementation.
    // Create the view hierarchy to be exercised by testCase 
    // and assign the root view of the hierarchy to self.view.
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
