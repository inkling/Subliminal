//
//  SLElementCustomGestureTestViewController.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/1/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTestCaseViewController.h"

#import <Subliminal/SLTestController+AppHooks.h>


#pragma mark - Touch visualization

@interface SLTouchView : UIView
@end

@implementation SLTouchView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // configure line-drawing parameters
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 2.0f);

    // draw an X:
    // upper-left to bottom-right
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    // upper-right to bottom-left
    CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);

    CGContextRestoreGState(context);
}

@end


#pragma mark - Test view controller

@interface SLElementCustomGestureTestViewController : SLTestCaseViewController

@end

@implementation SLElementCustomGestureTestViewController {
    NSMutableSet *_touchViews;
    UIView *_dragView;
    UIPanGestureRecognizer *_dragGestureRecognizer;
}

- (void)loadViewForTestCase:(SEL)testCase {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];

    _dragView = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 100.0f, 50.0f, 50.0f)];
    [self.view addSubview:_dragView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _dragView.backgroundColor = [UIColor blueColor];
    _dragView.isAccessibilityElement = YES;
    _dragView.accessibilityLabel = @"test element";
    // ensure that touches pass through to the main view, for visualizing recording
    _dragView.userInteractionEnabled = NO;

    _dragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
    // ensure that the main view will receive touches, for visualizing recording
    _dragGestureRecognizer.cancelsTouchesInView = NO;
    _dragGestureRecognizer.delaysTouchesEnded = NO;
    [self.view addGestureRecognizer:_dragGestureRecognizer];
}

- (instancetype)initWithTestCaseWithSelector:(SEL)testCase {
    self = [super initWithTestCaseWithSelector:testCase];
    if (self) {
        _touchViews = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dragView:(UIPanGestureRecognizer *)dragGestureRecognizer {
    UIView *referenceView = dragGestureRecognizer.view;
    CGPoint translation = [dragGestureRecognizer translationInView:referenceView];
    [dragGestureRecognizer setTranslation:CGPointZero inView:referenceView];

    _dragView.frame = CGRectOffset(_dragView.frame, translation.x, translation.y);
}

- (void)recordTouches:(NSSet *)touches {
    for (UITouch *touch in touches) {
        SLTouchView *view = [[SLTouchView alloc] initWithFrame:(CGRect){ .size = { 10.0f, 10.0f } }];
        view.center = [touch locationInView:touch.view];
        [self.view addSubview:view];
        [_touchViews addObject:view];
    }
}

- (void)clearTouches {
    [_touchViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_touchViews removeAllObjects];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self recordTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearTouches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearTouches];
}

@end
