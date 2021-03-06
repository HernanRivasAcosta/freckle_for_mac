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

@property NSInteger minutesBeforeThisSession;
@property NSDate *currentSessionStart;

@end

@implementation FreckleProjectData

// Public variables
@synthesize name;
// UserDefault keys
static NSString *const SAVED_TIME_KEY_PREFFIX = @"savedTimeFor";
static NSString *const LAST_START_KEY_PREFFIX = @"lastStartOf";

- (id)initWithName:(NSString *)aName
{
	self = [super init];
	
	if (self != nil)
	{
		name = aName;
		[self loadFromUserDefaults];
	}
	
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
	NSInteger secs = _minutesBeforeThisSession * 60 + currentWorkedTime;
	return secs > 0 ? secs : 0;
}

- (NSUInteger)minutesWorkedOnProject
{
	NSTimeInterval currentWorkedTime = -[_currentSessionStart timeIntervalSinceNow];
	NSInteger mins = _minutesBeforeThisSession + ceil(currentWorkedTime / 60);
	return mins > 0 ?  mins : 0;
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
	_minutesBeforeThisSession = 0;
	_currentSessionStart = nil;
	// Save the change
	[self saveToUserDefaults];
}

- (void)removeTrackedTime:(NSUInteger)minutes
{
	_minutesBeforeThisSession -= minutes;
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

@property FreckleUserData *userData;
@property FreckleAPIManager *apiManager;
@property NSArray *projectNames, *projects;

@property SEL onProjectsLoaded;
@property id onProjectsLoadedTarget;

@property FreckleLoginWindowController *loginWindow;

@end

@implementation FreckleProjectManager

- (id)initWithUserData:(FreckleUserData *)userData andAPIManager:(FreckleAPIManager *)apiManager
{
	self = [super init];
	
	if (self != nil)
	{
		_userData = userData;
		_apiManager = apiManager;
	}
	 
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
	
	for (project in _projects)
	{
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
	for (FreckleProjectData *project in _projects)
	{
		if ([project.name isEqualToString:name])
		{
			return project;
		}
	}
	
	return nil;
}

#pragma mark Utils
- (NSMutableArray *)getProjectsFrom:(NSArray *)names
{
	NSMutableArray *projects = [[NSMutableArray alloc] init];
	
	for (NSString *name in names)
	{
		[projects addObject:[[FreckleProjectData alloc] initWithName:name]];
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
