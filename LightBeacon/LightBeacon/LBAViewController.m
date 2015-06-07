//
//  LBAViewController.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/6/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAViewController.h"
#import <Gimbal/Gimbal.h>

#define LIGHT_ON_THRESHOLD @"Light_On_Threshold"
#define LIGHT_OFF_THRESHOLD @"Light_Off_Threshold"

@interface LBAViewController () <GMBLPlaceManagerDelegate>
@property (nonatomic) GMBLPlaceManager *placeManager;
@property (weak, nonatomic) IBOutlet UITextView *textLog;
@property (nonatomic) NSMutableString *log;
@property (nonatomic) BOOL lightIsOn;
@property (nonatomic) BOOL delayTimerIsOn;

// User configurable properties
@property (nonatomic) BOOL userLightOffTimerIsOn;
@property (nonatomic) NSInteger userOnThreshold;
@property (nonatomic) NSInteger userOffThreshold;
@end

@implementation LBAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpConfigurations];
    [self setUpUserDefaults];
}


-(void)setUpConfigurations{
    self.log = [@"" mutableCopy];
    self.lightIsOn = NO;
    self.delayTimerIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    [GMBLPlaceManager startMonitoring];
}


-(void)setUpUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    if (![defaults objectForKey:LIGHT_ON_THRESHOLD]){
        NSDictionary *lightDefaults = @{LIGHT_ON_THRESHOLD:@-70, LIGHT_OFF_THRESHOLD:@-90};
        [defaults registerDefaults:lightDefaults];
    };
    
    self.userOnThreshold = (long)[defaults objectForKey:LIGHT_ON_THRESHOLD];
    self.userOffThreshold = (long)[defaults objectForKey:LIGHT_OFF_THRESHOLD];
}


#pragma mark - GMBL PLACE MANAGER DELEGATE METHODS
- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit{
    [self createDeveloperLogsWithVisit:visit withEvent:@"Begin"];
}


- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit{
    [self createDeveloperLogsWithVisit:visit withEvent:@"End"];
}


- (void)placeManager:(GMBLPlaceManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting forVisits:(NSArray *)visits{
    [self createDeveloperLogsWithSighting:sighting];
    if (!self.lightIsOn && !self.delayTimerIsOn) {
        if (sighting.RSSI > self.userOnThreshold){
            [self startDelay];
            self.view.backgroundColor = [UIColor blueColor];
        }
    }
    if (self.lightIsOn && !self.delayTimerIsOn && !self.userLightOffTimerIsOn) {
        if (sighting.RSSI < self.userOffThreshold){
            [self startUserLightOffTimer];
        }
    }
}


#pragma mark - HELPERS
-(void)createDeveloperLogsWithVisit:(GMBLVisit *)visit withEvent:(NSString *)event{
    NSString * visitLog;
    if ([event isEqualToString:@"Begin"]) {
        visitLog = [NSString stringWithFormat:@"Began visit at %@ at %@ \n\n", visit.place.name, visit.arrivalDate];
    }
    if ([event isEqualToString:@"End"]) {
        visitLog = [NSString stringWithFormat:@"Ended %f visit at %@ at %@ \n\n", visit.dwellTime, visit.place.name, visit.arrivalDate];
    }
    [self.log insertString:visitLog atIndex:0];
    self.textLog.text = self.log;
    NSLog(@"%@", visitLog);
}


-(void)createDeveloperLogsWithSighting:(GMBLBeaconSighting *)sighting{
    NSString *sightingLog;
    sightingLog = [NSString stringWithFormat:@"PLACE MANAGER SIGHTING: %@ sighted on %@ with RSSI: %li \n\n", sighting.beacon, sighting.date, (long)sighting.RSSI];
    [self.log insertString:sightingLog atIndex:0];
    self.textLog.text = self.log;
    NSLog(@"%@", sightingLog);
}


-(void)startDelay{
    self.delayTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(lightSwitchOn) userInfo:nil repeats:NO];
    [timer fire];
}


-(void)startUserLightOffTimer{
    self.userLightOffTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:20 target:self selector:@selector(turnOffUserLightOffTimer) userInfo:nil repeats:NO];
    [timer fire];
}


-(void)lightSwitchOn{
    self.lightIsOn = YES;
    self.delayTimerIsOn = NO;
}


-(void)turnOffUserLightOffTimer{
    self.lightIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    self.view.backgroundColor = [UIColor blackColor];
}

@end
