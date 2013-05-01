//
//  SLElementMatchingTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 2/18/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

@interface SLElementMatchingTestViewController : SLTestCaseViewController
@end


@interface SLElementMatchingTestCell : UITableViewCell

- (void)configureAccessibility;

@end

@implementation SLElementMatchingTestCell {
    SEL _testCase;
    UISwitch *_switch;
    UILabel *_weatherCity, *_weatherTemp;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _testCase = NSSelectorFromString([[reuseIdentifier componentsSeparatedByString:@"_"] lastObject]);
        if (_testCase == @selector(testMatchingNonLabelTableViewCellChildElement)) {
            _switch = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.accessoryView = _switch;
        } else if ((_testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
                   (_testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell))){
            _weatherCity = [[UILabel alloc] initWithFrame:CGRectZero];
            _weatherCity.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_weatherCity];
            
            _weatherTemp = [[UILabel alloc] initWithFrame:CGRectZero];
            _weatherTemp.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_weatherTemp];
        } else {
            NSAssert(NO, @"%@ reuse identifier was not of expected format: '%@_<%@ test case>'.",
                     NSStringFromClass([self class]), NSStringFromClass([self class]), NSStringFromClass([SLElementMatchingTestViewController class]));
        }
    }
    return self;
}

- (void)configureAccessibility {
    _switch.accessibilityLabel = @"fooSwitch";

    // recreating Apple's example from the "Enhancing the Accessibility of Table View Cells" document
    // http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html#//apple_ref/doc/uid/TP40008785-CH102-SW3
    // we have child elements that are individually accessible
    // (UILabels are, by default, accessibility elements,
    // with accessibility labels derived from their text)
    // and the cell itself is not accessible
    // but uses a combination of its children's labels as its label
    _weatherCity.text = @"city";
    _weatherTemp.text = @"temp";
}

- (NSString *)accessibilityLabel {
    if (_testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) {
        return [NSString stringWithFormat:@"%@, %@", _weatherCity.accessibilityLabel, _weatherTemp.accessibilityLabel];
    }
    return [super accessibilityLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = CGRectInset(self.contentView.bounds, 20.0f, 0.0f);
    CGFloat halfWidth = CGRectGetWidth(contentRect) / 2.0;
    CGSize halfSize = CGSizeMake(halfWidth, CGRectGetHeight(contentRect));
    _weatherCity.frame = (CGRect){
        contentRect.origin,
        halfSize
    };
    _weatherTemp.frame = (CGRect){
        CGPointMake(CGRectGetMinX(contentRect) + halfWidth, CGRectGetMinY(contentRect)),
        halfSize
    };
}

@end


@interface SLElementMatchingTestViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *fooButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SLElementMatchingTestViewController

+ (NSString *)nibNameForTestCase:(SEL)testCase {
    if (testCase == @selector(testAnyElement) ||
        testCase == @selector(testElementWithAccessibilityLabel)) {
        return @"SLElementMatchingTestViewController";
    } else if ((testCase == @selector(testMatchingTableViewCellTextLabel)) ||
               (testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
               (testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell)) ||
               (testCase == @selector(testMatchingNonLabelTableViewCellChildElement))) {
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

static NSString *TestCellIdentifier = nil;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.text = @"barText";

    self.fooButton.accessibilityLabel = @"foo";
    self.fooButton.accessibilityValue = @"fooValue";

    if (self.tableView) {
        Class testCellClass;
        if (self.testCase == @selector(testMatchingTableViewCellTextLabel)) {
            testCellClass = [UITableViewCell class];
        } else if ((self.testCase == @selector(testMatchingNonLabelTableViewCellChildElement)) ||
                   (self.testCase == @selector(testMatchingTableViewCellWithCombinedLabel)) ||
                   (self.testCase == @selector(testCannotMatchIndividualChildLabelsOfTableViewCell))) {
            testCellClass = [SLElementMatchingTestCell class];
        } else {
            NSAssert(NO, @"Table view loaded for unexpected test case: %@.", NSStringFromSelector(self.testCase));
        }
        TestCellIdentifier = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(testCellClass), NSStringFromSelector(self.testCase)];
        [self.tableView registerClass:testCellClass forCellReuseIdentifier:TestCellIdentifier];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TestCellIdentifier forIndexPath:indexPath];

    if (self.testCase == @selector(testMatchingTableViewCellTextLabel)) {
        cell.textLabel.text = @"fooLabel";
    } else {
        NSAssert([cell isKindOfClass:[SLElementMatchingTestCell class]],
                 @"Unexpected table view cell class for test case: %@.", NSStringFromSelector(self.testCase));
        [(SLElementMatchingTestCell *)cell configureAccessibility];
    }

    return cell;
}

@end
