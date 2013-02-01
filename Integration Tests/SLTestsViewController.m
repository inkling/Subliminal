//
//  SLTestsViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 1/31/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestsViewController.h"

@implementation SLTestsViewController {
    NSArray *_tests;
}

- (instancetype)initWithTests:(NSArray *)tests {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _tests = [tests copy];
    }
    return self;
}

- (NSString *)title {
    return @"Tests";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class testClass = [_tests objectAtIndex:indexPath.row];

    static NSString *TestCellIdentifier = @"SLTestCell";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TestCellIdentifier];
    });
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TestCellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = NSStringFromClass(testClass);
    
    return cell;
}

@end
