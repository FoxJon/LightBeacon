//
//  LBACenterVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBACenterVC.h"
#import "LBALogManager.h"
#import "LBAColorConstants.h"
#import "LBARectangleView.h"
#import "LBAPlusSign.h"
#import "LBAMinusSign.h"
#import <Gimbal/Gimbal.h>
#import <CoreLocation/CoreLocation.h>
#import "LBADefaultsManager.h"
#import "LBAAlert.h"
#import "LBALocationManager.h"

@interface LBACenterVC () <GMBLPlaceManagerDelegate, LBALocationManagerDelegate>
@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableString *log;

@property (nonatomic) BOOL lightIsOn;
@property (nonatomic) BOOL delayTimerIsOn;
@property (nonatomic) BOOL placeManagerIsMonitoring;
@property (nonatomic) UIColor *liteTintColor;
@property (nonatomic) UIColor *darkTintColor;
@property (nonatomic) UIColor *whiteTintColor;
@property (nonatomic) NSDictionary *currentLocation;
@property (nonatomic) NSDictionary *sunriseSunset;
@property (nonatomic) BOOL sunriseSunsetSwitchIsOn;
@property (weak, nonatomic) IBOutlet UIView *centerContainerView;

// User configurable properties
@property (nonatomic) BOOL userLightOffTimerIsOn;
@property (nonatomic) int redColor;
@property (nonatomic) int greenColor;
@property (nonatomic) int blueColor;
@property (nonatomic) float alpha;

//UI Elements
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *darkTintColorElements;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lightTintColorElements;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *dimmerSlider;
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet LBARectangleView *dimBox;
@property (weak, nonatomic) IBOutlet UILabel *lowBatteryLabel;
@property (nonatomic) int entrySliderValue;
@property (nonatomic) int exitSliderValue;
@property (nonatomic) int exitDelaySliderValue;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;

@end

@implementation LBACenterVC

NSUserDefaults *defaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self setUpConfigurations];
    [LBADefaultsManager setUpDefaults];
    [self setTintColors];
    [self changeBackgroundColor];
    [self setUpVerticalSlider];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    
    [[LBALocationManager sharedManager] startUpdatingLocation];
    
    self.log = [@""mutableCopy];
    self.lowBatteryLabel.hidden = YES;
    
    for (UILabel *label in self.lightTintColorElements) {
        label.tintColor = self.liteTintColor;
    }
    for (UIView *view in self.darkTintColorElements) {
        view.tintColor = self.darkTintColor;
    }
    self.lightSwitch.onTintColor = self.darkTintColor;
    self.lightSwitch.tintColor = self.liteTintColor;
    self.lightSwitch.thumbTintColor = self.whiteTintColor;
    self.autoSwitch.onTintColor = self.darkTintColor;
    self.autoSwitch.tintColor = self.liteTintColor;
    self.autoSwitch.thumbTintColor = self.whiteTintColor;
    self.settingsButton.tintColor = self.liteTintColor;
    self.favsButton.tintColor = self.liteTintColor;
}


- (void)getSunriseSunset{
    if (self.sunriseSunsetSwitchIsOn && [CLLocationManager locationServicesEnabled]) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
        NSString *forecastIOAPIKey = [dictionary objectForKey:@"ForecastAPIKey"];
        NSURL *baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/", forecastIOAPIKey]];
        NSURL *forecastURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@,%@", [self.currentLocation objectForKey:@"currentLat"], [self.currentLocation objectForKey:@"currentLng"]] relativeToURL:baseUrl];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:forecastURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSData *data = [NSData dataWithContentsOfURL:location];
                NSDictionary *weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSNumber *sunset = weatherDictionary[@"daily"][@"data"][0][@"sunsetTime"];
                NSNumber *sunrise = weatherDictionary[@"daily"][@"data"][1][@"sunriseTime"];
                self.sunriseSunset = @{@"sunrise":sunrise, @"sunset":sunset};
                
                if (!self.placeManagerIsMonitoring) {
                    [GMBLPlaceManager startMonitoring];
                    self.placeManagerIsMonitoring = YES;
                }
            };
        }];
        [task resume];
    }
}


- (void)setUpConfigurations{
    self.lightIsOn = NO;
    self.delayTimerIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    
    if (!self.sunriseSunsetSwitchIsOn && !self.placeManagerIsMonitoring) {
        [GMBLPlaceManager startMonitoring];
        self.placeManagerIsMonitoring = YES;
    }
}


- (void)setTintColors{
    self.whiteTintColor = LIGHT_ON_WHITE_TINT_COLOR;
    if (self.lightIsOn) {
        self.liteTintColor = LIGHT_ON_LITE_TINT_COLOR;
        self.darkTintColor = LIGHT_ON_DARK_TINT_COLOR;
    }else{
        self.liteTintColor = LIGHT_OFF_LITE_TINT_COLOR;
        self.darkTintColor = LIGHT_OFF_DARK_TINT_COLOR;
    }
    if (!self.autoSwitch.on && self.lightSwitch.on) {
        self.autoSwitch.thumbTintColor = self.liteTintColor;
        self.autoSwitch.tintColor = self.darkTintColor;
    }else if (!self.autoSwitch.on && !self.lightSwitch.on){
        self.autoSwitch.thumbTintColor = self.whiteTintColor;
        self.autoSwitch.tintColor = self.liteTintColor;
    }
    if (self.autoSwitch.on & self.lightSwitch.on){
        self.autoSwitch.thumbTintColor = self.whiteTintColor;
        self.autoSwitch.tintColor = self.whiteTintColor;
        self.autoSwitch.onTintColor = LIGHT_OFF_DARK_TINT_COLOR;
    }
}

- (void)setUpVerticalSlider{
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.dimmerSlider.transform = trans;
}


- (NSMutableString *)log{
    if (!_log) {
        _log = [@"" mutableCopy];
    }
    return _log;
}

-(int)redColor{
    if (!_redColor) {
        _redColor = [self.redLabel.text intValue];
    }
    return _redColor;
}

-(int)greenColor{
    if (!_greenColor) {
        _greenColor = [self.greenLabel.text intValue];
    }
    return _greenColor;
}

-(int)blueColor{
    if (!_blueColor) {
        _blueColor = [self.blueLabel.text intValue];
    }
    return _blueColor;
}

-(float)alpha{
    if (!_alpha) {
        _alpha = self.dimmerSlider.value;
    }
    return _alpha;
}


#pragma mark - GMBL PLACE MANAGER DELEGATE METHODS
- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit{
    NSString * visitLog = [LBALogManager createDeveloperLogsWithVisit:visit andEvent:@"Begin"];
    [self updateLogWithString:visitLog];
}


- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit{
    NSString * visitLog = [LBALogManager createDeveloperLogsWithVisit:visit andEvent:@"End"];
    [self updateLogWithString:visitLog];
}


- (void)placeManager:(GMBLPlaceManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting forVisits:(NSArray *)visits{
    if ([self checkIfIsBetweenSunsetAndSunrise] == NO && self.sunriseSunsetSwitchIsOn) {
        return;
    }else{
        NSString * sightingLog = [LBALogManager createDeveloperLogsWithSighting:sighting];
        [self updateLogWithString:sightingLog];
        self.distanceLabel.text = [NSString stringWithFormat:@"%ld", (long)sighting.RSSI];
        if (!self.lightIsOn && !self.delayTimerIsOn) {
            if ((int)labs(sighting.RSSI) < self.entrySliderValue){
                if (sighting.beacon.batteryLevel == GMBLBatteryLevelLow) {
                    self.lowBatteryLabel.hidden = NO;
                }
                [self startDelay];
                self.lightSwitch.on = YES;
                [self changeBackgroundColor];
                [self setTintColors];
            }
        }
        if (self.lightIsOn && !self.delayTimerIsOn && !self.userLightOffTimerIsOn) {
            if ((int)labs(sighting.RSSI) > self.entrySliderValue){
                [self startUserLightOffTimer];
                [self setTintColors];
            }
        }
    }
}

#pragma mark - LBALocation DELEGATE

- (void)setCurrentLocation:(NSDictionary *)currentLocation{
    self.currentLocation = currentLocation;
    [self getSunriseSunset];
}

#pragma mark - ACTIONS

- (IBAction)lightSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        self.lightIsOn = YES;
    }else{
        self.lightIsOn = NO;
        self.autoSwitch.on = NO;
        [GMBLPlaceManager stopMonitoring];
        self.placeManagerIsMonitoring = NO;
    }
    [self setTintColors];
    [self changeBackgroundColor];
}

- (IBAction)autoSwitch:(UISwitch *)sender {
    if (sender.on) {
        if ([CLLocationManager locationServicesEnabled] && !self.placeManagerIsMonitoring) {
            [GMBLPlaceManager startMonitoring];
            self.placeManagerIsMonitoring = YES;
        }
        [self setTintColors];
    }else{
        [GMBLPlaceManager stopMonitoring];
        self.placeManagerIsMonitoring = NO;
        [self setTintColors];
    }
}

- (IBAction)redSliderMoved:(UISlider *)sender {
    int value = sender.value;
    self.redLabel.text = [NSString stringWithFormat:@"%d",value];
    [self updateUserBackgroundColorWithRedColor:value green:0 blue:0 alpha:0];
}

- (IBAction)greenSliderMoved:(UISlider *)sender {
    int value = sender.value;
    self.greenLabel.text = [NSString stringWithFormat:@"%d",value];
    [self updateUserBackgroundColorWithRedColor:0 green:value blue:0 alpha:0];
}

- (IBAction)blueSliderMoved:(UISlider *)sender {
    int value = sender.value;
    self.blueLabel.text = [NSString stringWithFormat:@"%d",value];
    [self updateUserBackgroundColorWithRedColor:0 green:0 blue:value alpha:0];
}

- (IBAction)dimmerValueChanged:(UISlider *)sender {
    [self updateUserBackgroundColorWithRedColor:0 green:0 blue:0 alpha:sender.value];
}

- (IBAction)redMinusButton:(UIButton *)sender {
    [self adjustRedValueWithOperator:@"-"];
}

- (IBAction)redPlusButton:(UIButton *)sender {
    [self adjustRedValueWithOperator:@"+"];
}

- (IBAction)greenMinusButton:(UIButton *)sender {
    [self adjustGreenValueWithOperator:@"-"];
}

- (IBAction)greenPlusButton:(UIButton *)sender {
    [self adjustGreenValueWithOperator:@"+"];
}

- (IBAction)blueMinusButton:(UIButton *)sender {
    [self adjustBlueValueWithOperator:@"-"];
}

- (IBAction)bluePlusButton:(UIButton *)sender {
    [self adjustBlueValueWithOperator:@"+"];
}


#pragma mark - HELPERS

- (void)updateLogWithString:(NSString *)log{
    [self.log insertString:log atIndex:0];
    NSLog(@"%@", log);
}

-(void)updateUserBackgroundColorWithRedColor:(int)red green:(int)green blue:(int)blue alpha:(float)alpha{
    if (self.lightIsOn) {
        if (red > 0) {
            self.redColor = red;
        }
        if (green > 0) {
            self.greenColor = green;
        }
        if (blue > 0) {
            self.blueColor = blue;
        }
        if (alpha > 0.0) {
            self.alpha = alpha;
        }
        self.centerContainerView.backgroundColor = [UIColor colorWithRed:self.redColor / 255.0 green:self.greenColor / 255.0 blue:self.blueColor / 255.0 alpha:self.alpha];
    }
}


- (void)startDelay{
    self.delayTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(lightSwitchOn) userInfo:nil repeats:NO];
    [timer fire];
}


- (void)startUserLightOffTimer{
    self.userLightOffTimerIsOn = YES;
    [self performSelector:@selector(turnOffUserLightOffTimer) withObject:nil afterDelay:(int)self.exitDelaySliderValue];
}


- (void)lightSwitchOn{
    self.lightIsOn = YES;
    self.delayTimerIsOn = NO;
}


- (void)turnOffUserLightOffTimer{
    self.lightIsOn = NO;
    self.lightSwitch.on = NO;
    self.userLightOffTimerIsOn = NO;
    [self changeBackgroundColor];
}

- (void)changeBackgroundColor{
    [UIView animateWithDuration:1.0 animations:^{
        int red = [self.redLabel.text intValue] / 255.0;
        int green = [self.greenLabel.text intValue] / 255.0;
        int blue = [self.blueLabel.text intValue] / 255.0;
        float alpha = self.alpha;
        self.centerContainerView.backgroundColor = self.lightIsOn ? [UIColor colorWithRed:red green:green blue:blue alpha:alpha] : [UIColor colorWithRed:0.098f green:0.098f blue:0.098f alpha:1.0f];
    }];
}

-(void)adjustRedValueWithOperator:(NSString *)operator{
    int redValue = [self.redLabel.text intValue];
    redValue = [operator isEqualToString:@"+"] ? (redValue += 1) : (redValue -= 1);
    if (redValue >= 0 && redValue <= 255) {
        self.redSlider.value = redValue;
        self.redLabel.text = [NSString stringWithFormat:@"%d",redValue];
        [self updateUserBackgroundColorWithRedColor:redValue green:0 blue:0 alpha:0];
    }
}

-(void)adjustGreenValueWithOperator:(NSString *)operator{
    int greenValue = [self.greenLabel.text intValue];
    greenValue = [operator isEqualToString:@"+"] ? (greenValue += 1) : (greenValue -= 1);
    if (greenValue >= 0 && greenValue <= 255) {
        self.greenSlider.value = greenValue;
        self.greenLabel.text = [NSString stringWithFormat:@"%d",greenValue];
        [self updateUserBackgroundColorWithRedColor:0 green:greenValue blue:0 alpha:0];
    }
}

-(void)adjustBlueValueWithOperator:(NSString *)operator{
    int blueValue = [self.blueLabel.text intValue];
    blueValue = [operator isEqualToString:@"+"] ? (blueValue += 1) : (blueValue -= 1);
    if (blueValue >= 0 && blueValue <= 255) {
        self.blueSlider.value = blueValue;
        self.blueLabel.text = [NSString stringWithFormat:@"%d",blueValue];
        [self updateUserBackgroundColorWithRedColor:0 green:0 blue:blueValue alpha:0];
    }
}

-(BOOL)checkIfIsBetweenSunsetAndSunrise{
    int sunset =  [[self.sunriseSunset objectForKey:@"sunset"] intValue];
    int sunrise = [[self.sunriseSunset objectForKey:@"sunrise"] intValue];
    NSTimeInterval now = (int)[[NSDate date] timeIntervalSince1970];
    if (sunset <= now && sunrise >= now) {
        return YES;
    }
    return NO;
}

#pragma mark - ACTIONS

- (IBAction)settingsButtonTapped:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 0:{
            [self.delegate moveCenterPanelToOriginalPosition];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            break;
        }
        case 1: {
            [self.delegate moveCenterPanelToTheRight];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            break;
        }
        default:
            break;
    }
}

- (IBAction)favsButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate moveRightPanelToTheLeft];
    self.settingsButton.enabled = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - LBARightVCDelegate

- (void)handleCloseButtonTap{
    [self.delegate moveRightPanelToOriginalPosition];
}

#pragma mark - LBALeftVCDelegate
- (void)setSunriseSunsetSwitchStatus:(BOOL)status{
    self.sunriseSunsetSwitchIsOn = status;
}

- (void)setEntrySliderValue:(int)entrySliderValue{
    self.entrySliderValue = entrySliderValue;
}

- (void)setExitSliderValue:(int)exitSliderValue{
    self.exitSliderValue = exitSliderValue;
}

- (void)setExitDelaySliderValue:(int)exitDelaySliderValue{
    self.exitDelaySliderValue = exitDelaySliderValue;
}


@end
