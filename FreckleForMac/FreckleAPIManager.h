//
//  FreckleAPIManager.h
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FreckleUserData.h"
#import "FreckleTimeParser.h"

@interface FreckleAPIManager : NSObject

- (id)initWithUserData:(FreckleUserData *)userData;

- (NSArray *)getProjectList;
- (void)log:(NSUInteger)minutes onProject:(NSString *)projectName withComments:(NSString *)comments;

@end
