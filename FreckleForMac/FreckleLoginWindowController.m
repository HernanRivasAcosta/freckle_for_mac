//
//  FreckleLoginWindowController.m
//  FreckleTimer
//
//  Created by Hernan on 10/27/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleLoginWindowController.h"

@interface FreckleLoginWindowController()

@property FreckleUserData *userData;
@property id<FreckleLoginWindowControllerDelegate> delegate;
@property CGFloat initialSuffixX;
@property BOOL shouldQuitAppOnClose;

@end

@implementation FreckleLoginWindowController

// xib
@synthesize _domainInput, _apiTokenInput, _domainSuffixField;

- (id)initWithUserData:(FreckleUserData *)userData andDelegate:(id<FreckleLoginWindowControllerDelegate>)delegate
{
	self = [super initWithWindowNibName:@"FreckleLoginWindowController"];
	
	if (self != nil)
	{
		_userData = userData;
		_delegate = delegate;
		_shouldQuitAppOnClose = YES;
	}
	
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	NSString *domain = _userData.domain == nil ? @"" : _userData.domain;
	[_domainInput setStringValue:domain];
	NSString *token = _userData.token == nil ? @"" : _userData.token;
	[_apiTokenInput setStringValue:token];
	
	_initialSuffixX = _domainInput.frame.origin.x;
	[self setSuffixPosition];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if (_shouldQuitAppOnClose)
	{
		[NSApp terminate:self];
	}
}

- (void)controlTextDidChange:(NSNotification *)obj
{
	if (obj.object == _domainInput)
	{
		[self setSuffixPosition];
	}
}

- (void)setSuffixPosition
{
	NSDictionary *fontInfo = [NSDictionary dictionaryWithObject:_domainInput.font forKey:NSFontAttributeName];
	NSString *inputText = _domainInput.stringValue.length > 0 ? _domainInput.stringValue : [_domainInput.cell placeholderString];
	
	NSRect r = _domainSuffixField.frame;
	r.origin.x = _domainInput.frame.origin.x + [inputText sizeWithAttributes:fontInfo].width + 1.5f;
	_domainSuffixField.frame = r;
}

- (IBAction)submitLogin:(id)sender
{
	[_userData setDomain:[_domainInput stringValue] andToken:[_apiTokenInput stringValue]];
	
	_shouldQuitAppOnClose = NO;
	
	// Target should never be nil here
	if (_delegate != nil)
	{
		[_delegate onLoginWindowClosed];
		_delegate = nil;
	}
	
	[self close];
}

- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://letsfreckle.com/help/api/"]];
}

@end
