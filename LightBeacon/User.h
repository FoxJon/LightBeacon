//
//  User.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/16/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * lightOnThreshold;
@property (nonatomic, retain) NSNumber * lightOffThreshold;
@property (nonatomic, retain) NSNumber * lightOffDelay;
@property (nonatomic, retain) NSNumber * dimmerValue;
@property (nonatomic, retain) NSNumber * sunriseSunsetMode;
@property (nonatomic, retain) NSNumber * autoLightOn;
@property (nonatomic, retain) NSNumber * lightSwitchOn;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSNumber * alpha;

+ (User *)fetchCurrentUser;

@end
