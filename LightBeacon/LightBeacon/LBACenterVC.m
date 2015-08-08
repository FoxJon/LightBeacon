//
//  LBACenterVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBACenterVC.h"
#import "LBALogManager.h"
#import "LBARectangleView.h"
#import "LBAAlert.h"
#import "User.h"
#import "LBADefaultsManager.h"
#import "LBALocationManager.h"
#import "LBACoreDataManager.h"
#import "UIColor+LBAColors.h"
#import "LBAHueManager.h"
#import <Gimbal/Gimbal.h>
#import <CoreLocation/CoreLocation.h>
#import <HueSDK_iOS/HueSDK.h>

@interface LBACenterVC () <GMBLPlaceManagerDelegate, LBALocationManagerDelegate>
@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) NSMutableString *log;
@property (nonatomic) PHBridgeResourcesCache *cache;
@property (nonatomic) PHLight *light;

@property (nonatomic) BOOL lightIsOn;
@property (nonatomic) BOOL delayTimerIsOn;
@property (nonatomic) BOOL placeManagerIsMonitoring;
@property (nonatomic) BOOL sunriseSunsetSwitchIsOn;
@property (nonatomic) UIColor *liteTintColor;
@property (nonatomic) UIColor *darkTintColor;
@property (nonatomic) UIColor *whiteTintColor;
@property (nonatomic) NSDictionary *currentLocation;
@property (nonatomic) NSDictionary *sunriseSunset;
@property (weak, nonatomic) IBOutlet UIView *centerContainerView;
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic) User *user;

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
@property (nonatomic) int entrySldrValue;
@property (nonatomic) int exitSldrValue;
@property (nonatomic) int exitDelaySldrValue;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;

@end

@implementation LBACenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseButtonTap)];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer.enabled = NO;

    [[LBADefaultsManager sharedManager] setUpDefaults];
    self.user = [User fetchCurrentUser];
    [self setUpUserConfigurations];
    [self setTintColors];
    [self changeBackgroundColor];
    [self setUpVerticalSlider];
    [LBALocationManager sharedManager].delegate = self;
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    self.light = [self.cache.lights objectForKey:@"3"];
    
    if (self.autoSwitch) {
        [GMBLPlaceManager startMonitoring];
        self.placeManagerIsMonitoring = YES;
    }
    
    self.favsButton.title = @"\u2661";
    [self.favsButton setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:24.0],NSForegroundColorAttributeName: [UIColor darkGrayColor]} forState:UIControlStateNormal];
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
    self.settingsButton.tintColor = self.liteTintColor;
    self.favsButton.tintColor = [UIColor darkGrayColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self changeBackgroundColor];
}

-(void)dealloc{
    [self saveContext];
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
                
                NSDate * today = [NSDate date];
                NSCalendar * cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
                NSDateComponents * comps = [cal components:NSHourCalendarUnit fromDate:today];
                
                NSNumber *sunset;
                NSNumber *sunrise;
                
                if ( [comps hour]>0 && [comps hour] < 12 ){
                    NSNumber *twenty4Hrs = [NSNumber numberWithInt:60*60*24];
                    sunset = @([weatherDictionary[@"daily"][@"data"][0][@"sunsetTime"] integerValue] - [twenty4Hrs integerValue]);
                    sunrise = weatherDictionary[@"daily"][@"data"][0][@"sunriseTime"];
                }else{
                    sunset = weatherDictionary[@"daily"][@"data"][0][@"sunsetTime"];
                    sunrise = weatherDictionary[@"daily"][@"data"][1][@"sunriseTime"];
                }
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


- (void)setUpUserConfigurations{
    self.lightSwitch.on = [self.user.lightSwitchOn boolValue];
    self.lightIsOn = self.lightSwitch.on;
    self.autoSwitch.on = [self.user.autoLightOn boolValue];
    self.delayTimerIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    self.sunriseSunsetSwitchIsOn = [self.user.sunriseSunsetMode boolValue];
    self.entrySldrValue = [self.user.lightOnThreshold floatValue];
    self.exitSldrValue = [self.user.lightOffThreshold floatValue];
    self.redColor = [self.user.red floatValue];
    self.redSlider.value = [self.user.red floatValue];
    self.redLabel.text = [NSString stringWithFormat:@"%d", [self.user.red intValue]];
    self.greenColor = [self.user.green floatValue];
    self.greenSlider.value = [self.user.green floatValue];
    self.greenLabel.text = [NSString stringWithFormat:@"%d", [self.user.green intValue]];
    self.blueColor = [self.user.blue floatValue];
    self.blueSlider.value = [self.user.blue floatValue];
    self.blueLabel.text = [NSString stringWithFormat:@"%d", [self.user.blue intValue]];
    self.alpha = [self.user.alpha floatValue];
    self.dimmerSlider.value = [self.user.dimmerValue floatValue];
    
    if (!self.sunriseSunsetSwitchIsOn && !self.placeManagerIsMonitoring) {
        [GMBLPlaceManager startMonitoring];
        self.placeManagerIsMonitoring = YES;
    }
}


- (void)setTintColors{
    self.whiteTintColor = [UIColor lbaLightOnWhiteTintColor];
    if (self.lightIsOn) {
        self.liteTintColor = [UIColor lbaLightOnLiteTintColor];
        self.darkTintColor = [UIColor lbaLightOnDarkTintColor];
    }else{
        self.liteTintColor = [UIColor lbaLightOffLiteTintColor];
        self.darkTintColor = [UIColor lbaLightOffDarkTintColor];
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
        self.autoSwitch.onTintColor = [UIColor lbaLightOffDarkTintColor];
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
    if (self.user.sunriseSunsetMode == [NSNumber numberWithBool:YES] && ![self checkIfIsBetweenSunsetAndSunrise]) {
        return;
    }else{
        NSString * sightingLog = [LBALogManager createDeveloperLogsWithSighting:sighting];
        [self updateLogWithString:sightingLog];
        self.distanceLabel.text = [NSString stringWithFormat:@"%ld", (long)sighting.RSSI];
        if (!self.lightIsOn && !self.delayTimerIsOn) {
            if ((int)labs(sighting.RSSI) < labs(self.entrySldrValue)){
                if (sighting.beacon.batteryLevel == GMBLBatteryLevelLow) {
                    self.lowBatteryLabel.hidden = NO;
                }
                [self startDelay];
                self.lightSwitch.on = YES;
                self.lightIsOn = YES;
                [self changeBackgroundColor];
                [self setTintColors];
                [[LBAHueManager sharedManager] updateLightState:YES forLight:self.light];
            }
        }
        if (self.lightIsOn && !self.delayTimerIsOn && !self.userLightOffTimerIsOn) {
            if ((int)labs(sighting.RSSI) > labs(self.entrySldrValue)){
                [self startUserLightOffTimer];
                [self setTintColors];
            }
        }
    }
}

#pragma mark - ACTIONS

- (IBAction)lightSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        self.lightIsOn = YES;
        self.user.lightSwitchOn = [NSNumber numberWithBool:YES];
        [[LBAHueManager sharedManager] updateLightState:YES forLight:self.light];
    }else{
        self.lightIsOn = NO;
        [[LBAHueManager sharedManager] updateLightState:NO forLight:self.light];
        self.autoSwitch.on = NO;
        [GMBLPlaceManager stopMonitoring];
        self.placeManagerIsMonitoring = NO;
        self.user.lightSwitchOn = [NSNumber numberWithBool:NO];
        self.user.autoLightOn = [NSNumber numberWithBool:NO];
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
        self.user.autoLightOn = [NSNumber numberWithBool:YES];
    }else{
        [GMBLPlaceManager stopMonitoring];
        self.placeManagerIsMonitoring = NO;
        [self setTintColors];
        self.user.autoLightOn = [NSNumber numberWithBool:NO];
    }
}

- (IBAction)redSliderMoved:(UISlider *)sender {
    self.redLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    [self updateUserBackgroundColorWithRedColor:sender.value green:0 blue:0 alpha:0];
    self.user.red = [NSNumber numberWithFloat:sender.value];
}

- (IBAction)greenSliderMoved:(UISlider *)sender {
    self.greenLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    [self updateUserBackgroundColorWithRedColor:0 green:sender.value blue:0 alpha:0];
    self.user.green = [NSNumber numberWithFloat:sender.value];
}

- (IBAction)blueSliderMoved:(UISlider *)sender {
    self.blueLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    [self updateUserBackgroundColorWithRedColor:0 green:0 blue:sender.value alpha:0];
    self.user.blue = [NSNumber numberWithFloat:sender.value];
}

- (IBAction)dimmerValueChanged:(UISlider *)sender {
    [self updateUserBackgroundColorWithRedColor:0 green:0 blue:0 alpha:sender.value];
    self.user.alpha = [NSNumber numberWithFloat:sender.value];
    self.user.dimmerValue = [NSNumber numberWithFloat:sender.value];
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

- (IBAction)settingsButtonTapped:(UIButton *)sender {
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
    [self saveContext];
    [self.delegate moveRightPanelToTheLeft];
    self.gestureRecognizer.enabled = YES;
    self.settingsButton.enabled = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
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
        
        int brightness = 254 * self.alpha;
        [[LBAHueManager sharedManager] updateLightState:[UIColor colorWithRed:self.redColor / 255.0 green:self.greenColor / 255.0 blue:self.blueColor / 255.0 alpha:self.alpha] andBrightness:brightness forLight:self.light];
    }
}


- (void)startDelay{
    self.delayTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(lightSwitchOn) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)startUserLightOffTimer{
    self.userLightOffTimerIsOn = YES;
    [self performSelector:@selector(turnOffUserLightOffTimer) withObject:nil afterDelay:(int)self.exitDelaySldrValue];
}


- (void)lightSwitchOn{
    self.lightIsOn = YES;
    self.delayTimerIsOn = NO;
}


- (void)turnOffUserLightOffTimer{
    self.lightIsOn = NO;
    self.lightSwitch.on = NO;
    [[LBAHueManager sharedManager] updateLightState:NO forLight:self.light];
    self.userLightOffTimerIsOn = NO;
    [self changeBackgroundColor];
}

- (void)changeBackgroundColor{
    [UIView animateWithDuration:1.0 animations:^{
        float red = self.redSlider.value / 255.0;
        float green = self.greenSlider.value / 255.0;
        float blue = self.blueSlider.value / 255.0;
        float alpha = self.alpha;
        self.centerContainerView.backgroundColor = self.lightIsOn ? [UIColor colorWithRed:red green:green blue:blue alpha:alpha] : [UIColor colorWithRed:0.098f green:0.098f blue:0.098f alpha:1.0f];
        if (self.lightIsOn) {
            int brightness = 254 * self.alpha;
            [[LBAHueManager sharedManager] updateLightState:[UIColor colorWithRed:self.redColor / 255.0 green:self.greenColor / 255.0 blue:self.blueColor / 255.0 alpha:self.alpha] andBrightness:brightness forLight:self.light];
        }else{
            [[LBAHueManager sharedManager] updateLightState:NO forLight:self.light];
        }
    }];
}

-(void)adjustRedValueWithOperator:(NSString *)operator{
    int redValue = [self.redLabel.text intValue];
    redValue = [operator isEqualToString:@"+"] ? (redValue += 1) : (redValue -= 1);
    if (redValue >= 0 && redValue <= 255) {
        self.redSlider.value = redValue;
        self.redLabel.text = [NSString stringWithFormat:@"%d",redValue];
        [self updateUserBackgroundColorWithRedColor:redValue green:0 blue:0 alpha:0];
        self.user.red = [NSNumber numberWithFloat:self.redSlider.value];

    }
}

-(void)adjustGreenValueWithOperator:(NSString *)operator{
    int greenValue = [self.greenLabel.text intValue];
    greenValue = [operator isEqualToString:@"+"] ? (greenValue += 1) : (greenValue -= 1);
    if (greenValue >= 0 && greenValue <= 255) {
        self.greenSlider.value = greenValue;
        self.greenLabel.text = [NSString stringWithFormat:@"%d",greenValue];
        [self updateUserBackgroundColorWithRedColor:0 green:greenValue blue:0 alpha:0];
        self.user.green = [NSNumber numberWithFloat:self.greenSlider.value];
    }
}

-(void)adjustBlueValueWithOperator:(NSString *)operator{
    int blueValue = [self.blueLabel.text intValue];
    blueValue = [operator isEqualToString:@"+"] ? (blueValue += 1) : (blueValue -= 1);
    if (blueValue >= 0 && blueValue <= 255) {
        self.blueSlider.value = blueValue;
        self.blueLabel.text = [NSString stringWithFormat:@"%d",blueValue];
        [self updateUserBackgroundColorWithRedColor:0 green:0 blue:blueValue alpha:0];
        self.user.blue = [NSNumber numberWithFloat:self.blueSlider.value];
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

#pragma mark - LBALocation DELEGATE

- (void)updateCurrentLocation:(NSDictionary *)currentLocation{
    self.currentLocation = currentLocation;
    [self getSunriseSunset];
}

#pragma mark - LBARightVCDelegate

- (void)handleCloseButtonTap{
    [self.delegate moveRightPanelToOriginalPosition];
    self.gestureRecognizer.enabled = NO;
}

- (void)handleEditButtonTap{
    [self.delegate moveRightPanelToFullLeft];
}

- (void)handleDoneButtonTap{
    [self.delegate moveRightPanelFromFullLeft];
}

-(void)changeBackgroundColorToColor:(UIColor *)color{
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    
    [UIView animateWithDuration:0.4 animations:^{
        self.centerContainerView.backgroundColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:CGColorGetAlpha(color.CGColor)];
    }];
    int brightness = 254 * CGColorGetAlpha(color.CGColor);
    [[LBAHueManager sharedManager] updateLightState:[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:CGColorGetAlpha(color.CGColor)] andBrightness:brightness forLight:self.light];
    
    self.redLabel.text = [NSString stringWithFormat:@"%d", (int)(components[0] * 255)];
    self.redSlider.value = components[0] * 255;
    self.redColor = self.redSlider.value;
    self.greenLabel.text = [NSString stringWithFormat:@"%d", (int)(components[1] * 255)];
    self.greenSlider.value = components[1] * 255;
    self.greenColor = self.greenSlider.value;
    self.blueLabel.text = [NSString stringWithFormat:@"%d", (int)(components[2] * 255)];
    self.blueSlider.value = components[2] * 255;
    self.blueColor = self.blueSlider.value;
    self.dimmerSlider.value = CGColorGetAlpha(color.CGColor);
    self.alpha = self.dimmerSlider.value;
}

#pragma mark - LBALeftVCDelegate

- (void)updateEntrySliderValue:(int)entrySliderValue{
    self.entrySldrValue = entrySliderValue;
}

- (void)updateExitSliderValue:(int)exitSliderValue{
    self.exitSldrValue = exitSliderValue;
}

- (void)updateExitDelaySliderValue:(int)exitDelaySliderValue{
    self.exitDelaySldrValue = exitDelaySliderValue;
}

#pragma mark - private methods
- (void)saveContext{
    [[LBACoreDataManager sharedManager]saveContextForEntity:@"User"];
}

@end
