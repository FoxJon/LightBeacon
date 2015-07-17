//
//  LBADefaultsManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBADefaultsManager.h"
#import "LBAConstants.h"


@implementation LBADefaultsManager

+ (void)setUpDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults floatForKey:LIGHT_ON_THRESHOLD]){
        [defaults setFloat:80 forKey:LIGHT_ON_THRESHOLD];
        [defaults setFloat:90 forKey:LIGHT_OFF_THRESHOLD];
        [defaults setFloat:20 forKey:LIGHT_OFF_DELAY];
        [defaults setFloat:1.0 forKey:DIMMER_VALUE];
        [defaults setBool:YES forKey:SUNRISE_SUNSET_MODE];
        [defaults setBool:YES forKey:AUTO_LIGHT_ON];
        [defaults setBool:NO forKey:LIGHT_SWITCH_ON];
        [defaults setFloat:255 forKey:CURRENT_COLOR_RED];
        [defaults setFloat:255 forKey:CURRENT_COLOR_GREEN];
        [defaults setFloat:255 forKey:CURRENT_COLOR_BLUE];
        [defaults setFloat:1 forKey:CURRENT_ALPHA];
    };
}
@end
