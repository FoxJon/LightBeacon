//
//  LBAViewController.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/6/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAViewController.h"
#import "LBALogManager.h"
#import "LBAColorConstants.h"
#import "LBARectangleView.h"
#import "LBASettingsTab.h"
#import "LBAPlusSign.h"
#import "LBAMinusSign.h"
#import <Gimbal/Gimbal.h>

#define LIGHT_ON_THRESHOLD @"Light_On_Threshold"
#define LIGHT_OFF_THRESHOLD @"Light_Off_Threshold"
#define USER_LIGHT_OFF_DELAY @"User_light_Off_Delay"

@interface LBAViewController () <GMBLPlaceManagerDelegate>
@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) NSMutableString *log;

@property (nonatomic) BOOL lightIsOn;
@property (nonatomic) BOOL delayTimerIsOn;
@property (nonatomic) UIColor *liteTintColor;
@property (nonatomic) UIColor *darkTintColor;
@property (nonatomic) UIColor *whiteTintColor;

// User configurable properties
@property (nonatomic) BOOL userLightOffTimerIsOn;
@property (nonatomic) NSInteger userOnThreshold;
@property (nonatomic) NSInteger userOffThreshold;

//UI Elements
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *darkTintColorElements;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lightTintColorElements;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoritesButton;
@property (weak, nonatomic) IBOutlet LBARectangleView *dimBox;
@property (nonatomic) UISlider *dimmerSlider;
//Labels
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end

@implementation LBAViewController

- (void)viewDidLoad {
    self.dimmerSlider = [UISlider new];
    [self.view addSubview:self.dimmerSlider];
    [super viewDidLoad];
    [self setUpConfigurations];
    [self setUpUserDefaults];
    [self setTintColors];
    [self setUpVerticalSlider];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    self.log = [@""mutableCopy];
}


- (void)setUpConfigurations{
    self.lightIsOn = NO;
    self.delayTimerIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    [GMBLPlaceManager startMonitoring];
}


- (void)setTintColors{
    if (self.lightIsOn) {
        self.liteTintColor = LIGHT_ON_LITE_TINT_COLOR;
        self.darkTintColor = LIGHT_ON_DARK_TINT_COLOR;
    }else{
        self.liteTintColor = LIGHT_OFF_LITE_TINT_COLOR;
        self.darkTintColor = LIGHT_OFF_DARK_TINT_COLOR;
    }
    [self changeBackgroundColor];
    [self refreshTintColors];
}


- (void)refreshTintColors{
    for (UILabel *label in self.lightTintColorElements) {
        label.tintColor = self.liteTintColor;
    }
    for (UIView *view in self.darkTintColorElements) {
        view.tintColor = self.darkTintColor;
    }
    self.lightSwitch.onTintColor = self.darkTintColor;
    self.lightSwitch.tintColor = self.liteTintColor;
    self.lightSwitch.thumbTintColor = self.liteTintColor;
    self.settingsButton.tintColor = self.liteTintColor;
    self.favoritesButton.tintColor = self.liteTintColor;
    
    [self setUpSliderTint:self.dimmerSlider];
    [self setUpSliderTint:self.redSlider];
    [self setUpSliderTint:self.greenSlider];
    [self setUpSliderTint:self.blueSlider];
}

- (void)setUpSliderTint:(UISlider *)slider{
    if (!self.lightIsOn) {
        slider.thumbTintColor = self.liteTintColor;
        slider.minimumTrackTintColor = self.liteTintColor;
        slider.maximumTrackTintColor = self.liteTintColor;
    }else{
        slider.thumbTintColor = self.whiteTintColor;
        slider.minimumTrackTintColor = self.liteTintColor;
        slider.maximumTrackTintColor = self.darkTintColor;
        self.lightSwitch.thumbTintColor = self.whiteTintColor;
    }
}

- (void)setUpVerticalSlider{
    self.dimmerSlider.minimumValue = 0;
    self.dimmerSlider.maximumValue = 100;
    [self.dimmerSlider setValue:100];
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.dimmerSlider.transform = trans;
    self.dimmerSlider.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = @{@"dimmerSlider":self.dimmerSlider, @"dimBox":self.dimBox};
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dimmerSlider(37)]" options:0 metrics:nil views:viewsDictionary];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[dimmerSlider(150)]" options:0 metrics:nil views:viewsDictionary];
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dimBox]-70-[dimmerSlider]" options:0 metrics:nil views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[dimmerSlider]-(-10)-|" options:0 metrics:nil views:viewsDictionary];
    
    [self.dimmerSlider addConstraints:constraint_H];
    [self.dimmerSlider addConstraints:constraint_V];
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];

}


- (NSMutableString *)log{
    if (!_log) {
        _log = [@"" mutableCopy];
    }
    return _log;
}


- (void)setUpUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    if (![defaults objectForKey:LIGHT_ON_THRESHOLD]){
        NSDictionary *lightDefaults = @{LIGHT_ON_THRESHOLD:@-80, LIGHT_OFF_THRESHOLD:@-90};
        [defaults registerDefaults:lightDefaults];
    };
    
    self.userOnThreshold = [[defaults objectForKey:LIGHT_ON_THRESHOLD] integerValue];
    self.userOffThreshold = [[defaults objectForKey:LIGHT_OFF_THRESHOLD] integerValue];
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
    NSString * sightingLog = [LBALogManager createDeveloperLogsWithSighting:sighting];
    [self updateLogWithString:sightingLog];
    if (!self.lightIsOn && !self.delayTimerIsOn) {
        if (sighting.RSSI > self.userOnThreshold){
            [self startDelay];
            [self changeBackgroundColor];
        }
    }
    if (self.lightIsOn && !self.delayTimerIsOn && !self.userLightOffTimerIsOn) {
        if (sighting.RSSI < self.userOffThreshold){
            [self startUserLightOffTimer];
        }
    }
}

#pragma mark - ACTIONS

- (IBAction)lightSwitch:(UISwitch *)sender {
    self.lightIsOn = sender.on ? YES : NO;
    [self setTintColors];
}


#pragma mark - HELPERS
- (void)updateLogWithString:(NSString *)log{
    [self.log insertString:log atIndex:0];
    NSLog(@"%@", log);
}


- (void)startDelay{
    self.delayTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(lightSwitchOn) userInfo:nil repeats:NO];
    [timer fire];
}


- (void)startUserLightOffTimer{
    self.userLightOffTimerIsOn = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:20 target:self selector:@selector(turnOffUserLightOffTimer) userInfo:nil repeats:NO];
    [timer fire];
}


- (void)lightSwitchOn{
    self.lightIsOn = YES;
    self.delayTimerIsOn = NO;
}


- (void)turnOffUserLightOffTimer{
    self.lightIsOn = NO;
    self.userLightOffTimerIsOn = NO;
    [self changeBackgroundColor];
}

- (void)changeBackgroundColor{
    [UIView animateWithDuration:1.0 animations:^{
        self.view.backgroundColor = self.lightIsOn ? [UIColor colorWithRed:0.937f green:0.992f blue:0.976f alpha:1.0f] : [UIColor colorWithRed:0.098f green:0.098f blue:0.098f alpha:1.0f];
    }];
}

@end
