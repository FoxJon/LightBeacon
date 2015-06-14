//
//  LBALogManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/7/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBALogManager.h"

@implementation LBALogManager

+ (NSString *)createDeveloperLogsWithVisit:(GMBLVisit *)visit andEvent:(NSString *)event{
    NSString * visitLog;
    if ([event isEqualToString:@"Begin"]) {
        visitLog = [NSString stringWithFormat:@"Began visit at %@ at %@ \n\n", visit.place.name, visit.arrivalDate];
    }
    if ([event isEqualToString:@"End"]) {
        visitLog = [NSString stringWithFormat:@"Ended %f visit at %@ at %@ \n\n", visit.dwellTime, visit.place.name, visit.arrivalDate];
    }
    return visitLog;
}


+ (NSString *)createDeveloperLogsWithSighting:(GMBLBeaconSighting *)sighting{
    return [NSString stringWithFormat:@"PLACE MANAGER SIGHTING: %@ sighted on %@ with RSSI: %li \n\n", sighting.beacon, sighting.date, (long)sighting.RSSI];
}

@end
