//
//  FreckleUserData.m
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleUserData.h"

@interface FreckleUserData()

@property (nonatomic) NSString *domain, *token;
@property (nonatomic) NSMutableArray *favoriteProjects;

@end

@implementation FreckleUserData

// NSUserDefaults keys
static NSString *const DOMAIN_KEY = @"freckleDomain";
static NSString *const TOKEN_KEY = @"token";
static NSString *const FAVORITE_PROJECTS_KEY = @"favoriteProjects";

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		[self loadFromDefaults];
	}
	
	return self;
}

#pragma mark API
- (BOOL)loggedIn
{
	return _domain != nil && _token != nil;
}

- (NSString *)domain
{
	return _domain;
}

- (NSString *)token
{
	return _token;
}

- (NSArray *)favoriteProjects
{
	return [NSArray arrayWithArray:_favoriteProjects];
}

- (BOOL)addToFavorites:(NSString *)projectName
{
	// Do nothing if this is already the favorite project
	if (_favoriteProjects.count > 0 && [[_favoriteProjects objectAtIndex:0] isEqualToString:projectName])
	{
		return NO;
	}
	
	[_favoriteProjects removeObject:projectName];
	[_favoriteProjects insertObject:projectName atIndex:0];
		
	// This array should only be increased in the previous line, so this is overkill
	while (_favoriteProjects.count > 5)
		[_favoriteProjects removeLastObject];
	
	[self saveToDefaults];
	return YES;
}

- (void)removeFromFavorites:(NSString *)projectName
{
	[_favoriteProjects removeObject:projectName];
	[self saveToDefaults];
}

- (void)setDomain:(NSString *)domain andToken:(NSString *)token
{
	_domain = domain;
	_token = token;
	
	[self saveToDefaults];
}

#pragma mark Utils
- (void)loadFromDefaults
{
	// Uncomment this line when debugging, simple way to clear the saved credentials
	//[self saveToDefaults];
	
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	_domain = [def objectForKey:DOMAIN_KEY];
	_token = [def objectForKey:TOKEN_KEY];
	if ([def objectForKey:FAVORITE_PROJECTS_KEY] != nil)
	{
		// We need this list to be a mutable array
		_favoriteProjects = [NSMutableArray arrayWithArray:[def objectForKey:FAVORITE_PROJECTS_KEY]];
	}
	else
	{
		_favoriteProjects = [NSMutableArray array];
	}
}

- (void)saveToDefaults
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	[def setObject:_domain forKey:DOMAIN_KEY];
	[def setObject:_token forKey:TOKEN_KEY];
	[def setObject:_favoriteProjects forKey:FAVORITE_PROJECTS_KEY];
}

@end
