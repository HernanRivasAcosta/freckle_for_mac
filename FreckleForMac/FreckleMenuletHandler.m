//
//  FreckleMenuletHandler.m
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleMenuletHandler.h"

@interface FreckleMenuletHandler()

@property FreckleUserData *_userData;
@property FreckleAPIManager *_apiManager;
@property FreckleProjectManager *_projectManager;

@property NSStatusItem *_menuBarIcon;
@property NSMenu *_allProjectsMenu;
@property FreckleSubmitProjectWindowController *_submitWindow;

@property FreckleProjectData *_currentProject;

@end

@implementation FreckleMenuletHandler

// Received from parameters
@synthesize _userData, _apiManager, _projectManager;
// Private variables
@synthesize _menuBarIcon, _allProjectsMenu, _submitWindow;
@synthesize _currentProject;

- (id)initWithUserData:(FreckleUserData *)userData apiManager:(FreckleAPIManager *)apiManager andProjectManager:(FreckleProjectManager *)projectManager
{
	self = [super init];
	
	_userData = userData;
	_apiManager = apiManager;
	_projectManager = projectManager;
	[self createMenuBarIcon];
	
	return self;
}

#pragma mark Menu Creation
- (void)createMenuBarIcon
{
	_menuBarIcon = [[NSStatusBar systemStatusBar] statusItemWithLength:22];
	[_menuBarIcon setImage:[NSImage imageNamed:@"Status"]];
	[_menuBarIcon setAlternateImage:[NSImage imageNamed:@"StatusHighlighted"]];
	[_menuBarIcon setEnabled:YES];
	[_menuBarIcon setHighlightMode:YES];
	
	// We will to call this everytime there is a change either in favorites or active projects.
	// It is not necessary, but it would be nice to have some optimization here, we are not reusing anything.
	[self setMenuBarIconSubmenu];
}

- (void)setMenuBarIconSubmenu
{
	// Create the main menu
	NSMenu *menu = [[NSMenu alloc] init];
	
	[menu setDelegate:self];
	
	// Add all favorite and active projects
	[self fillMenuWithHighlightedProjects:menu];
	
	// Add an item with all the projects
	NSMenuItem *allProjects = [[NSMenuItem alloc] init];
	[allProjects setTitle:@"All Projects"];
	[allProjects setSubmenu:[self menuWithProjects]];
	[menu addItem:allProjects];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@""];
	[quit setTarget:self];
	[quit setEnabled:YES];
	[menu addItem:quit];
	
	// Set the menu
	[_menuBarIcon setMenu:menu];
}

- (void)fillMenuWithHighlightedProjects:(NSMenu *)menu
{
	NSUInteger itemsAdded, i, l;
	
	itemsAdded = 0;
	
	FreckleProjectData *project;
	
	NSString *itemName, *fullItemName;
	NSMenuItem *menuItem;
	
	NSArray *activeProjects = [_projectManager getActiveProjects];
	
	l = activeProjects.count;
	for (i = 0; i < l; i++)
	{
		project = [activeProjects objectAtIndex:i];
		
		if (project.beingWorkedOn)
		{
			_currentProject = project;
		}
		
		itemName = project.name;
		fullItemName = [NSString stringWithFormat:@"%@\t\t%@", [FreckleTimeParser formatMinutes:project.minutesWorkedOnProject], itemName];
		
		menuItem = [[NSMenuItem alloc] initWithTitle:fullItemName action:@selector(menuItemClicked:) keyEquivalent:@""];
		[menuItem setState:(project.beingWorkedOn ? NSOnState : NSOffState)];
		[menuItem setRepresentedObject:itemName];
		[menuItem setEnabled:YES];
		[menuItem setTarget:self];
		[menu addItem:menuItem];
		
		itemsAdded++;
	}
	
	if (itemsAdded > 0)
	{
		[menu addItem:[NSMenuItem separatorItem]];
		itemsAdded = 0;
	}
	
	l = _userData.favoriteProjects.count;
	for (i = 0; i < l; i++)
	{
		itemName = [_userData.favoriteProjects objectAtIndex:i];
		
		// If the item is active, it will not show on the favorites
		if (![self isActive:itemName])
		{
			menuItem = [[NSMenuItem alloc] initWithTitle:itemName action:@selector(menuItemClicked:) keyEquivalent:@""];
			[menuItem setRepresentedObject:itemName];
			[menuItem setEnabled:YES];
			[menuItem setTarget:self];
			[menu addItem:menuItem];
			
			itemsAdded++;
		}
	}
	
	if (itemsAdded > 0)
	{
		[menu addItem:[NSMenuItem separatorItem]];
	}
}

- (NSMenu *)menuWithProjects
{
	if (_allProjectsMenu != nil)
	{
		// Set the supermenu to nil to prevent xcode from thinking this submenu has multiple parents
		[_allProjectsMenu setSupermenu:nil];
		return _allProjectsMenu;
	}
	
	_allProjectsMenu = [[NSMenu alloc] init];
	
	NSUInteger l, i;
	NSArray *projectNames = [_projectManager getProjectNames];
	NSString *itemName;
	NSMenuItem *menuItem;
	
	l = projectNames.count;
	for (i = 0; i < l; i++)
	{
		itemName = [projectNames objectAtIndex:i];
		menuItem = [[NSMenuItem alloc] initWithTitle:itemName action:@selector(menuItemClicked:) keyEquivalent:@""];
		[menuItem setRepresentedObject:itemName];
		[menuItem setEnabled:YES];
		[menuItem setTarget:self];
		[_allProjectsMenu addItem:menuItem];
	}
	
	return _allProjectsMenu;
}

#pragma mark Selectors
- (void)quit:(NSMenuItem *)sender
{
	[NSApp terminate:self];
}

- (void)menuItemClicked:(NSMenuItem *)sender
{
	BOOL menuShouldChange = NO;
	
	NSString *buttonName = sender.representedObject;
	
	// Get the ProjectData (should not be nil)
	FreckleProjectData *project = [_projectManager getProjectByName:buttonName];
	
	[_userData addToFavorites:[project name]];
	
	// When pressing command
	if (([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask) != 0)
	{
		if (([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0)
		{
			if ([project isActive])
			{
				// If the project is active, delete it
				[project deleteWork];
			}
			else
			{
				// Otherwise, remove it from favorites
				[_userData removeFromFavorites:[project name]];
			}
			[self setMenuBarIconSubmenu];
			
		}
		// Otherwise, submit the project
		else
		{
			[self showSubmitWindowFor:project];
		}
	}
	else
	{
		if ([project beingWorkedOn])
		{
			[project stoppedWorking];
			// There is no current project
			_currentProject = nil;
		}
		else
		{
			[project startedWorking];
			
			// Stop the previous project (if any)
			if (_currentProject != nil)
				[_currentProject stoppedWorking];
			// Set this as the current project
			_currentProject = project;
		}
		
		// TEMP, check if it actually changed
		menuShouldChange = YES;
		
		// Always add the item to favorites, the function to do so returns true if the favorites changed
		menuShouldChange = [_userData addToFavorites:sender.representedObject] || menuShouldChange;
		
		// Refresh the menues if anything changed
		if (menuShouldChange)
		{
			[self setMenuBarIconSubmenu];
		}
	}
}

#pragma mark Utils
- (BOOL)isActive:(NSString *)projectName
{
	return [[_projectManager getProjectByName:projectName] isActive];
}

- (void)showSubmitWindowFor:(FreckleProjectData *)project
{
	_submitWindow = [[FreckleSubmitProjectWindowController alloc] initWithProject:project apiManager:_apiManager andDelegate:self];
	[[_submitWindow window] center];
	[_submitWindow showWindow:self];
	
	[NSApp activateIgnoringOtherApps:YES];
	[[_submitWindow window] makeKeyAndOrderFront:nil];
	[[_submitWindow window] setLevel:NSFloatingWindowLevel];
}

#pragma mark NSMenuDelegate
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSString *buttonName = menuItem.representedObject;
	
	if (buttonName != nil) // The Quit button has a no represented object
	{
		FreckleProjectData *project = [_projectManager getProjectByName:buttonName];
		
		if (project.isActive && [menuItem menu] != _allProjectsMenu)
		{
			// Use this function only to change the title and the state of the item
			NSString *itemName = [NSString stringWithFormat:@"%@\t\t%@", [FreckleTimeParser formatMinutes:project.minutesWorkedOnProject], project.name];
			[menuItem setTitle:itemName];
			[menuItem setState:(project.beingWorkedOn ? NSOnState : NSOffState)];
		}
		else
		{
			[menuItem setTitle:project.name];
		}
	}
	
	// Items are always enabled
	return YES;
}

#pragma mark FreckleSubmitProjectWindowControllerDelegate
- (void)onProjectSubmitted:(FreckleProjectData *)project
{
	[project doneWorking];
	
	if (project == _currentProject)
	{
		_currentProject = nil;
	}
	
	// Refresh the menu
	[self setMenuBarIconSubmenu];
}

@end
