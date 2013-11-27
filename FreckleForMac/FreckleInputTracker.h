//
//  FreckleInputTracker.h
//  FreckleForMac
//
//  Created by Hernan on 11/25/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FreckleConfigurationManager.h"

@protocol FreckleInputTrackerDelegate <NSObject>

- (void)userWasInactiveFor:(NSUInteger)minutes;

@end

@interface FreckleInputTracker : NSObject

- (FreckleInputTracker *)initWithDelegate:(id<FreckleInputTrackerDelegate>)delegate andConfig:(FreckleConfigurationManager *)config;

- (void)onInput;

@end
