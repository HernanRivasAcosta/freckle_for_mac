//
//  FreckleLoginWindowController.h
//  FreckleTimer
//
//  Created by Hernan on 10/27/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FreckleUserData.h"

@protocol FreckleLoginWindowControllerDelegate <NSObject>

@required
- (void)onLoginWindowClosed;

@end

@interface FreckleLoginWindowController : NSWindowController<NSTextFieldDelegate, NSWindowDelegate>

- (id)initWithUserData:(FreckleUserData *)userData andDelegate:(id<FreckleLoginWindowControllerDelegate>)delegate;
- (void)controlTextDidChange:(NSNotification *)obj;

#pragma mark xib
@property (weak) IBOutlet NSTextField *_domainInput;
@property (weak) IBOutlet NSTextField *_domainSuffixField;
@property (weak) IBOutlet NSTextField *_apiTokenInput;

#pragma mark actions
- (IBAction)submitLogin:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
