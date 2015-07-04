//
//  LBALeftVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBALeftVC.h"
#import "LBADefaultsManager.h"
#import "LBAAlert.h"
#import "LBALocationManager.h"
#import <CoreLocation/CoreLocation.h>

#define LIGHT_ON_THRESHOLD @"Light_On_Threshold"
#define LIGHT_OFF_THRESHOLD @"Light_Off_Threshold"
#define USER_LIGHT_OFF_DELAY @"User_light_Off_Delay"

@interface LBALeftVC ()

@property (nonatomic) NSInteger entryThreshold;
@property (weak, nonatomic) IBOutlet UISlider *entrySlider;
@property (nonatomic) NSInteger exitThreshold;
@property (weak, nonatomic) IBOutlet UISlider *exitSlider;
@property (weak, nonatomic) IBOutlet UISlider *exitDelaySlider;
@property (weak, nonatomic) IBOutlet UISwitch *sunriseSunsetSwitch;
@property (weak, nonatomic) IBOutlet UILabel *entryLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitDelayLabel;

@end

@implementation LBALeftVC

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [super viewDidLoad];
    self.entrySlider.value = fabs([[defaults objectForKey:LIGHT_ON_THRESHOLD] floatValue]);
    self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    self.exitSlider.value = fabs([[defaults objectForKey:LIGHT_OFF_THRESHOLD] floatValue]);
    self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    self.exitDelaySlider.value = [[defaults objectForKey:USER_LIGHT_OFF_DELAY] intValue];
    self.exitDelayLabel.text = [NSString stringWithFormat:@"%is", (int)self.exitDelaySlider.value];
    if ([[defaults objectForKey:@"sunriseSunsetMode"] isEqual: @YES]) {
        self.sunriseSunsetSwitch.on = YES;
        [self.delegate setSunriseSunsetSwitchStatus:YES];
    }else{
        self.sunriseSunsetSwitch.on = NO;
        [self.delegate setSunriseSunsetSwitchStatus:NO];
    }
}

- (IBAction)entrySliderMoved:(UISlider *)sender {
    if (sender.value >= self.exitSlider.value) {
        self.exitSlider.value = self.entrySlider.value + 1;
        self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    }
    self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    [[NSUserDefaults standardUserDefaults] setObject:@(-[NSNumber numberWithFloat:self.entrySlider.value].doubleValue) forKey:LIGHT_ON_THRESHOLD];
}

- (IBAction)exitSliderMoved:(UISlider *)sender {
    if (sender.value <= self.entrySlider.value) {
        self.entrySlider.value = sender.value - 1;
        self.entryLabel.text = [NSString stringWithFormat:@"-%i", (int)self.entrySlider.value];
    }
    self.exitLabel.text = [NSString stringWithFormat:@"-%i", (int)self.exitSlider.value];
    [[NSUserDefaults standardUserDefaults] setObject:@(-[NSNumber numberWithFloat:self.exitSlider.value].doubleValue) forKey:LIGHT_OFF_THRESHOLD];
}

- (IBAction)exitDelaySliderMoved:(id)sender {
    self.exitDelayLabel.text = [NSString stringWithFormat:@"%is", (int)self.exitDelaySlider.value];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.exitDelaySlider.value] forKey:LIGHT_OFF_THRESHOLD];
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

- (IBAction)sunriseSunsetSwitch:(UISwitch *)sender {
    if (sender.on) {
        if ([CLLocationManager locationServicesEnabled]) {
            [[LBALocationManager sharedManager] startUpdatingLocation];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"sunriseSunsetMode"];
        }else{
            self.sunriseSunsetSwitch.on = NO;
            [[LBAAlert sharedAlert] withTitle:@"Location Services Disabled" message:@"Please turn on location services in order to use this feature."];

        }
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"sunriseSunsetMode"];
    }
}

-(void)adjustEntryValueWithOperator:(NSString *)operator{
    int entryValue = abs([self.entryLabel.text intValue]);
    entryValue = [operator isEqualToString:@"+"] ? (entryValue += 1) : (entryValue -= 1);
    if (entryValue >= 20 && entryValue <= 99) {
        self.entrySlider.value = entryValue;
        self.entryLabel.text = [NSString stringWithFormat:@"-%d",entryValue];
        [[NSUserDefaults standardUserDefaults] setObject:@(-[NSNumber numberWithFloat:self.entrySlider.value].doubleValue) forKey:LIGHT_ON_THRESHOLD];
        [self.delegate setEntrySliderValue:self.entrySlider.value];
    }
}

-(void)adjustExitValueWithOperator:(NSString *)operator{
    int exitValue = abs([self.exitLabel.text intValue]);
    exitValue = [operator isEqualToString:@"+"] ? (exitValue += 1) : (exitValue -= 1);
    if (exitValue >= 21 && exitValue <= 100) {
        self.exitSlider.value = exitValue;
        self.exitLabel.text = [NSString stringWithFormat:@"-%d",exitValue];
        [[NSUserDefaults standardUserDefaults] setObject:@(-[NSNumber numberWithFloat:self.exitSlider.value].doubleValue) forKey:LIGHT_OFF_THRESHOLD];
        [self.delegate setExitSliderValue:self.exitSlider.value];
    }
}

-(void)adjustExitDelayValueWithOperator:(NSString *)operator{
    int exitDelayValue = abs([self.exitDelayLabel.text intValue]);
    exitDelayValue = [operator isEqualToString:@"+"] ? (exitDelayValue += 1) : (exitDelayValue -= 1);
    if (exitDelayValue >= 0 && exitDelayValue <= 300) {
        self.exitDelaySlider.value = exitDelayValue;
        self.exitDelayLabel.text = [NSString stringWithFormat:@"%ds",exitDelayValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.exitDelaySlider.value] forKey:USER_LIGHT_OFF_DELAY];
        [self.delegate setExitDelaySliderValue:self.exitDelaySlider.value];
    }
}

@end
