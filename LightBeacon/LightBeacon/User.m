//
//  User.m
//  LightBeacon
//
//  Created by Jonathan Fox on 8/25/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "User.h"
#import "LBACoreDataManager.h"

@implementation User

@dynamic alpha;
@dynamic autoLightOn;
@dynamic blue;
@dynamic dimmerValue;
@dynamic green;
@dynamic lightOffDelay;
@dynamic lightOffThreshold;
@dynamic lightOnThreshold;
@dynamic lightSwitchOn;
@dynamic red;
@dynamic sunriseSunsetMode;


+ (User *)fetchCurrentUser{
    User *user = nil;
    id object = [[[LBACoreDataManager sharedManager]fetchEntityWithName:@"User"]firstObject];
    if ([object isKindOfClass:[User class]]) {
        user = object;
    }
    return user;
}
@end
