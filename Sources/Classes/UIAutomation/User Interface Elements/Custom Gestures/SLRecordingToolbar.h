//
//  SLRecordingToolbar.h
//  Subliminal
//
//  Created by Jeffrey Wear on 12/17/13.
//  Copyright (c) 2013 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLRecordingToolbar : UIToolbar

@property (nonatomic, strong, readonly) UIBarButtonItem *playButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *recordButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *stopButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *doneButtonItem;

@property (nonatomic) BOOL showsRecordButton;

@end

