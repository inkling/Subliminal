//
//  SLMailComposeView.m
//  Subliminal
//
//  Created by Jeffrey Wear on 5/25/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLMailComposeView.h"
#import "SLUIAElement+Subclassing.h"

#import "SLTerminal+ConvenienceFunctions.h"
#import "SLGeometry.h"
#import "SLKeyboard.h"
#import "SLNavigationBar.h"
#import "SLActionSheet.h"

typedef NS_ENUM(NSUInteger, SLMailComposeViewChildType) {
    SLMailComposeViewChildTypeToField,
    SLMailComposeViewChildTypeCcBccLabel,
    SLMailComposeViewChildTypeCcField,
    SLMailComposeViewChildTypeBccField,
    SLMailComposeViewChildTypeSubjectField,
    SLMailComposeViewChildTypeBodyView
};

@implementation SLMailComposeView {
    SLStaticElement *_toField;
    SLStaticElement *_ccBccLabel, *_ccField, *_bccField;
    SLStaticElement *_subjectField;
    SLStaticElement *_bodyView;
}

+ (NSString *)UIAChildSelectorForChildOfType:(SLMailComposeViewChildType)type {
    switch (type) {
        case SLMailComposeViewChildTypeToField:
            return @"textFields()['toField']";
        case SLMailComposeViewChildTypeCcBccLabel:
            // on iOS 6, this is a plain element; on 7, it's a static text element
            return @"elements()['Cc/Bcc:']";
        case SLMailComposeViewChildTypeCcField:
            return @"textFields()['ccField']";
        case SLMailComposeViewChildTypeBccField:
            return @"textFields()['bccField']";
        case SLMailComposeViewChildTypeSubjectField:
            return @"textFields()['subjectField']";
        case SLMailComposeViewChildTypeBodyView:
            // on iOS 6, this is a text field; on 7, it's a text view
            return @"elements()['Message body']";
    }
}

+ (instancetype)currentComposeView {
    /**
     UIAutomation does not provide an interface to the compose view
     (e.g. on `UIAApplication`, like other system views).
     We identify a view as the compose view if it has the children of a compose view.
     
     We define the compose view getter as a standalone function
     (rather than an immediately-evaluated function expression) so that
     the `-description` of the compose view and its children will be more concise.
     */
    static NSString *const kCurrentComposeViewFunctionName = @"SLMailComposeViewCurrentComposeView";
    [[SLTerminal sharedTerminal] loadFunctionWithName:kCurrentComposeViewFunctionName
                                               params:nil
                                                 body:[NSString stringWithFormat:@"\
        var candidateView = UIATarget.localTarget().frontMostApp().mainWindow().scrollViews()[0];\
        if (candidateView.isValid() &&\
            candidateView.%@.isValid() &&\
            candidateView.%@.isValid() &&\
            candidateView.%@.isValid() &&\
            candidateView.%@.isValid() &&\
            candidateView.%@.isValid() &&\
            candidateView.%@.isValid()) {\
            return candidateView;\
        } else {"
            // return `UIAElementNil`
            // I don't know how to create it,
            // so get a reference to it by attempting to retrieve an element guaranteed not to exist
            @"return UIATarget.localTarget().frontMostApp().elements()['%@: %p'];\
        }",
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeToField],
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeCcBccLabel],
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeCcField],
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeBccField],
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeSubjectField],
        [self UIAChildSelectorForChildOfType:SLMailComposeViewChildTypeBodyView],
        NSStringFromClass(self), self]];
    
    NSString *namespacedCurrentComposeViewFunctionName = [NSString stringWithFormat:@"%@.%@",
                                                          [[SLTerminal sharedTerminal] scriptNamespace], kCurrentComposeViewFunctionName];
    return [[self alloc] initWithUIARepresentation:[NSString stringWithFormat:@"%@()", namespacedCurrentComposeViewFunctionName]];
}

- (instancetype)initWithUIARepresentation:(NSString *)UIARepresentation {
    self = [super initWithUIARepresentation:UIARepresentation];
    if (self) {
        NSString *(^UIARepresentationForChildOfType)(SLMailComposeViewChildType) = ^(SLMailComposeViewChildType type) {
            return [UIARepresentation stringByAppendingFormat:@".%@", [[self class] UIAChildSelectorForChildOfType:type]];
        };
        
        _toField = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeToField)];
        _ccBccLabel = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeCcBccLabel)];
        _ccField = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeCcField)];
        _bccField = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeBccField)];
        _subjectField = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeSubjectField)];
        _bodyView = [[SLStaticElement alloc] initWithUIARepresentation:UIARepresentationForChildOfType(SLMailComposeViewChildTypeBodyView)];
    }
    return self;
}

#pragma mark - Reading and Setting Mail Fields

/**
 A general note on error handling in the mail field setters and getters:
 these methods, like all of `SLMailComposeView`'s interface (save `+currentComposeView`),
 require that the compose view be valid.
 
 However, it is not necessary to check `-[self isValid]` in these methods because
 the mail fields are derived from the compose view--that is, their UIAutomation
 representations are derived from that of the compose view. This causes them to
 be valid if and only if the compose view is valid, and attempting to manipulate
 the fields will cause suitable exceptions to be thrown if the compose view is not valid.
 */

/**
 When the recipient fields contain multiple recipients and don't have keyboard
 focus, they collapse and truncate the display of the secondary recipients
 (e.g. read "foo@example.com & 1 more...").
 
 To read all recipients, a field must first be given the keyboard focus (so that
 it will expand). But even when expanded, the `value()` of a field with multiple
 recipients will still be truncated. So, the recipients must be read as the `name()`s
 of the "recipient buttons" within the field.

 Unfortunately, on iOS 6, the buttons' `rect()`s are not actually within
 the `rect()` of the field--the field comes _after_ the buttons. The buttons must
 be read as those in the compose view's elements array just prior to the field.
 */
- (NSArray *)recipientsInFieldWithName:(NSString *)fieldName {
    NSString *quotedFieldName = [NSString stringWithFormat:@"'%@'", [fieldName slStringByEscapingForJavaScriptLiteral]];
    NSString *recipientsJSONString = [[SLTerminal sharedTerminal] evalFunctionWithName:@"SLMailComposeViewNamesOfRecipientButtonsInFieldWithName"
                                                                                params:@[ @"fieldName" ]
                                                                                  body:[NSString stringWithFormat:@"\
        var composeView = %@;"
        // compare names rather than elements because elements aren't unique objects
        @"var getName = function(element){ return element.name() };\
        var mailElementNames = composeView.elements().toArray().map(getName);\
        var mailFieldNames = composeView.textFields().toArray().map(getName);\
        var mailButtonNames = composeView.buttons().toArray().map(getName);"

        @"var fieldIndexAsElement = mailElementNames.indexOf(fieldName);\
        if (fieldIndexAsElement === -1) throw ('Field \"' + fieldName + '\" not found');"

        @"var previousFieldIndexAsElement = -1;\
        var fieldIndexAsField = mailFieldNames.indexOf(fieldName);\
        var previousFieldIndexAsField = fieldIndexAsField - 1;\
        if (previousFieldIndexAsField > -1) {\
            var previousFieldName = mailFieldNames[previousFieldIndexAsField];\
            previousFieldIndexAsElement = mailElementNames.indexOf(previousFieldName);\
            if (previousFieldIndexAsElement === -1) throw ('Field \"' + previousFieldName + '\" not found');\
        }"

        // return the name of every button element (except for "Add Contact")
        // between the previous field and this field
        @"var names = mailElementNames.slice(Math.max(0, previousFieldIndexAsElement), fieldIndexAsElement).filter(function(name){\
            return ((mailButtonNames.indexOf(name) !== -1) &&\
                    (name !== 'Add Contact'));\
        }).sort(function(nameA, nameB){"
            // filter duplicates--on iOS 7, there are text views that contain the email text
            // and we may have picked those up "as" buttons
            // sort first so we can use a faster filtering algorithm
            @"return nameA - nameB;\
        }).reduce(function(arr, name){\
            if ((arr.length === 0) || (arr[arr.length-1] !== name)) arr.push(name);\
            return arr;\
        }, []);\
        return JSON.stringify(names);\
        ", _UIARepresentation]
                                                                              withArgs:@[ quotedFieldName ]];
    NSData *recipientsJSONData = [recipientsJSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!recipientsJSONData) return nil;

    return [NSJSONSerialization JSONObjectWithData:recipientsJSONData options:0 error:NULL];
}

- (void)setContentsOfField:(SLUIAElement *)field toRecipients:(NSArray *)recipients {
    // Bring up the keyboard
    if (![field hasKeyboardFocus]) [field tap];

    // Clear the contents of the field
    [field waitUntilTappable:YES thenSendMessage:@"setValue('')"];

    // Add the recipients
    for (NSString *recipient in recipients) {
        [[SLKeyboard keyboard] typeString:recipient];
        // Hitting enter confirms the recipient, turning it into a button (see `-recipientsInFieldWithName:`)
        // The need to confirm is also why we can't use `setValue()`.
        [[SLKeyboard keyboard] typeString:@"\n"];
    }
}

/// See comment on `recipientsInFieldWithName:` for explanation.
- (NSArray *)toRecipients {
    if (![_toField hasKeyboardFocus]) [_toField tap];

    return [self recipientsInFieldWithName:@"toField"];
}

- (void)setToRecipients:(NSArray *)toRecipients {
    [self setContentsOfField:_toField toRecipients:toRecipients];
}

/// See comment on `recipientsInFieldWithName:` for explanation.
- (NSArray *)ccRecipients {
    /*
     The "Cc/Bcc:" label is visible iff the "Cc:" and "Bcc:" fields are empty
     (the label is shown next to a unified (collapsed) field).
     This is the fastest way to determine if the "Cc:" field is empty,
     plus the field isn't always tappable when collapsed (i.e. on iOS 6).
     */
    if ([_ccBccLabel isValidAndVisible]) return @[];

    if (![_ccField hasKeyboardFocus]) [_ccField tap];

    return [self recipientsInFieldWithName:@"ccField"];
}

- (void)setCcRecipients:(NSArray *)ccRecipients {
    /*
     If the "cc" and "bcc" fields are collapsed, we need to show  the "cc" field
     to make it tappable for `-setContentsOfField:toRecipients:`.
     Tapping the "cc/bcc" label expands the "cc" and "bcc" fields.
     (The "cc" field is not tappable on iOS 6 if collapsed, fyi.)
     */
    if ([_ccBccLabel isValidAndVisible]) [_ccBccLabel tap];

    [self setContentsOfField:_ccField toRecipients:ccRecipients];
}

/// See comment on `recipientsInFieldWithName:` for explanation.
- (NSArray *)bccRecipients {
    /*
     The "Cc/Bcc:" label is visible iff the "Cc:" and "Bcc:" fields are empty
     (the label is shown next to a unified (collapsed) field).
     This is the fastest way to determine if the "Bcc:" field is empty,
     plus the field isn't always tappable when collapsed (i.e. on iOS 6).
     */
    if ([_ccBccLabel isValidAndVisible]) return @[];

    if (![_bccField hasKeyboardFocus]) [_bccField tap];

    return [self recipientsInFieldWithName:@"bccField"];
}

- (void)setBccRecipients:(NSArray *)bccRecipients {
    /*
     If the "cc" and "bcc" fields are collapsed, we need to show  the "cc" field
     to make it tappable for `-setContentsOfField:toRecipients:`.
     Tapping the "cc/bcc" label expands the "cc" and "bcc" fields.
     (The "bcc" field is not tappable on iOS 6 if collapsed, fyi.)
     */
    if ([_ccBccLabel isValidAndVisible]) [_ccBccLabel tap];

    [self setContentsOfField:_bccField toRecipients:bccRecipients];
}

- (NSString *)subject {
    return [_subjectField value];
}

- (void)setSubject:(NSString *)subject {
    /*
     We don't need to use the keyboard to type the value here (as normal),
     but can rather use the faster and more robust `setValue()`,
     because the subject field is a private subview of the mail compose view,
     so the application can't observe the text changing. It's also ok to violate
     our "test like a user" mantra because we're not responsible for testing system views.
     */
    [_subjectField waitUntilTappable:YES thenSendMessage:@"setValue('%@')", [subject slStringByEscapingForJavaScriptLiteral]];
}

- (NSString *)body {
    return [_bodyView value];
}

- (void)setBody:(NSString *)body {
    /*
     We don't need to use the keyboard to type the value here (as normal),
     but can rather use the faster and more robust `setValue()`,
     because the body view is a private subview of the mail compose view,
     so the application can't observe the text changing. It's also ok to violate
     our "test like a user" mantra because we're not responsible for testing system views.
     */
    [_bodyView waitUntilTappable:YES thenSendMessage:@"setValue('%@')", [body slStringByEscapingForJavaScriptLiteral]];
}

#pragma mark - Sending Mail

- (BOOL)sendMessage {
    __block BOOL didSendMessage = NO;
    
    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    // the sheet itself doesn't technically need to be tappable,
    // but as the user is "acting upon the sheet", we pass `YES` for _waitUntilTappable_
    [self waitUntilTappable:YES thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        SLUIAElement *sendButton = [[SLNavigationBar currentNavigationBar] rightButton];
        if (![sendButton isEnabled]) return;
        
        [sendButton tap];
        didSendMessage = YES;
    } timeout:[[self class] defaultTimeout]];
    
    return didSendMessage;
}

- (BOOL)cancelAndDeleteDraft:(BOOL)deleteDraft {
    __block BOOL draftWasInProgress = NO;
    
    // Use this as convenience to perform the waiting and, if necessary, exception throwing
    // the sheet itself doesn't technically need to be tappable,
    // but as the user is "acting upon the sheet", we pass `YES` for _waitUntilTappable_
    [self waitUntilTappable:YES thenPerformActionWithUIARepresentation:^(NSString *UIARepresentation) {
        SLUIAElement *cancelButton = [[SLNavigationBar currentNavigationBar] leftButton];
        [cancelButton tap];
        
        // Wait for the action sheet to show up if it will (i.e. if there was a draft in progress)
        [NSThread sleepForTimeInterval:0.3];
        
        SLActionSheet *draftActionSheet = [SLActionSheet currentActionSheet];
        if ([draftActionSheet isValidAndVisible]) {
            draftWasInProgress = YES;
            
            NSArray *draftActionButtons = [draftActionSheet buttons];
            
            NSString *buttonTitle = deleteDraft ? @"Delete Draft" : @"Save Draft";
            NSUInteger buttonIndex = [draftActionButtons indexOfObjectPassingTest:^BOOL(SLUIAElement *button, NSUInteger idx, BOOL *stop) {
                return [[button label] isEqualToString:buttonTitle];
            }];
            NSAssert(buttonIndex != NSNotFound,
                     @"Option to %@ draft not found.", deleteDraft ? @"delete" : @"cancel");
            [draftActionButtons[buttonIndex] tap];
        }
    } timeout:[[self class] defaultTimeout]];
    
    return draftWasInProgress;
}

@end
