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

@synthesize configurationManager, userData, apiManager, projectManager, menuletHandler, inputTracker;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Set the notification center delegate to self, this will allow us to force notifications to appear, regardless of wether our app is key or not (http://stackoverflow.com/questions/11814903/send-notification-to-mountain-lion-notification-center)
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	
	// Create the configuration and the user data, this automatically loads the defaults
	configurationManager = [[FreckleConfigurationManager alloc] init];
	userData = [[FreckleUserData alloc] init];
	
	// The API manager manages the requests to Freckle, requieres the userData to get both the domain and the token and the configuration to read some user defined values
	apiManager = [[FreckleAPIManager alloc] initWithUserData:userData andConfiguration:configurationManager];
	
	// The project manager uses the API manager to get the project list
	projectManager = [[FreckleProjectManager alloc] initWithUserData:userData andAPIManager:apiManager];
	[projectManager loadProjectsWithSelector:@selector(onProjectsLoaded) andTarget:self];
}

#pragma mark Utils
- (void)onProjectsLoaded
{
	NSLog(@"creating menulet");
	menuletHandler = [[FreckleMenuletHandler alloc] initWithUserData:userData apiManager:apiManager andProjectManager:projectManager];

	inputTracker = [[FreckleInputTracker alloc] initWithDelegate:menuletHandler andConfig:configurationManager];
	
	_eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSLeftMouseUpMask | NSRightMouseDownMask | NSRightMouseUpMask | NSMouseMovedMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask | NSMouseEnteredMask | NSMouseExitedMask | NSKeyDownMask | NSKeyUpMask | NSFlagsChangedMask | NSAppKitDefinedMask | NSSystemDefinedMask | NSApplicationDefinedMask | NSPeriodicMask | NSCursorUpdateMask | NSScrollWheelMask | NSTabletPointMask | NSTabletProximityMask | NSOtherMouseDownMask | NSOtherMouseUpMask | NSOtherMouseDraggedMask | NSEventMaskGesture | NSEventMaskMagnify | NSEventMaskSwipe | NSEventMaskRotate | NSEventMaskBeginGesture | NSEventMaskEndGesture handler:^(NSEvent *evt) {
		[inputTracker onInput];
	}];
}

#pragma mark NSUserNotificationCenterDelegate
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	// Always show notifications, even if we are the key app
	return YES;
}


@end
