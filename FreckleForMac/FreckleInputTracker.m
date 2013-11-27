//
//  FreckleInputTracker.m
//  FreckleForMac
//
//  Created by Hernan on 11/25/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleInputTracker.h"

@interface FreckleInputTracker()

@property id<FreckleInputTrackerDelegate> delegate;
@property FreckleConfigurationManager *config;
@property CFAbsoluteTime lastInput;

@end

@implementation FreckleInputTracker

- (FreckleInputTracker *)initWithDelegate:(id<FreckleInputTrackerDelegate>)delegate andConfig:(FreckleConfigurationManager *)config
{
	self = [super init];
	
	if (self != nil)
	{
		_delegate = delegate;
		_config = config;
		
		_lastInput = CFAbsoluteTimeGetCurrent();
	}
	
	return self;
}

#pragma mark API
- (void)onInput
{
	CFAbsoluteTime currTime = CFAbsoluteTimeGetCurrent();
	
	CFAbsoluteTime diff = (currTime - _lastInput) / 60.0;
	if ([_config maximumInactivityTime] > 0 && diff > [_config maximumInactivityTime])
	{
		[_delegate userWasInactiveFor:diff];
	}
	
	_lastInput = currTime;
}

@end
