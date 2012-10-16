//
//  SLAppProxy.m
//  Subliminal
//
//  Created by Jeffrey Wear on 10/16/12.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "SLAppProxy.h"

#import <objc/runtime.h>

static const void *const SLProxiedObjectProxyKey = &SLProxiedObjectProxyKey;

@implementation SLAppProxy {
    id _object;
}

+ (id)registerProxyForObject:(id)object {
    // proxies are unique to objects
    id proxy = nil;
    Class objectClass = object_getClass(object);    // the proxy will lie about -class
    if (objectClass == objc_getClass("SLAppProxy")) {
        proxy = object;
    } else {
        @synchronized(object) {
            proxy = objc_getAssociatedObject(object, SLProxiedObjectProxyKey);
            if (!proxy) {
                proxy = [[SLAppProxy alloc] initWithObject:object];
                // proxies retain their objects
                objc_setAssociatedObject(object, SLProxiedObjectProxyKey, proxy, OBJC_ASSOCIATION_ASSIGN);
            }
        }
    }
    return proxy;
}

+ (id)proxyForObject:(id)object {
    return [self registerProxyForObject:object];
}

- (id)initWithObject:(id)object {
    // no call to super, because we don't descend from NSObject
    _object = object;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *methodSignature = nil;
    if ([NSThread isMainThread]) {
        methodSignature = [_object methodSignatureForSelector:sel];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            methodSignature = [_object methodSignatureForSelector:sel];
        });
    }
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (dispatch_get_current_queue() == dispatch_get_main_queue()) {
        [invocation invokeWithTarget:_object];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [invocation invokeWithTarget:_object];
        });
    }
    
    // proxify object-type results so that they may be also used off the main thread
    if (strcmp([[invocation methodSignature] methodReturnType], "@") == 0) {
        id resultObject = nil;
        [invocation getReturnValue:&resultObject];
        if (resultObject) {
            id proxy = [[self class] registerProxyForObject:resultObject];
            [invocation setReturnValue:&proxy];
        }
    }
}

#pragma mark NSProxy Overrides
// NSProxy implements the following methods, which is annoying
// We want to invoke the proxied object's implementations

- (NSUInteger)hash {
    return [_object hash];
}

- (BOOL)isEqual:(id)object {
    return [_object isEqual:object];
}

@end
