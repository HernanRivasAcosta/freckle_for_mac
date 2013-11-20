//
//  FreckleProjectManager.m
//  FreckleForMac
//
//  Created by Hernan on 11/4/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleProjectManager.h"

///////////////////////////////////////////////////////////
#pragma mark PROJECT DATA
///////////////////////////////////////////////////////////

@interface FreckleProjectData()

@property NSUInteger _minutesBeforeThisSession;
@property NSDate *_currentSessionStart;

@end

@implementation FreckleProjectData

// Private variables
@synthesize _minutesBeforeThisSession, _currentSessionStart;
// Public variables
@synthesize name;
// UserDefault keys
static NSString *const SAVED_TIME_KEY_PREFFIX = @"savedTimeFor";
static NSString *const LAST_START_KEY_PREFFIX = @"lastStartOf";

- (id)initWithName:(NSString *)aName
{
	self = [super init];
	
	name = aName;
	[self loadFromUserDefaults];
	
	return self;
}

#pragma mark API
- (BOOL)beingWorkedOn
{
	return _currentSessionStart != nil;
}

- (BOOL)hasUnsavedTime
{
	return _minutesBeforeThisSession > 0;
}

- (BOOL)isActive
{
	return [self beingWorkedOn] || [self hasUnsavedTime];
}

- (NSUInteger)secondsWorkedOnProject
{
	NSTimeInterval currentWorkedTime = -[_currentSessionStart timeIntervalSinceNow];
	
	return _minutesBeforeThisSession * 60 + currentWorkedTime;
}

- (NSUInteger)minutesWorkedOnProject
{
	NSTimeInterval currentWorkedTime = -[_currentSessionStart timeIntervalSinceNow];
	
	return _minutesBeforeThisSession + ceil(currentWorkedTime / 60);
}

- (void)startedWorking
{
	// Save a date when we started working on the project
	_currentSessionStart = [NSDate date];
	// Save the changes
	[self saveToUserDefaults];
}

- (void)stoppedWorking
{
	// Add the time to the total of minutes worked
	_minutesBeforeThisSession = [self minutesWorkedOnProject];
	// Remove this date, the time has been logged
	_currentSessionStart = nil;
	// Save the changes
	[self saveToUserDefaults];
}

- (void)doneWorking
{
	// This is called when the project is submitted, clear all the data
	_minutesBeforeThisSession = 0;
	_currentSessionStart = nil;
	// Save the change
	[self saveToUserDefaults];
}

- (void)deleteWork
{
	// This is called when the project is submitted, clear all the data
	_minutesBeforeThisSession = 0;
	_currentSessionStart = nil;
	// Save the change
	[self saveToUserDefaults];
}

#pragma mark Utils
- (void)loadFromUserDefaults
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	_minutesBeforeThisSession = [def integerForKey:[self savedTimeKey]];
	_currentSessionStart = [def objectForKey:[self lastStartKey]];
}

- (void)saveToUserDefaults
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	if (_minutesBeforeThisSession > 0)
	{
		[def setInteger:_minutesBeforeThisSession forKey:[self savedTimeKey]];
	}
	else
	{
		[def removeObjectForKey:[self savedTimeKey]];
	}
	
	if (_currentSessionStart != nil)
	{
		[def setObject:_currentSessionStart forKey:[self lastStartKey]];
	}
	else
	{
		[def removeObjectForKey:[self lastStartKey]];
	}
	[def synchronize];
}

#pragma mark UserDefault Keys
- (NSString *)savedTimeKey
{
	return [NSString stringWithFormat:@"%@%@", SAVED_TIME_KEY_PREFFIX, name];
}
- (NSString *)lastStartKey
{
	return [NSString stringWithFormat:@"%@%@", LAST_START_KEY_PREFFIX, name];
}

@end

///////////////////////////////////////////////////////////
#pragma mark PROJECT MANAGER
///////////////////////////////////////////////////////////

@interface FreckleProjectManager()

@property FreckleUserData *_userData;
@property FreckleAPIManager *_apiManager;
@property NSArray *_projectNames, *_projects;

@property SEL _onProjectsLoaded;
@property id _onProjectsLoadedTarget;

@property FreckleLoginWindowController *_loginWindow;

@end

@implementation FreckleProjectManager

// Private variables
@synthesize _userData, _apiManager;
@synthesize _projectNames, _projects;
@synthesize _onProjectsLoaded, _onProjectsLoadedTarget;
@synthesize _loginWindow;

- (id)initWithUserData:(FreckleUserData *)userData andAPIManager:(FreckleAPIManager *)apiManager
{
	self = [super init];
	
	_userData = userData;
	_apiManager = apiManager;
	 
	return self;
}


#pragma mark API
- (void)loadProjectsWithSelector:(SEL)selector andTarget:(id)target
{
	_projectNames = [_apiManager getProjectList];
	
	if (_projectNames != nil)
	{
		_projects = [NSArray arrayWithArray:[self getProjectsFrom:_projectNames]];
		[target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
	}
	else
	{
		// Save this to perform the callback later
		_onProjectsLoaded = selector;
		_onProjectsLoadedTarget = target;
		
		// Show login popup
		[self showLoginWindow];
	}
}

- (NSArray *)getProjects
{
	return [NSArray arrayWithArray:_projects];
}

- (NSArray *)getProjectNames
{
	return [NSArray arrayWithArray:_projectNames];
}

- (NSArray *)getActiveProjects
{
	NSMutableArray *actives = [[NSMutableArray alloc] init];
	
	FreckleProjectData *project;
	
	NSUInteger l = _projects.count;
	for (NSUInteger i = 0; i < l; i++)
	{
		project = [_projects objectAtIndex:i];
		if (project.isActive)
		{
			// The current project is always first.
			// By desing only one project should be worked on at any time.
			if (project.beingWorkedOn)
			{
				[actives insertObject:project atIndex:0];
			}
			else
			{
				[actives addObject:project];
			}
		}
	}
	
	return [NSArray arrayWithArray:actives];
}

- (FreckleProjectData *)getProjectByName:(NSString *)name
{
	NSUInteger l = _projects.count;
	for (NSUInteger i = 0; i < l; i++)
	{
		if ([[[_projects objectAtIndex:i] name] isEqualToString:name])
		{
			return [_projects objectAtIndex:i];
		}
	}
	
	return nil;
}

#pragma mark Utils
- (NSMutableArray *)getProjectsFrom:(NSArray *)names
{
	NSMutableArray *projects = [[NSMutableArray alloc] init];
	
	NSUInteger l = names.count;
	for (NSUInteger i = 0; i < l; i++)
	{
		[projects addObject:[[FreckleProjectData alloc] initWithName:[names objectAtIndex:i]]];
	}
	
	return projects;
}

- (void)loadProjects
{
	// Try to get the projects, if this fails, then the credentials are invalid and we ask again
	_projectNames = [_apiManager getProjectList];
	
	if (_projectNames != nil)
	{
		_projects = [NSArray arrayWithArray:[self getProjectsFrom:_projectNames]];
		[_onProjectsLoadedTarget performSelectorOnMainThread:_onProjectsLoaded withObject:nil waitUntilDone:NO];
	}
	else
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error connecting to Freckle" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Check your connection and try again"];
		[alert runModal];
		
		[self showLoginWindow];
	}
}

#pragma mark User Interface
- (void)showLoginWindow
{
	_loginWindow = [[FreckleLoginWindowController alloc] initWithUserData:_userData andDelegate:self];
	[[_loginWindow window] center];
	[_loginWindow showWindow:self];
	
	[NSApp activateIgnoringOtherApps:YES];
	[[_loginWindow window] makeKeyAndOrderFront:nil];
	[[_loginWindow window] setLevel:NSFloatingWindowLevel];
	[[_loginWindow window] center];
}

#pragma mark FreckleLoginWindowControllerDelegate
- (void)onLoginWindowClosed
{
	[self performSelectorInBackground:@selector(loadProjects) withObject:nil];
}

@end
