//
//  SLTableViewCellChildElementsTestViewController.m
//  Subliminal
//
//  Created by Jordan Zucker on 3/20/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>

@interface SLTableViewCellChildElementsTestViewController : SLTestCaseViewController

@end

@interface SLTableViewCellChildElementsTestViewController () <UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tableViewElements;
@property (nonatomic, strong) NSMutableArray *tableViewFavorites;
@end

@implementation SLTableViewCellChildElementsTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    return @"SLTableViewCellChildElementsTestViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableViewElements = @[@"Cell 0", @"Cell 1", @"Cell 2", @"Cell 3"];
    _tableViewFavorites = [[NSMutableArray alloc] initWithObjects:@(NO), @(NO), @(NO), @(NO), nil];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
    }
    return self;
}

//#pragma mark - App hooks
// Put any app hooks below here

#pragma mark - UIButton method

- (IBAction)pressButton:(id)sender
{
    UIButton *favoriteButton = (UIButton *)sender;
    NSNumber *oldFavoriteBool = [_tableViewFavorites objectAtIndex:favoriteButton.tag];
    [self setFavoriteButton:favoriteButton withFavoriteStatus:(![oldFavoriteBool boolValue])];
}

- (void) setFavoriteButton:(UIButton *)favoriteButton withFavoriteStatus:(BOOL)favoriteBool
{
    NSString *updatedFavoriteButtonAccessibilityValue;
    UIImage *updatedFavoriteButtonImage;
    if (favoriteBool == YES) {
        updatedFavoriteButtonAccessibilityValue = @"on";
        updatedFavoriteButtonImage = [UIImage imageNamed:@"heart_icon&32.png"];

    }
    else {
        updatedFavoriteButtonAccessibilityValue = @"off";
        updatedFavoriteButtonImage = [UIImage imageNamed:@"heart_empty_icon&32.png"];
    }
    [_tableViewFavorites setObject:@(favoriteBool) atIndexedSubscript:favoriteButton.tag];
    favoriteButton.accessibilityValue = updatedFavoriteButtonAccessibilityValue;
    [favoriteButton setImage:updatedFavoriteButtonImage forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableViewElements count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault   reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [_tableViewElements objectAtIndex:indexPath.row];
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteButton.accessibilityLabel = @"Favorite";
    favoriteButton.tag = indexPath.row;

    favoriteButton.frame = CGRectMake(160.0f, 5.0f, 32.0f, 32.0f);
    [self setFavoriteButton:favoriteButton withFavoriteStatus:[[_tableViewFavorites objectAtIndex:indexPath.row] boolValue]];
    [favoriteButton addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:favoriteButton];
    
    cell.accessibilityLabel = cell.textLabel.text;
    cell.accessibilityValue = cell.textLabel.text;
    
    return cell;
}

@end
