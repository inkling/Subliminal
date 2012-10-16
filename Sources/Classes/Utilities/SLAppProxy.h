//
//  SLAppProxy.h
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLAppProxy : NSProxy

+ (id)proxyForObject:(id)object;

@end
