//
//  FreckleUserData.h
//  FreckleForMac
//
//  Created by Hernan on 11/3/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FreckleUserData : NSObject

- (BOOL)loggedIn;

- (NSString *)domain;
- (NSString *)token;
- (NSArray *)favoriteProjects;

- (BOOL)addToFavorites:(NSString *)projectName;
- (void)removeFromFavorites:(NSString *)projectName;
- (void)setDomain:(NSString *)domain andToken:(NSString *)token;

@end
