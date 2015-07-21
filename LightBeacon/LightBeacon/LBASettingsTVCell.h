//
//  LBASettingsTVCell.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/4/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBAMinusSign.h"
#import "LBAPlusSign.h"
#import "LBARectangleView.h"

@interface LBASettingsTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *thresholdValue;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UIButton *thresholdMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *thresholdPlusButton;
@property (weak, nonatomic) IBOutlet LBAMinusSign *minusSign;
@property (weak, nonatomic) IBOutlet LBAPlusSign *plusSign;
@property (weak, nonatomic) IBOutlet LBARectangleView *rectangleView;

@end
