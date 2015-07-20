//
//  LBALeftVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBALeftVC.h"
#import "LBAAlert.h"
#import "LBALocationManager.h"
#import "LBASettingsTVCell.h"
#import "LBASunriseTVCell.h"
#import "LBASettingsMinusSign.h"
#import "LBASettingsPlusSign.h"
#import "LBAConstants.h"
#import "LBACoreDataManager.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>

#define ENTRY_TAG 1
#define EXIT_TAG 2
#define EXIT_DELAY_TAG 3

@interface LBALeftVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) LBASunriseTVCell *sunriseCell;
@property (nonatomic) LBASettingsTVCell *entryCell;
@property (nonatomic) LBASettingsTVCell *exitCell;
@property (nonatomic) LBASettingsTVCell *exitDelayCell;
@property (nonatomic) User *user;
@end

@implementation LBALeftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User fetchCurrentUser];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self saveContext];
}

#pragma mark - TABLEVIEW DATASOURCE
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [UITableViewCell new];
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 0:{
            self.sunriseCell = [self setUpCell:cell WithIdentifier:@"SunriseCell" andNibName:@"LBASunriseCell" forTableview:tableView];
            [self.sunriseCell.sunriseSunsetSwitch addTarget:self action:@selector(sunriseSwitch:) forControlEvents:UIControlEventValueChanged];
            
            if (self.user.sunriseSunsetMode) {
                self.sunriseCell.sunriseSunsetSwitch.on = YES;
            }else{
                self.sunriseCell.sunriseSunsetSwitch.on = NO;
            }
            
            self.sunriseCell.layoutMargins = UIEdgeInsetsZero;
            return self.sunriseCell;
            break;
        }
        case 1:{
            self.entryCell = [self setUpCell:cell WithIdentifier:@"SettingsCell" andNibName:@"LBASettingsCell" forTableview:tableView];
            self.entryCell.titleLabel.text = @"Entry Threshold";
            self.entryCell.thresholdSlider.minimumValue = 20;
            self.entryCell.thresholdSlider.maximumValue = 98;
            
            [self setUpSlider:self.entryCell.thresholdSlider withTag:ENTRY_TAG];
            
            self.entryCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)self.entryCell.thresholdSlider.value];
            
            [self setUpOperatorButtonsWithMinusButton:self.entryCell.thresholdMinusButton andPlusButton:self.entryCell.thresholdPlusButton withTag:ENTRY_TAG];
            
            self.entryCell.layoutMargins = UIEdgeInsetsZero;
            
            return self.entryCell;
            break;
        }
        case 2:{
            self.exitCell = [self setUpCell:self.exitCell WithIdentifier:@"SettingsCell" andNibName:@"LBASettingsCell" forTableview:tableView];
            self.exitCell.titleLabel.text = @"Exit Threshold";
            self.exitCell.thresholdSlider.minimumValue = 21;
            self.exitCell.thresholdSlider.maximumValue = 99;
            
            [self setUpSlider:self.exitCell.thresholdSlider withTag:EXIT_TAG];
            
            self.exitCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)self.exitCell.thresholdSlider.value];
            
            [self setUpOperatorButtonsWithMinusButton:self.exitCell.thresholdMinusButton andPlusButton:self.exitCell.thresholdPlusButton withTag:EXIT_TAG];
            
            self.exitCell.layoutMargins = UIEdgeInsetsZero;
            
            return self.exitCell;
            break;
        }
        case 3:{
            self.exitDelayCell = [self setUpCell:self.exitDelayCell WithIdentifier:@"SettingsCell" andNibName:@"LBASettingsCell" forTableview:tableView];
            self.exitDelayCell.titleLabel.text = @"Exit Delay";
            self.exitDelayCell.thresholdSlider.minimumValue = 0;
            self.exitDelayCell.thresholdSlider.maximumValue = 300;
            
            [self setUpSlider:self.exitDelayCell.thresholdSlider withTag:EXIT_DELAY_TAG];

            self.exitDelayCell.thresholdValue.text = [NSString stringWithFormat:@"%is", (int)self.exitDelayCell.thresholdSlider.value];
            
            [self setUpOperatorButtonsWithMinusButton:self.exitDelayCell.thresholdMinusButton andPlusButton:self.exitDelayCell.thresholdPlusButton withTag:EXIT_DELAY_TAG];
            
            self.exitDelayCell.layoutMargins = UIEdgeInsetsZero;
            
            return self.exitDelayCell;
            break;
        }
        default:
            break;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return footer;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - ACTIONS

- (IBAction)sunriseSwitch:(UISwitch *)sender{
    if (sender.on) {
        if ([CLLocationManager locationServicesEnabled]) {
            [[LBALocationManager sharedManager] startUpdatingLocation];
            self.user.sunriseSunsetMode = [NSNumber numberWithBool:YES];
        }else{
            self.user.sunriseSunsetMode = [NSNumber numberWithBool:NO];
            [[LBAAlert sharedAlert] withTitle:@"Location Services Disabled" message:@"Please turn on location services in order to use this feature."];
        }
    }else{
        self.user.sunriseSunsetMode = [NSNumber numberWithBool:NO];
    }
}


- (IBAction)sliderMoved:(UISlider *)sender{
    switch (sender.tag) {
        case 1:{
            if (sender.value >= self.exitCell.thresholdSlider.value) {
                self.exitCell.thresholdSlider.value = sender.value + 1;
                self.exitCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)self.exitCell.thresholdSlider.value];
                self.user.lightOffThreshold = [NSNumber numberWithFloat:self.exitCell.thresholdSlider.value];
                [self.delegate updateEntrySliderValue:self.exitCell.thresholdSlider.value];
            }
            self.entryCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)sender.value];
            self.user.lightOnThreshold = [NSNumber numberWithFloat:sender.value];
            [self.delegate updateEntrySliderValue:self.entryCell.thresholdSlider.value];
            break;
        }
        case 2:{
            if (sender.value <= self.entryCell.thresholdSlider.value) {
                self.entryCell.thresholdSlider.value = sender.value - 1;
                self.entryCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)self.entryCell.thresholdSlider.value];
                self.user.lightOnThreshold = [NSNumber numberWithFloat:self.entryCell.thresholdSlider.value];
                [self.delegate updateExitSliderValue:self.entryCell.thresholdSlider.value];
            }
            self.exitCell.thresholdValue.text = [NSString stringWithFormat:@"-%i", (int)sender.value];
            self.user.lightOffThreshold = [NSNumber numberWithFloat:sender.value];
            [self.delegate updateExitSliderValue:self.exitCell.thresholdSlider.value];
            break;
        }
        case 3:{
            self.exitDelayCell.thresholdValue.text = [NSString stringWithFormat:@"%is", (int)sender.value];
            self.user.lightOffDelay = [NSNumber numberWithFloat:sender.value];
            [self.delegate updateExitDelaySliderValue:self.exitDelayCell.thresholdSlider.value];
        }
        default:
            break;
    }
}

-(IBAction)operatorTapped:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{
            int thresholdValue = abs([self.entryCell.thresholdValue.text intValue]);
            NSString *myClass = NSStringFromClass([[sender superview] class]);
            thresholdValue = [myClass isEqualToString:@"LBASettingsPlusSign"] ? (thresholdValue + 1) : (thresholdValue - 1);
            if (thresholdValue >= 20 && thresholdValue <= 98) {
                self.entryCell.thresholdSlider.value = thresholdValue;
                self.entryCell.thresholdValue.text = [NSString stringWithFormat:@"-%d",thresholdValue];
                self.user.lightOnThreshold = [NSNumber numberWithFloat:self.entryCell.thresholdSlider.value];
                [self.delegate updateEntrySliderValue:self.entryCell.thresholdSlider.value];
                if ([myClass isEqualToString:@"LBASettingsPlusSign"] && thresholdValue == (int)self.exitCell.thresholdSlider.value) {
                    self.exitCell.thresholdSlider.value += 1;
                    self.user.lightOffThreshold = [NSNumber numberWithFloat:self.exitCell.thresholdSlider.value];
                    self.exitCell.thresholdValue.text = [NSString stringWithFormat:@"-%d",(int)self.exitCell.thresholdSlider.value];
                }
            }
        }
            break;
        case 2:{
            int thresholdValue = abs([self.exitCell.thresholdValue.text intValue]);
            NSString *myClass = NSStringFromClass([[sender superview] class]);
            thresholdValue = [myClass isEqualToString:@"LBASettingsPlusSign"] ? (thresholdValue + 1) : (thresholdValue - 1);
            if (thresholdValue >= 21 && thresholdValue <= 99) {
                self.exitCell.thresholdSlider.value = thresholdValue;
                self.exitCell.thresholdValue.text = [NSString stringWithFormat:@"-%d",thresholdValue];
                self.user.lightOffThreshold = [NSNumber numberWithFloat:self.exitCell.thresholdSlider.value];
                [self.delegate updateExitSliderValue:self.exitCell.thresholdSlider.value];
                if ([myClass isEqualToString:@"LBASettingsMinusSign"] && thresholdValue == (int)self.entryCell.thresholdSlider.value) {
                    self.entryCell.thresholdSlider.value -= 1;
                    self.user.lightOnThreshold = [NSNumber numberWithFloat:self.entryCell.thresholdSlider.value];
                    self.entryCell.thresholdValue.text = [NSString stringWithFormat:@"-%d",(int)self.entryCell.thresholdSlider.value];
                }
            }
            
        }
            break;
        case 3:{
            int value = abs([self.exitDelayCell.thresholdValue.text intValue]);
            NSString *myClass = NSStringFromClass([[sender superview] class]);
            value = [myClass isEqualToString:@"LBASettingsPlusSign"] ? (value + 1) : (value - 1);
            if (value >= 0 && value <= 300) {
                self.exitDelayCell.thresholdSlider.value = value;
                self.exitDelayCell.thresholdValue.text = [NSString stringWithFormat:@"%ds",value];
                self.user.lightOffDelay = [NSNumber numberWithFloat:self.exitDelayCell.thresholdSlider.value];
                [self.delegate updateExitDelaySliderValue:self.exitDelayCell.thresholdSlider.value];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - HELPERS
- (id)setUpCell:(id)cell WithIdentifier:(NSString *)identifier andNibName:(NSString *)nibName forTableview:(UITableView *)tableView{
    [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:identifier];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

- (void)setUpSlider:(UISlider *)slider withTag:(int)tag{
    [slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    slider.tag = tag;
    switch (tag) {
        case 1:{
            slider.value = [self.user.lightOnThreshold floatValue];
        }
            break;
        case 2:{
            slider.value = [self.user.lightOffThreshold floatValue];
        }
            break;
        case 3:{
            slider.value = [self.user.lightOffDelay floatValue];
        }
        default:
            break;
    }
}

- (void)setUpOperatorButtonsWithMinusButton:(UIButton *)minusButton andPlusButton:(UIButton *)plusButton withTag:(int)tag{
    [minusButton addTarget:self action:@selector(operatorTapped:) forControlEvents:UIControlEventTouchUpInside];
    [plusButton addTarget:self action:@selector(operatorTapped:) forControlEvents:UIControlEventTouchUpInside];
    minusButton.tag = tag;
    plusButton.tag = tag;
}

#pragma mark - PRIVATE METHODS
- (void)saveContext{
    [[LBACoreDataManager sharedManager]saveContextForEntity:@"User"];
}

@end
