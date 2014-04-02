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

    // Do any additional setup after loading the view from its nib.
    // Test case specific configuration is best done using app hooks
    // triggered from -[SLTableViewCellChildElementsTests setUpTestCaseWithSelector:].
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

#pragma mark - UIButton method

- (IBAction)pressButton:(id)sender
{
    UIButton *favoriteButton = (UIButton *)sender;
    NSNumber *oldFavoriteBool = [_tableViewFavorites objectAtIndex:favoriteButton.tag];
    [self setFavoriteButton:favoriteButton withFavoriteStatus:(![oldFavoriteBool boolValue])];
    //    NSNumber *oldFavoriteBool = [_tableViewFavorites objectAtIndex:favoriteButton.tag];
    //    NSNumber *updatedFavoriteBool;
    //    NSString *updatedFavoriteButtonAccessibilityValue;
    //    UIImage *updatedFavoriteButtonImage;
    //    if ([oldFavoriteBool boolValue] == YES) {
    //        updatedFavoriteBool = @(NO);
    //        updatedFavoriteButtonAccessibilityValue = @"off";
    //        updatedFavoriteButtonImage = [UIImage imageNamed:@"heart_empty_icon&32.png"];
    //
    //    }
    //    else {
    //        updatedFavoriteBool = @(YES);
    //        updatedFavoriteButtonAccessibilityValue = @"on";
    //        updatedFavoriteButtonImage = [UIImage imageNamed:@"heart_icon&32.png"];
    //    }
    //    [_tableViewFavorites setObject:updatedFavoriteBool atIndexedSubscript:favoriteButton.tag];
    //    favoriteButton.accessibilityValue = updatedFavoriteButtonAccessibilityValue;
    //    [favoriteButton setImage:updatedFavoriteButtonImage forState:UIControlStateNormal];

    //    if ([favoriteButton.titleLabel.text isEqualToString:@"Favorite"]) {
    //        [favoriteButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
    //    }
    //    else {
    //        [favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
    //    }
    //[favoriteButton setImage:[UIImage imageNamed:@"heart_icon&32.png"] forState:UIControlStateNormal];
}

- (void) setFavoriteButton:(UIButton *)favoriteButton withFavoriteStatus:(BOOL)favoriteBool
{
    //NSNumber *oldFavoriteBool = [_tableViewFavorites objectAtIndex:favoriteButton.tag];
    //    NSNumber *updatedFavoriteBool;
    NSString *updatedFavoriteButtonAccessibilityValue;
    UIImage *updatedFavoriteButtonImage;
    if (favoriteBool == YES) {
        //        updatedFavoriteBool = @(NO);
        updatedFavoriteButtonAccessibilityValue = @"on";
        updatedFavoriteButtonImage = [UIImage imageNamed:@"heart_icon&32.png"];

    }
    else {
        //        updatedFavoriteBool = @(YES);
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

    //UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[favoriteButton setImage:[UIImage imageNamed:@"heart_empty_icon&32.png"] forState:UIControlStateNormal];
    favoriteButton.accessibilityLabel = @"Favorite";
    //favoriteButton.accessibilityValue = @"off";
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
