//
//  FreckleProjectManager.h
//  FreckleForMac
//
//  Created by Hernan on 11/4/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FreckleAPIManager.h"
#import "FreckleLoginWindowController.h"

///////////////////////////////////////////////////////////
#pragma mark PROJECT DATA
///////////////////////////////////////////////////////////

@interface FreckleProjectData : NSObject

@property (readonly) NSString *name;

- (id)initWithName:(NSString *)aName;

- (BOOL)beingWorkedOn;
- (BOOL)hasUnsavedTime;
- (BOOL)isActive;

- (NSUInteger)secondsWorkedOnProject;
- (NSUInteger)minutesWorkedOnProject;

- (void)startedWorking;
- (void)stoppedWorking;
- (void)doneWorking;

- (void)deleteWork;

- (void)removeTrackedTime:(NSUInteger)minutes;

@end

///////////////////////////////////////////////////////////
#pragma mark PROJECT MANAGER
///////////////////////////////////////////////////////////

@interface FreckleProjectManager : NSObject <FreckleLoginWindowControllerDelegate>

- (id)initWithUserData:(FreckleUserData *)userData andAPIManager:(FreckleAPIManager *)apiManager;

- (void)loadProjectsWithSelector:(SEL)selector andTarget:(id)target;

- (NSArray *)getProjects;
- (NSArray *)getProjectNames;
- (NSArray *)getActiveProjects;
- (FreckleProjectData *)getProjectByName:(NSString *)name;

- (void)onLoginWindowClosed;

@end
