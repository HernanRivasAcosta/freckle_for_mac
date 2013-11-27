//
//  FreckleMenuletHandler.h
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FreckleUserData.h"
#import "FreckleProjectManager.h"
#import "FreckleSubmitProjectWindowController.h"
#import "FreckleInputTracker.h"

@interface FreckleMenuletHandler : NSObject <NSMenuDelegate, FreckleSubmitProjectWindowControllerDelegate, FreckleInputTrackerDelegate>

- (id)initWithUserData:(FreckleUserData *)userData apiManager:(FreckleAPIManager *)apiManager andProjectManager:(FreckleProjectManager *)projectManager;

- (void)onProjectSubmitted:(FreckleProjectData *)project;

@end
