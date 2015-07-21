//
//  LBADefaultsManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBADefaultsManager.h"
#import "User.h"
#import "LBACoreDataManager.h"

@interface LBADefaultsManager ()
@property (nonatomic) User *user;
@end

@implementation LBADefaultsManager

+ (LBADefaultsManager *)sharedManager{
    static LBADefaultsManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (void)setUpDefaults{
    NSMutableArray *mutableFetchResults = [[LBACoreDataManager sharedManager]fetchEntityWithName:@"User"];
    
    if (mutableFetchResults.count == 0) {
        id object = [[LBACoreDataManager sharedManager]insertNewManagedObjectWithName:@"User"];
        if ([object isKindOfClass:[User class]]) {
            self.user = object;
            self.user.lightOnThreshold = [NSNumber numberWithFloat:80];
            self.user.lightOffThreshold = [NSNumber numberWithFloat:90];
            self.user.lightOffDelay = [NSNumber numberWithFloat:20];
            self.user.dimmerValue = [NSNumber numberWithFloat:1.0];
            self.user.sunriseSunsetMode = [NSNumber numberWithBool:YES];
            self.user.autoLightOn = [NSNumber numberWithBool:YES];
            self.user.lightSwitchOn = [NSNumber numberWithBool:NO];
            self.user.red = [NSNumber numberWithFloat:255];
            self.user.green = [NSNumber numberWithFloat:255];
            self.user.blue = [NSNumber numberWithFloat:255];
            self.user.alpha = [NSNumber numberWithFloat:1];
            
            [[LBACoreDataManager sharedManager]saveContextForEntity:@"User"];
        }
    }
}

@end
