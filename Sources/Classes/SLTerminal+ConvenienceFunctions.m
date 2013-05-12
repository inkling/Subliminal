//
//  SLTerminal+ConvenienceFunctions.m
//  Subliminal
//
//  Created by Jeffrey Wear on 4/9/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLTerminal+ConvenienceFunctions.h"

#import <objc/runtime.h>


@interface SLTerminal (ConvenienceFunctions_Internal)

/**
 Returns a Boolean value that indicates whether a function with the specified
 name has been added to Subliminal's namespace.
 
 @param name The name of a function.
 @return YES if a function with the specified name has previously been added 
 to Subliminal's namespace, NO otherwise.
 */
- (BOOL)functionWithNameIsLoaded:(NSString *)name;

@end


@implementation SLTerminal (ConvenienceFunctions)

#pragma mark - Evaluating functions

/// All access to this dictionary, and addition of functions to Subliminal's
/// namespace, should be done on the terminal's evalQueue for thread safety.
- (NSMutableDictionary *)loadedFunctions {
    static const void *const kFunctionsLoadedKey = &kFunctionsLoadedKey;
    NSMutableDictionary *functionsLoaded = objc_getAssociatedObject(self, kFunctionsLoadedKey);
    if (!functionsLoaded) {
        functionsLoaded = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kFunctionsLoadedKey, functionsLoaded, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return functionsLoaded;
}

- (BOOL)functionWithNameIsLoaded:(NSString *)name {
    if (dispatch_get_current_queue() != self.evalQueue) {
        __block BOOL functionIsLoaded;
        dispatch_sync(self.evalQueue, ^{
            functionIsLoaded = [self functionWithNameIsLoaded:name];
        });
        return functionIsLoaded;
    }
    
    return ([self loadedFunctions][name] != nil);
}

- (void)loadFunctionWithName:(NSString *)name params:(NSArray *)params body:(NSString *)body {
    if (dispatch_get_current_queue() != self.evalQueue) {
        NSException *__block loadException;
        dispatch_sync(self.evalQueue, ^{
            @try {
                [self loadFunctionWithName:name params:params body:body];
            }
            @catch (NSException *exception) {
                loadException = exception;
            }
        });
        if (loadException) @throw loadException;
        return;
    }
    
    NSString *paramList = [params componentsJoinedByString:@", "];
    NSString *function = [NSString stringWithFormat:@"%@.%@ = function(%@){ %@ }", self.scriptNamespace, name, paramList, body];
    NSString *loadedFunction = [self loadedFunctions][name];
    if (!loadedFunction) {
        [self eval:function];
        [self loadedFunctions][name] = function;
    } else {
        NSAssert([function isEqualToString:loadedFunction],
                 @"Function with name %@, params %@, and body %@ has previously been loaded with different parameters and/or body: %@",
                 name, params, body, loadedFunction);
    }
}

- (NSString *)evalFunctionWithName:(NSString *)name withArgs:(NSArray *)args {
    if (dispatch_get_current_queue() != self.evalQueue) {
        NSString *__block result;
        NSException *__block evalException;
        dispatch_sync(self.evalQueue, ^{
            @try {
                result = [self evalFunctionWithName:name withArgs:args];
            }
            @catch (NSException *exception) {
                evalException = exception;
            }
        });
        if (evalException) @throw evalException;
        return result;
    }
    
    NSAssert([self functionWithNameIsLoaded:name], @"No function with name %@ has been loaded.", name);
    NSString *argList = [args componentsJoinedByString:@", "];
    return [self evalWithFormat:@"%@.%@(%@)", self.scriptNamespace, name, argList];
}

- (NSString *)evalFunctionWithName:(NSString *)name
                            params:(NSArray *)params
                              body:(NSString *)body
                          withArgs:(NSArray *)args {
    if (dispatch_get_current_queue() != self.evalQueue) {
        NSString *__block result;
        NSException *__block evalException;
        dispatch_sync(self.evalQueue, ^{
            @try {
                result = [self evalFunctionWithName:name params:params body:body withArgs:args];
            }
            @catch (NSException *exception) {
                evalException = exception;
            }
        });
        if (evalException) @throw evalException;
        return result;
    }
    
    [self loadFunctionWithName:name params:params body:body];
    return [self evalFunctionWithName:name withArgs:args];
}

#pragma mark - Waiting on boolean expressions

- (BOOL)waitUntilTrue:(NSString *)condition
           retryDelay:(NSTimeInterval)retryDelay
              timeout:(NSTimeInterval)timeout {
    NSString *retryFunction = [NSString stringWithFormat:@"\
                               (function () {\
                                   var cond = function() { return (%@); };\
                                   var retryDelay = %g;\
                                   var timeout = %g;\
                                   \
                                   var startTime = (Date.now() / 1000);\
                                   var condTrue = false;\
                                   while (!(condTrue = cond()) && (((Date.now() / 1000) - startTime) < timeout)) {\
                                       UIATarget.localTarget().delay(retryDelay);\
                                   };\
                                   return condTrue;\
                               })()", condition, retryDelay, timeout];

    return [[self eval:retryFunction] boolValue];
}

@end
