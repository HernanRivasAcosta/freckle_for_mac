//
//  FreckleConfigurationManager.m
//  FreckleForMac
//
//  Created by Hernan on 11/25/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleConfigurationManager.h"

@implementation FreckleConfigurationManager

#pragma mark Public properties
@synthesize maximumInactivityTime;

#pragma mark Constants
static NSString *const INACTIVE_TIME_KEY = @"maxInactiveTime";

- (FreckleConfigurationManager *)init
{
	self = [super init];
	
	if (self != nil)
	{
		[self loadFromDefaults];
	}
	
	return self;
}

#pragma mark API
- (void)maximumInactivityTime:(NSUInteger)seconds
{
	maximumInactivityTime = seconds;
	
	[self saveToDefaults];
}

#pragma mark UserDefaults
- (void)loadFromDefaults
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	if ([def objectForKey:INACTIVE_TIME_KEY] != nil)
	{
		maximumInactivityTime = [def integerForKey:INACTIVE_TIME_KEY];
	}
	else
	{
		// Use the default value (5 minutes)
		maximumInactivityTime = 5;
	}
}

- (void)saveToDefaults
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	[def setInteger:maximumInactivityTime forKey:INACTIVE_TIME_KEY];
}

@end
