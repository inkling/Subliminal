//
//  SLNavigationBarTestsViewController.m
//  Subliminal
//
//  Created by Jordan Zucker on 4/4/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLNavigationBarTestsViewController : SLTestCaseViewController

@end

@interface SLNavigationBarTestsViewController ()
// Connect IBOutlets here.
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@end

@implementation SLNavigationBarTestsViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLNavigationBarTestsViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    // Test case specific configuration is best done using app hooks
    // triggered from -[SLNavigationBarTests setUpTestCaseWithSelector:].
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:self action:@selector(tapRightButton:)];
    rightButton.accessibilityLabel = @"Right";
    _navBar.topItem.rightBarButtonItem = rightButton;

    _navBar.accessibilityIdentifier = @"NavigationBar";

    _navBar.topItem.title = @"Testing";
    _navBar.topItem.title.isAccessibilityElement = YES;
    _navBar.topItem.title.accessibilityLabel = _navBar.topItem.title;
}

- (IBAction)tapRightButton:(id)sender
{
    NSLog(@"hey");
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        // Register for app hooks, e.g.
        // [[SLTestController sharedTestController] registerTarget:<#(id)#> forAction:<#(SEL)#>];
    }
    return self;
}

// Deregister for app hooks, if any
//- (void)dealloc {
//    [[SLTestController sharedTestController] deregisterTarget:self];
//}

//#pragma mark - App hooks
// Put any app hooks below here

@end
