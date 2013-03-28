//
//  SLAlert.m
//  Subliminal
//
//  Created by Jeffrey Wear on 3/27/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import "SLAlert.h"
#import "SLElement+Subclassing.h"

NSString *const SLAlertCouldNotDismissException = @"SLAlertCouldNotDismissException";

@implementation SLAlert {
    NSString *_title;
}

+ (instancetype)alertWithTitle:(NSString *)title {
    SLAlert *alert = [SLAlert elementMatching:^BOOL(NSObject *obj) {
        if ([obj isKindOfClass:[UIAlertView class]]) {
            UIAlertView *alert = (UIAlertView *)obj;
            return [alert.title isEqualToString:title];
        } else {
            return NO;
        }
    } withDescription:title];
    alert->_title = title;
    return alert;
}

- (BOOL)matchesObject:(NSObject *)object {
    return [object isKindOfClass:[UIAlertView class]] && [super matchesObject:object];
}

- (void)dismiss {
    static NSString *const SLUIAAlertDismissFunctionName = @"SLUIAAlertDismiss";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *SLUIAAlertDismissFunction = @"\
            function %@(alert) {\
                var didDismissAlert = false;\
                if (alert.cancelButton().isValid()) {\
                    alert.cancelButton().tap();\
                    didDismissAlert = true;\
                } else if (alert.defaultButton().isValid()) {\
                    alert.defaultButton().tap();\
                    didDismissAlert = true;\
                }\
                return (didDismissAlert ? 'YES' : 'NO');\
            }\
        ";
        [[SLTerminal sharedTerminal] evalWithFormat:SLUIAAlertDismissFunction,
         SLUIAAlertDismissFunctionName];
    });

    [self performActionWithUIASelf:^(NSString *uiaSelf) {
        BOOL didDismissAlert = [[[SLTerminal sharedTerminal] evalWithFormat:@"%@(%@)",
                                 SLUIAAlertDismissFunctionName, uiaSelf] boolValue];
        if (!didDismissAlert) {
            [NSException raise:SLAlertCouldNotDismissException
                        format:@"%@ appears to have no buttons to tap.", self];
        }
    }];
}

- (void)dismissWithButtonTitled:(NSString *)buttonTitle {
    [self sendMessage:@"buttons()['%@'].tap()", [buttonTitle slStringByEscapingForJavaScriptLiteral]];
}

- (NSString *)isEqualToUIAAlertPredicate {
    static NSString *const kIsEqualToUIAAlertPredicateFormatString = @"\
    var title = \"%@\";\
    if (title.length > 0) {\
    return alert.staticTexts()[0].label() === title;\
    } else {\
    return true;\
    }\
    ";
    NSString *isEqualToUIAAlertPredicate = [NSString stringWithFormat:kIsEqualToUIAAlertPredicateFormatString,
                                            (_title ? [_title slStringByEscapingForJavaScriptLiteral] : @"")];
    return isEqualToUIAAlertPredicate;
}

@end
