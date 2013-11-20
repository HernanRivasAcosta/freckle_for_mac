//
//  FreckleAppDelegate.m
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleAppDelegate.h"

@implementation FreckleAppDelegate

@synthesize userData, apiManager, projectManager, menuletHandler;

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

#import "FreckleSubmitProjectWindowController.h"

#pragma mark Utils
- (void)onProjectsLoaded
{
	NSLog(@"creating menulet");
	menuletHandler = [[FreckleMenuletHandler alloc] initWithUserData:userData apiManager:apiManager andProjectManager:projectManager];
}

@end
