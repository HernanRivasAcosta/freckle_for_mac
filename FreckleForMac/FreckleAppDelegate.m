//
//  FreckleAppDelegate.m
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleAppDelegate.h"

@interface FreckleAppDelegate()

@property id eventHandler;

@end

@implementation FreckleAppDelegate

@synthesize userData, apiManager, projectManager, configurationManager, menuletHandler, inputTracker;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Create the user data, this automatically loads the defaults
	userData = [[FreckleUserData alloc] init];
	
	// The API manager manages the requests to Freckle, requieres the userData to get both the domain and the token
	apiManager = [[FreckleAPIManager alloc] initWithUserData:userData];
	
	// The project manager uses the API manager to get the project list
	projectManager = [[FreckleProjectManager alloc] initWithUserData:userData andAPIManager:apiManager];
	[projectManager loadProjectsWithSelector:@selector(onProjectsLoaded) andTarget:self];
}

#pragma mark Utils
- (void)onProjectsLoaded
{
	configurationManager = [[FreckleConfigurationManager alloc] init];
	
	NSLog(@"creating menulet");
	menuletHandler = [[FreckleMenuletHandler alloc] initWithUserData:userData apiManager:apiManager andProjectManager:projectManager];

	inputTracker = [[FreckleInputTracker alloc] initWithDelegate:menuletHandler andConfig:configurationManager];
	
	_eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSLeftMouseUpMask | NSRightMouseDownMask | NSRightMouseUpMask | NSMouseMovedMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask | NSMouseEnteredMask | NSMouseExitedMask | NSKeyDownMask | NSKeyUpMask | NSFlagsChangedMask | NSAppKitDefinedMask | NSSystemDefinedMask | NSApplicationDefinedMask | NSPeriodicMask | NSCursorUpdateMask | NSScrollWheelMask | NSTabletPointMask | NSTabletProximityMask | NSOtherMouseDownMask | NSOtherMouseUpMask | NSOtherMouseDraggedMask | NSEventMaskGesture | NSEventMaskMagnify | NSEventMaskSwipe | NSEventMaskRotate | NSEventMaskBeginGesture | NSEventMaskEndGesture handler:^(NSEvent *evt) {
		[inputTracker onInput];
	}];
}


@end
