//
//  LBASettingsTVCell.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/4/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBASettingsTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *thresholdValue;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UIButton *thresholdMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *thresholdPlusButton;

@end
