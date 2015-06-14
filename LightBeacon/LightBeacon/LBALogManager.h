//
//  LBALogManager.h
//  LightBeacon
//
//  Created by Jonathan Fox on 6/7/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gimbal/Gimbal.h>

@interface LBALogManager : NSObject

+ (NSString *)createDeveloperLogsWithVisit:(GMBLVisit *)visit andEvent:(NSString *)event;
+ (NSString *)createDeveloperLogsWithSighting:(GMBLBeaconSighting *)sighting;

@end
