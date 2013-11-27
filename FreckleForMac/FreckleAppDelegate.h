//
//  FreckleAppDelegate.h
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FreckleUserData.h"
#import "FreckleAPIManager.h"
#import "FreckleProjectManager.h"
#import "FreckleConfigurationManager.h"
#import "FreckleMenuletHandler.h"
#import "FreckleInputTracker.h"


@interface FreckleAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;

@property FreckleConfigurationManager *configurationManager;

@property FreckleUserData *userData;
@property FreckleAPIManager *apiManager;
@property FreckleProjectManager *projectManager;

@property FreckleMenuletHandler *menuletHandler;
@property FreckleInputTracker *inputTracker;

@end
