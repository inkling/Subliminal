//
//  STLoginManager.m
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "STLoginManager.h"


NSString *const LoginFailureError = @"LoginFailureError";


@implementation STLoginManager

static STLoginManager *__sharedLoginManager = nil;
+ (id)sharedLoginManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedLoginManager = [[STLoginManager alloc] init];
    });
    return __sharedLoginManager;
}

- (id)init {
    NSAssert(!__sharedLoginManager, @"STLoginManager should not be initialized manually. Use +sharedLoginManager instead.");
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionBlock:(void (^)(BOOL, NSError *))completion {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSError *fooError = [NSError errorWithDomain:LoginFailureError code:NetworkErrorCode userInfo:nil];
        if (completion) completion(NO, fooError);
    });
}

@end
