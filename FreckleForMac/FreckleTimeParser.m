//
//  FreckleTimeParser.m
//  FreckleForMac
//
//  Created by Hernan on 11/10/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import "FreckleTimeParser.h"

@implementation FreckleTimeParser

#pragma mark API
+ (NSString *)formatMinutes:(NSUInteger)minutes
{
	NSUInteger m = minutes % 60;
	NSUInteger h = (minutes - m) / 60;
	
	NSString *mStr = [NSString stringWithFormat:(m >= 10 ? @"%lu" : @"0%lu"), (unsigned long)m];
	NSString *hStr = [NSString stringWithFormat:(h >= 10 ? @"%lu" : @"0%lu"), (unsigned long)h];
	
	return [NSString stringWithFormat:@"%@:%@", hStr, mStr];
}

+ (NSString *)formatSeconds:(NSUInteger)seconds
{
	NSUInteger s = seconds % 60;
	
	NSString *sStr = [NSString stringWithFormat:(s >= 10 ? @"%lu" : @"0%lu"), (unsigned long)s];
	NSString *hStr = [FreckleTimeParser formatMinutes:(seconds - s) / 60];
	
	return [NSString stringWithFormat:@"%@:%@", hStr, sStr];
}

// This function does the best it can to match according to this style rules:
// http://letsfreckle.com/blog/2011/10/more-than-meets-the-eye-the-quick-entry-box/
// Note that some of this are not considered valid
+ (NSUInteger)minutesFromString:(NSString *)string
{
	// Matches digits and nothing else
	NSString *matchDigit = @"\\d+";
	// Matches a time given in the format 2h3m, minutes are optional
	NSString *matchHoursAndMinutes = @"(\\d+h)(\\d+(?:m)?)?";
	// Matches an hour separated by a colon, like 2:21
	NSString *matchColon = @"(\\d+)\\:(\\d+)";
	// Matches a number of minutes, like 3m or 95m
	NSString *matchMinutes = @"()(\\d+m)";
	
	// This variable will be reused
	NSRegularExpression *regEx;
	NSRegularExpressionOptions opts = NSRegularExpressionCaseInsensitive;
	NSError *error = nil;
	
	NSRange strRange = NSMakeRange(0, string.length);
	
	// First, match digits with no letters or colons, this has its special logic to determine if it is a minute or an hour
	regEx = [NSRegularExpression regularExpressionWithPattern:matchDigit options:opts error:&error];
	NSRange matchRange = [regEx rangeOfFirstMatchInString:string options:0 range:strRange];
	// Comparing location to NSNotFound is not enough, we probably matched a digit, we need to know if the entire string is only made with numbers
	if (matchRange.location == 0 && matchRange.length == string.length)
	{
		NSUInteger n = [string integerValue];
		// All numbers smaller than 10 are considered hours (who would log a single minute?)
		return n < 10 ? n * 60 : n;
	}
	
	NSArray *matches;
	NSUInteger minutesInMatch;
	
	// Convert each string into a RegularExpression object and check the result
	regEx = [NSRegularExpression regularExpressionWithPattern:matchHoursAndMinutes options:opts error:&error];
	matches = [regEx matchesInString:string options:0 range:strRange];
	minutesInMatch = [FreckleTimeParser minutesFromArray:matches andString:string];
	if (minutesInMatch != 0)
		return minutesInMatch;
	
	regEx = [NSRegularExpression regularExpressionWithPattern:matchColon options:opts error:&error];
	matches = [regEx matchesInString:string options:0 range:strRange];
	minutesInMatch = [FreckleTimeParser minutesFromArray:matches andString:string];
	if (minutesInMatch != 0)
		return minutesInMatch;
	
	regEx = [NSRegularExpression regularExpressionWithPattern:matchMinutes options:opts error:&error];
	matches = [regEx matchesInString:string options:0 range:strRange];
	minutesInMatch = [FreckleTimeParser minutesFromArray:matches andString:string];
	if (minutesInMatch != 0)
		return minutesInMatch;
	
	return 0;
}

+ (NSUInteger)minutesFromArray:(NSArray *)array andString:(NSString *)string
{
	// Only one match allowed
	if (array.count != 1)
		return 0;
	// Get the match
	NSTextCheckingResult *match = [array objectAtIndex:0];
	// Check if a match was found
	if (match.range.location == NSNotFound)
		return 0;
	// Check if the match matches the whole string
	if (match.range.length != string.length)
		return 0;
	// We can parse the string now
	NSUInteger result = [[string substringWithRange:[match rangeAtIndex:1]] integerValue] * 60;
	if ([match rangeAtIndex:2].length > 0)
		return result + [[string substringWithRange:[match rangeAtIndex:2]] integerValue];
	else
		return result;
}

@end
