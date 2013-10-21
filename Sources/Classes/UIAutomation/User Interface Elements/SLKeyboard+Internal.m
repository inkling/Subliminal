//
//  SLKeyboard+Internal.m
//  Subliminal
//
//  Created by Aaron Golden on 10/21/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLKeyboard+Internal.h"

#import "SLUIAElement+Subclassing.h"
#import "SLLogger.h"
#import "SLStringUtilities.h"

@implementation SLKeyboard (Internal)

- (void)typeString:(NSString *)string withSetValueFallbackUsingElement:(SLUIAElement *)element {
    @try {
        [self typeString:string];
    } @catch (id exception) {
        [[SLLogger sharedLogger] logWarning:[NSString stringWithFormat:@"-[SLKeyboard typeString:] will fall back on UIAElement.setValue due to an exception in UIAKeyboard.typeString: %@", exception]];
        [element waitUntilTappable:YES thenSendMessage:@"setValue('%@')", [string slStringByEscapingForJavaScriptLiteral]];
    }
}

@end
