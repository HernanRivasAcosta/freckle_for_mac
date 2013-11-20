//
//  FreckleSubmitProjectWindowController.h
//  FreckleForMac
//
//  Created by Hernan on 11/10/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FreckleProjectManager.h"
#import "FreckleTimeParser.h"
#import "FreckleAPIManager.h"

@protocol FreckleSubmitProjectWindowControllerDelegate <NSObject>

@required
- (void)onProjectSubmitted:(FreckleProjectData *)project;

@end

@interface FreckleSubmitProjectWindowController : NSWindowController<NSWindowDelegate, NSTextFieldDelegate>

- (id)initWithProject:(FreckleProjectData *)project apiManager:(FreckleAPIManager *)apiManager andDelegate:(id<FreckleSubmitProjectWindowControllerDelegate>)delegate;

#pragma mark xib
@property (weak) IBOutlet NSTextField *_timeField;
@property (weak) IBOutlet NSTextField *_commentsField;

#pragma mark Actions
- (IBAction)submit:(id)sender;

@end
