//
//  LBACenterVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBACenterVC.h"

@interface LBACenterVC ()

#import "LBALogManager.h"
#import "LBAColorConstants.h"
#import "LBARectangleView.h"
#import "LBASettingsTab.h"
#import "LBAPlusSign.h"
#import "LBAMinusSign.h"
#import <Gimbal/Gimbal.h>
#import <CoreLocation/CoreLocation.h>

#define LIGHT_ON_THRESHOLD @"Light_On_Threshold"
#define LIGHT_OFF_THRESHOLD @"Light_Off_Threshold"
#define USER_LIGHT_OFF_DELAY @"User_light_Off_Delay"

@interface LBACenterVC () <GMBLPlaceManagerDelegate, CLLocationManagerDelegate>
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

// User configurable properties
@property (nonatomic) BOOL userLightOffTimerIsOn;
@property (nonatomic) NSInteger entryThreshold;
@property (weak, nonatomic) IBOutlet UISlider *entrySlider;
@property (nonatomic) NSInteger exitThreshold;
@property (weak, nonatomic) IBOutlet UISlider *exitSlider;
@property (weak, nonatomic) IBOutlet UISlider *exitDelaySlider;
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
@property (weak, nonatomic) IBOutlet UIView *mainViewContainer;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UISwitch *sunriseSunsetSwitch;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;
@property (weak, nonatomic) IBOutlet UILabel *entryLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitDelayLabel;

@end

@implementation LBACenterVC

NSUserDefaults *defaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self setUpConfigurations];
    [self setUpUserDefaults];
    [self setTintColors];
    [self changeBackgroundColor];
    [self setUpVerticalSlider];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    
    [self setUpCoreLocation];
    
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


- (void)setUpCoreLocation{
    if (!self.locationManager) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self showLocationServicesAlert];
    }
}


- (void)getSunriseSunset{
    if (self.sunriseSunsetSwitch.on && [CLLocationManager locationServicesEnabled]) {
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
    
    if (!self.sunriseSunsetSwitch.on && !self.placeManagerIsMonitoring) {
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

- (void)setUpUserDefaults{
    defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    if (![defaults objectForKey:LIGHT_ON_THRESHOLD]){
        NSDictionary *lightDefaults = @{LIGHT_ON_THRESHOLD:@80, LIGHT_OFF_THRESHOLD:@90, USER_LIGHT_OFF_DELAY:@20, @"sunriseSunsetMode": @YES};
        [defaults registerDefaults:lightDefaults];
    };
    
    self.entrySlider.value = fabs([[defaults objectForKey:LIGHT_ON_THRESHOLD] floatValue]);
    self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    self.exitSlider.value = fabs([[defaults objectForKey:LIGHT_OFF_THRESHOLD] floatValue]);
    self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    self.exitDelaySlider.value = [[defaults objectForKey:USER_LIGHT_OFF_DELAY] intValue];
    self.exitDelayLabel.text = [NSString stringWithFormat:@"%is", (int)self.exitDelaySlider.value];
    if ([[defaults objectForKey:@"sunriseSunsetMode"] isEqual: @YES]) {
        self.sunriseSunsetSwitch.on = YES;
    }else{
        self.sunriseSunsetSwitch.on = NO;
    }
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
    if ([self checkIfIsBetweenSunsetAndSunrise] == NO && self.sunriseSunsetSwitch.on) {
        return;
    }else{
        NSString * sightingLog = [LBALogManager createDeveloperLogsWithSighting:sighting];
        [self updateLogWithString:sightingLog];
        self.distanceLabel.text = [NSString stringWithFormat:@"%ld", (long)sighting.RSSI];
        if (!self.lightIsOn && !self.delayTimerIsOn) {
            if ((int)labs(sighting.RSSI) < self.entrySlider.value){
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
            if ((int)labs(sighting.RSSI) > self.entrySlider.value){
                [self startUserLightOffTimer];
                [self setTintColors];
            }
        }
    }
}

#pragma mark - CLLOCATION DELEGATE

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    self.currentLocation = @{@"currentLat":[NSString stringWithFormat:@"%+.6f", location.coordinate.latitude], @"currentLng":[NSString stringWithFormat:@"%+.6f", location.coordinate.longitude]};
    
    [self.locationManager stopUpdatingLocation];
    
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

- (IBAction)entrySliderMoved:(UISlider *)sender {
    if (sender.value >= self.exitSlider.value) {
        self.exitSlider.value = self.entrySlider.value + 1;
        self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    }
    self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    [defaults setObject:@(-[NSNumber numberWithFloat:self.entrySlider.value].doubleValue) forKey:LIGHT_ON_THRESHOLD];
}

- (IBAction)exitSliderMoved:(UISlider *)sender {
    if (sender.value <= self.entrySlider.value) {
        self.entrySlider.value = sender.value - 1;
        self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    }
    self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    [defaults setObject:@(-[NSNumber numberWithFloat:self.exitSlider.value].doubleValue) forKey:LIGHT_OFF_THRESHOLD];
}

- (IBAction)exitDelaySliderMoved:(id)sender {
    self.exitDelayLabel.text = [NSString stringWithFormat:@"%is", (int)self.exitDelaySlider.value];
    [defaults setObject:[NSNumber numberWithFloat:self.exitDelaySlider.value] forKey:LIGHT_OFF_THRESHOLD];
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

- (IBAction)entryMinusButton:(UIButton *)sender {
    [self adjustEntryValueWithOperator:@"-"];
}

- (IBAction)entryPlusButton:(UIButton *)sender {
    [self adjustEntryValueWithOperator:@"+"];
}

- (IBAction)exitMinusButton:(UIButton *)sender {
    [self adjustExitValueWithOperator:@"-"];
}

- (IBAction)exitPlusButton:(UIButton *)sender {
    [self adjustExitValueWithOperator:@"+"];
}

- (IBAction)exitDelayMinusButton:(UIButton *)sender {
    [self adjustExitDelayValueWithOperator:@"-"];
}

- (IBAction)exitDelayPlusButton:(UIButton *)sender {
    [self adjustExitDelayValueWithOperator:@"+"];
}

- (IBAction)settingsButtonTapped:(UIBarButtonItem *)sender {
    if (self.mainViewContainer.frame.origin.x == 0) {
        self.mainViewContainer.translatesAutoresizingMaskIntoConstraints = YES;
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
            self.mainViewContainer.frame = CGRectMake(self.mainViewContainer.frame.size.width - 90, 20, self.mainViewContainer.frame.size.width, self.mainViewContainer.frame.size.height);
            
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:^{
            self.mainViewContainer.frame = CGRectMake(0, 20, self.mainViewContainer.frame.size.width, self.mainViewContainer.frame.size.height);
        } completion:^(BOOL finished) {
            self.mainViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        }];
    }
}

- (IBAction)sunriseSunsetSwitch:(UISwitch *)sender {
    if (sender.on) {
        if ([CLLocationManager locationServicesEnabled]) {
            [self setUpCoreLocation];
            [defaults setObject:@YES forKey:@"sunriseSunsetMode"];
        }else{
            self.sunriseSunsetSwitch.on = NO;
            [self showLocationServicesAlert];
        }
    }else{
        [defaults setObject:@NO forKey:@"sunriseSunsetMode"];
    }
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
        self.mainView.backgroundColor = [UIColor colorWithRed:self.redColor / 255.0 green:self.greenColor / 255.0 blue:self.blueColor / 255.0 alpha:self.alpha];
    }
}


- (void)startDelay{
    self.delayTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(lightSwitchOn) userInfo:nil repeats:NO];
    [timer fire];
}


- (void)startUserLightOffTimer{
    self.userLightOffTimerIsOn = YES;
    [self performSelector:@selector(turnOffUserLightOffTimer) withObject:nil afterDelay:(int)self.exitDelaySlider.value];
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
        self.mainView.backgroundColor = self.lightIsOn ? [UIColor colorWithRed:red green:green blue:blue alpha:alpha] : [UIColor colorWithRed:0.098f green:0.098f blue:0.098f alpha:1.0f];
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

-(void)adjustEntryValueWithOperator:(NSString *)operator{
    int entryValue = abs([self.entryLabel.text intValue]);
    entryValue = [operator isEqualToString:@"+"] ? (entryValue += 1) : (entryValue -= 1);
    if (entryValue >= 20 && entryValue <= 99) {
        self.entrySlider.value = entryValue;
        self.entryLabel.text = [NSString stringWithFormat:@"-%d",entryValue];
        [defaults setObject:@(-[NSNumber numberWithFloat:self.entrySlider.value].doubleValue) forKey:LIGHT_ON_THRESHOLD];
    }
}

-(void)adjustExitValueWithOperator:(NSString *)operator{
    int exitValue = abs([self.exitLabel.text intValue]);
    exitValue = [operator isEqualToString:@"+"] ? (exitValue += 1) : (exitValue -= 1);
    if (exitValue >= 21 && exitValue <= 100) {
        self.exitSlider.value = exitValue;
        self.exitLabel.text = [NSString stringWithFormat:@"-%d",exitValue];
        [defaults setObject:@(-[NSNumber numberWithFloat:self.exitSlider.value].doubleValue) forKey:LIGHT_OFF_THRESHOLD];
    }
}

-(void)adjustExitDelayValueWithOperator:(NSString *)operator{
    int exitDelayValue = abs([self.exitDelayLabel.text intValue]);
    exitDelayValue = [operator isEqualToString:@"+"] ? (exitDelayValue += 1) : (exitDelayValue -= 1);
    if (exitDelayValue >= 0 && exitDelayValue <= 300) {
        self.exitDelaySlider.value = exitDelayValue;
        self.exitDelayLabel.text = [NSString stringWithFormat:@"%ds",exitDelayValue];
        [defaults setObject:[NSNumber numberWithFloat:self.exitDelaySlider.value] forKey:USER_LIGHT_OFF_DELAY];
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

-(void)showLocationServicesAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Please turn on location services in order to use this feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - ACTIONS

- (IBAction)favsButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate moveRightPanelToTheLeft];
    self.settingsButton.enabled = NO;
}

#pragma mark - LBARightVCDelegate

- (void)handleDoneButtonTap{
    [self.delegate moveRightPanelToOriginalPosition];
}

@end
