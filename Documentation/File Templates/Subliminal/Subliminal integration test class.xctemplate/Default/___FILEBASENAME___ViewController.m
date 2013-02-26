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
 For every test case, return a non-nil value from EITHER nibNameForTestCase: 
 OR viewForTestCase:.
 */

+ (NSString *)nibNameForTestCase:(SEL)testCase {
#warning Potentially incomplete method implementation.
    // Return the name of the nib file which contains the view
    // to be exercised by testCase.
    return nil;
}

+ (UIView *)viewForTestCase:(SEL)testCase {
#warning Potentially incomplete method implementation.
    // Return the view to be exercised by testCase.
    return nil;
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
