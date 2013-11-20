//
//  FreckleTimeParser.h
//  FreckleForMac
//
//  Created by Hernan on 11/10/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FreckleTimeParser : NSObject

+ (NSString *)formatMinutes:(NSUInteger)minutes;
+ (NSString *)formatSeconds:(NSUInteger)seconds;
+ (NSUInteger)minutesFromString:(NSString *)string;

@end
