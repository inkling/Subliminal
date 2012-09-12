//
//  STLoginManager.h
//  SubliminalTest
//
//  Created by Jeffrey Wear on 9/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    InvalidLoginErrorCode = 0,
    NetworkErrorCode
} LoginFailureErrorCode;

extern NSString *const LoginFailureError;


@interface STLoginManager : NSObject

+ (id)sharedLoginManager;

- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
          completionBlock:(void(^)(BOOL didLogIn, NSError *error))completion;

@end
