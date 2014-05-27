//
//  SLGeometry.m
//  Subliminal
//
//  Created by Maximilian Tagher on 7/2/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLGeometry.h"
#import "SLTerminal+ConvenienceFunctions.h"


NSString *SLUIARectFromCGRect(CGRect rect) {
    NSCParameterAssert(!CGRectIsNull(rect));
    return [NSString stringWithFormat:@"{origin:{x:%f,y:%f}, size:{width:%f, height:%f}}",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

// `UIARect` is some string which evaluates to a `Rect`
CGRect SLCGRectFromUIARect(NSString *UIARect) {
    NSString *CGRectString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLCGRectStringFromJSRect"
                                                                        params:@[ @"rect" ]
                                                                          body:@"if (!rect) return '';\
                                                                                 else return '{{' + rect.origin.x + ',' + rect.origin.y + '},\
                                                                                 {' + rect.size.width + ',' + rect.size.height + '}}';"
                                                                      withArgs:@[ UIARect ]];
    return ([CGRectString length] ? CGRectFromString(CGRectString) : CGRectNull);
}

NSString *SLUIARectEqualToRectFunctionName() {
    static NSString *const SLUIARectEqualToRectFunctionName = @"SLUIARectEqualToRect";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SLTerminal sharedTerminal] loadFunctionWithName:SLUIARectEqualToRectFunctionName
                                                   params:@[ @"rect1", @"rect2" ]
                                                     body:@"return ((!rect1 && !rect2) ||\
                                                                    ((rect2.origin.x === rect1.origin.x) &&\
                                                                     (rect2.origin.y === rect1.origin.y) &&\
                                                                     (rect2.size.width === rect1.size.width) &&\
                                                                     (rect2.size.height === rect1.size.height)));"];
    });
    return SLUIARectEqualToRectFunctionName;
}

NSString *SLUIARectContainsRectFunctionName() {
    static NSString *const SLUIARectContainsRectFunctionName = @"SLUIARectContainsRect";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SLTerminal sharedTerminal] loadFunctionWithName:SLUIARectContainsRectFunctionName
                                                   params:@[ @"rect1", @"rect2" ]
                                                     body:@"return  ((rect2.origin.x >= rect1.origin.x) &&\
                                                                     (rect2.origin.y >= rect1.origin.y) &&\
                                                                     ((rect2.origin.x + rect2.size.width) <= (rect1.origin.x + rect1.size.width)) &&\
                                                                     ((rect2.origin.y + rect2.size.height) <= (rect1.origin.y + rect1.size.height)));"];
    });
    return SLUIARectContainsRectFunctionName;
}
