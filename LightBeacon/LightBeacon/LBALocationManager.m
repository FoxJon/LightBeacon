//
//  LBALocationManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.

#import "LBALocationManager.h"
#import "LBAAlert.h"
#import "LBACenterVC.h"
#import <CoreLocation/CoreLocation.h>

@interface LBALocationManager () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSDictionary *currentLocation;
@end

@implementation LBALocationManager

+(instancetype)sharedManager{
    static LBALocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

-(instancetype)init{
    if((self = [super init])){
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startUpdatingLocation{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        [[LBAAlert sharedAlert] withTitle:@"Location Services Disabled" message:@"Please turn on location services in order to use this feature."];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    self.currentLocation = @{@"currentLat":[NSString stringWithFormat:@"%+.6f", location.coordinate.latitude], @"currentLng":[NSString stringWithFormat:@"%+.6f", location.coordinate.longitude]};
    
    [self.locationManager stopUpdatingLocation];
    
    [self.delegate updateCurrentLocation:self.currentLocation];
}

@end
