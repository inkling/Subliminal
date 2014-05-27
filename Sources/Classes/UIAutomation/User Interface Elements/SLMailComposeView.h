//
//  SLMailComposeView.h
//  Subliminal
//
//  Created by Jeffrey Wear on 5/25/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import "SLStaticElement.h"

/**
 `SLMailComposeView` allows you to manipulate mail compose views
 within your application.
 
 "Mail compose views" are the views displayed by instances of
 `MFMailComposeViewController`.
 */
@interface SLMailComposeView : SLStaticElement

/**
 Returns an object that represents the app's current mail compose view, if any.
 
 This element will be [valid](-[SLUIAElement isValid]) if and only if the application
 is currently showing a mail compose view.
 
 @return An object that represents the app's current mail compose view.
 */
+ (instancetype)currentComposeView;

#pragma mark - Reading and Setting Mail Fields
/// ------------------------------------------
/// @name Reading and Setting Mail Fields
/// ------------------------------------------

/**
 The recipients in the email's "To" field, as an array of `NSString` objects
 representing the recipients' email addresses.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).

 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
@property (nonatomic, copy) NSArray *toRecipients;

/**
 The recipients in the email's "Cc" field, as an array of `NSString` objects
 representing the recipients' email addresses.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
@property (nonatomic, copy) NSArray *ccRecipients;

/**
 The recipients in the email's "Bcc" field, as an array of `NSString` objects
 representing the recipients' email addresses.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
@property (nonatomic, copy) NSArray *bccRecipients;

/**
 The subject line of the email.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
@property (nonatomic, copy) NSString *subject;

/**
 The body of the email.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
@property (nonatomic, copy) NSString *body;

#pragma mark - Sending Mail
/// ------------------------------------------
/// @name Sending Mail
/// ------------------------------------------

/**
 Cancels the message.
 
 An empty message will be discarded immediately, but if a draft is in progress,
 the user will be presented with the option to save or delete the draft.
 _deleteDraft_ determines the choice to take if/when the option is presented.
 
 @param deleteDraft `YES` to delete the draft, `NO` otherwise.
 This parameter has no effect if a draft is not in progress.
 @return `YES` if there was a draft in progress, `NO` otherwise.
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
- (BOOL)cancelAndDeleteDraft:(BOOL)deleteDraft;

/**
 Sends the message.
 
 @return `YES` if the message was sent, `NO` otherwise
 (for instance, if the message is empty).
 
 @exception SLUIAElementInvalidException Raised if the compose view is not valid
 by the end of the [default timeout](+defaultTimeout).
 
 @exception SLUIAElementNotTappableException Raised by the setter if the compose
 view is not tappable when whatever amount of time remains of the default timeout
 after the compose view becomes valid elapses.
 */
- (BOOL)sendMessage;

@end
