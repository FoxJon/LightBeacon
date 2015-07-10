//
//  LBALocationManager.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LBALocationManagerDelegate <NSObject>

- (void)updateCurrentLocation:(NSDictionary *)location;

@end

@interface LBALocationManager : NSObject

@property id<LBALocationManagerDelegate> delegate;

+(instancetype)sharedManager;
- (void)startUpdatingLocation;

@end
