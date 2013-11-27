//
//  FreckleConfigurationManager.h
//  FreckleForMac
//
//  Created by Hernan on 11/25/13.
//  Copyright (c) 2013 Hernan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FreckleConfigurationManager : NSObject

@property (nonatomic, setter=maximumInactivityTime:) NSUInteger maximumInactivityTime;
@property (nonatomic) BOOL allowNotifications;

- (FreckleConfigurationManager *)init;

// In minutes
- (void)maximumInactivityTime:(NSUInteger)seconds;

@end
