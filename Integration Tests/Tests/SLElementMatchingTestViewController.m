//
//  SLElementMatchingTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLElementMatchingTestViewController : SLTestCaseViewController <UITableViewDataSource>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@end

@interface SLElementMatchingTestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fooButton;
@end

@implementation SLElementMatchingTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    if (testCase == @selector(testElementWithAccessibilityLabel)) {
        return @"SLElementMatchingTestViewController";
    } else if (testCase == @selector(testMatchingTableViewChildElement) || testCase == @selector(testTappingTableViewChildElement)) {
        return @"SLTableViewChildElementMatchingTestViewController";
    } else {
        return nil;
    }
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fooButton.accessibilityLabel = @"foo";
    self.fooButton.accessibilityValue = @"fooValue";
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"foo";
    return cell;
}

@end
