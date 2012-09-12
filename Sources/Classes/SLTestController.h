//
//  SLTestController.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SLLogger;

@interface SLTestController : NSObject

@property (nonatomic) NSTimeInterval defaultTimeout;
@property (nonatomic, strong) SLLogger *logger;

+ (id)sharedTestController;

- (void)runTests:(NSArray *)tests;

@end
