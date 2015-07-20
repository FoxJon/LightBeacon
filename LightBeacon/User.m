//
//  User.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/16/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "User.h"
#import "LBACoreDataManager.h"

@implementation User

@dynamic lightOnThreshold;
@dynamic lightOffThreshold;
@dynamic lightOffDelay;
@dynamic dimmerValue;
@dynamic sunriseSunsetMode;
@dynamic autoLightOn;
@dynamic lightSwitchOn;
@dynamic red;
@dynamic green;
@dynamic blue;
@dynamic alpha;

+ (User *)fetchCurrentUser{
    User *user = nil;
    id object = [[[LBACoreDataManager sharedManager]fetchEntityWithName:@"User"]firstObject];
    if ([object isKindOfClass:[User class]]) {
        user = object;
    }
    return user;
}

@end
