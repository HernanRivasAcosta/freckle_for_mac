//
//  FreckleSubmitProjectWindowController.m
//  FreckleForMac
//
//  Created by Hernan on 11/10/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleSubmitProjectWindowController.h"

@interface FreckleSubmitProjectWindowController ()

@property FreckleProjectData *_project;
@property FreckleAPIManager *_apiManager;
@property id<FreckleSubmitProjectWindowControllerDelegate> _delegate;
@property NSUInteger _lastValidMinutes;

@end

@implementation FreckleSubmitProjectWindowController

// Private variables
@synthesize _project, _apiManager, _delegate, _lastValidMinutes;
// xib
@synthesize _timeField, _commentsField;

- (id)initWithProject:(FreckleProjectData *)project apiManager:(FreckleAPIManager *)apiManager andDelegate:(id<FreckleSubmitProjectWindowControllerDelegate>)delegate
{
	self = [super initWithWindowNibName:@"FreckleSubmitProjectWindowController"];
	
	_project = project;
	_apiManager = apiManager;
	_delegate = delegate;
	
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[self.window setTitle:[NSString stringWithFormat:@"Log time on %@", _project.name]];
	
	[_commentsField becomeFirstResponder];
	
	_lastValidMinutes = [_project minutesWorkedOnProject];
	[_timeField setStringValue:[FreckleTimeParser formatMinutes:_lastValidMinutes]];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
	if (obj.object == _timeField)
	{
		[_timeField setStringValue:[self parseInputTime]];
	}
}

#pragma mark Actions
- (IBAction)submit:(id)sender
{
	[_apiManager log:_lastValidMinutes onProject:_project.name withComments:_commentsField.stringValue];
	
	if (_delegate != nil)
	{
		[_delegate onProjectSubmitted:_project];
		_delegate = nil;
	}
	[self.window close];
}

#pragma mark Time Parsing
- (NSString *)parseInputTime
{
	NSUInteger parsedMins = [FreckleTimeParser minutesFromString:_timeField.stringValue];
	
	if (parsedMins != 0)
	{
		// If the time is valid, save it as the last valid time
		_lastValidMinutes = parsedMins;
	}
	
	// Always use the last know valid time
	return [FreckleTimeParser formatMinutes:_lastValidMinutes];
}

@end
