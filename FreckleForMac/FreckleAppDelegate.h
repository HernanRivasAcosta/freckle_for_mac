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
#import "FreckleMenuletHandler.h"

@interface FreckleAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property FreckleUserData *userData;
@property FreckleAPIManager *apiManager;
@property FreckleProjectManager *projectManager;

@property FreckleMenuletHandler *menuletHandler;

@end
