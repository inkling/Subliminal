//
//  SLTestController.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/3/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SLTestController : NSObject

@property (nonatomic) NSTimeInterval defaultTimeout;

+ (id)sharedTestController;

- (void)runTests:(NSSet *)tests;

@end
