//
//  LBADefaultsManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBADefaultsManager.h"

#define LIGHT_ON_THRESHOLD @"Light_On_Threshold"
#define LIGHT_OFF_THRESHOLD @"Light_Off_Threshold"
#define USER_LIGHT_OFF_DELAY @"User_light_Off_Delay"

@implementation LBADefaultsManager

+ (void)setUpDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    if (![defaults objectForKey:LIGHT_ON_THRESHOLD]){
        NSDictionary *lightDefaults = @{LIGHT_ON_THRESHOLD:@80, LIGHT_OFF_THRESHOLD:@90, USER_LIGHT_OFF_DELAY:@20, @"sunriseSunsetMode": @YES};
        [defaults registerDefaults:lightDefaults];
    };
}
@end
