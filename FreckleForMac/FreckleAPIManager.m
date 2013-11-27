//
//  FreckleAPIManager.m
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleAPIManager.h"

@interface FreckleAPIManager()

@property FreckleUserData *userData;
@property FreckleConfigurationManager *config;

@end

@implementation FreckleAPIManager

- (id)initWithUserData:(FreckleUserData *)userData andConfiguration:(FreckleConfigurationManager *)config
{
	self = [super init];
	
	if (self != nil)
	{
		_userData = userData;
		_config = config;
	}
	
	return self;
}

#pragma mark API
- (NSArray *)getProjectList
{
	NSArray *result = nil;
	
	if (!_userData.loggedIn)
	{
		return result;
	}
	
	NSString *urlStr = [self getURLForEndPoint:@"projects.json"];
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
	[self addTokenToRequest:req];
	[req setHTTPMethod:@"GET"];
	
	NSError *urlConnError = nil;
	NSHTTPURLResponse *urlConnResponse = nil;
	NSData *reqData = [NSURLConnection sendSynchronousRequest:req returningResponse:&urlConnResponse error:&urlConnError];
	
	if (urlConnResponse != nil && urlConnResponse.statusCode == 200)
	{
		result = [[NSMutableArray alloc] init];
		
		NSArray *projects = [NSJSONSerialization JSONObjectWithData:reqData options:0 error:&urlConnError];
		NSUInteger l = projects.count;
		for (NSUInteger i = 0; i < l; i++)
		{
			[(NSMutableArray *)result addObject:[[[projects objectAtIndex:i] valueForKey:@"project"] valueForKey:@"name"]];
		}
		NSLog(@"project list is %@", result);
		
		result = [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	}
	else
	{
		NSString *msg = @"unable to retrieve projects, reason: %@";
		
		if (urlConnError != nil)
		{
			msg = [NSString stringWithFormat:msg, urlConnError];
		}
		else
		{
			msg = [NSString stringWithFormat:msg, @"unknown"];
		}
		NSLog(@"%@", msg);
	}
	
	return result;
}

- (void)log:(NSUInteger)minutes onProject:(NSString *)project withComments:(NSString *)comments
{
	NSString *postString = @"{\"entry\":{\"minutes\":\"%@\", \"date\":\"%@\", \"project-name\":\"%@\", \"description\":\"%@\", \"allow_hashtags\":\"true\"}}";
	
	NSDate *currentDate = [NSDate date];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:currentDate];
	
	NSString *date = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)components.year, (long)components.month, (long)components.day];
	NSString *time = [FreckleTimeParser formatMinutes:minutes];
	NSString *jsonToSend = [NSString stringWithFormat:postString, time, date, project, comments];
	
	NSString *urlStr = [self getURLForEndPoint:@"entries.json"];
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
	[self addTokenToRequest:req];
	[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPMethod:@"POST"];
	[req setHTTPBody:[jsonToSend dataUsingEncoding:NSUTF8StringEncoding]];
	
	[NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
	 {
		 NSLog(@"Received %ld with body %@", (long)[(NSHTTPURLResponse *)response statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		 
		 if([(NSHTTPURLResponse *)response statusCode] == 201)
		 {
			 NSLog(@"Successfully logged time on %@", project);
			 
			 if (_config.allowNotifications)
			 {
				 // Create a notification
				 NSUserNotification *notification = [[NSUserNotification alloc] init];
				 notification.title = @"Project submitted";
				 notification.informativeText = [NSString stringWithFormat:@"Time has been successfully logged on %@", project];
				 notification.soundName = NSUserNotificationDefaultSoundName;
				 
				 [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			 }
		 }
		 else
		 {
			 NSString *msg = @"Unable to log time on %@, reason: %@";
			 
			 if (connectionError != nil)
			 {
				 msg = [NSString stringWithFormat:@"Unable to log time on %@, reason: %@", project, connectionError.localizedDescription];
			 }
			 else
			 {
				 msg = [NSString stringWithFormat:@"Unable to log time on %@, reason: %@", project, @"unknown"];
			 }
			 
			 NSAlert *alert = [NSAlert alertWithMessageText:msg defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
			 [alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
		 }
	 }];
}

#pragma mark Utils
- (NSString *)getURLForEndPoint:(NSString *)endPoint
{
	return [NSString stringWithFormat:@"https://%@.letsfreckle.com/api/%@", _userData.domain, endPoint];
}

- (void)addTokenToRequest:(NSMutableURLRequest *)request
{
	[request addValue:_userData.token forHTTPHeaderField:@"X-FreckleToken"];
}

@end
