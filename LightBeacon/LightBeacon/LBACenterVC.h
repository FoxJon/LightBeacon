//
//  LBACenterVC.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBALeftVC.h"
#import "LBARightVC.h"

@protocol LBACenterVCDelegate <NSObject>

@optional
-(void)moveCenterPanelToTheRight;
-(void)moveRightPanelToTheLeft;
-(void)moveRightPanelToFullLeft;
-(void)moveRightPanelFromFullLeft;

@required
-(void)moveCenterPanelToOriginalPosition;
-(void)moveRightPanelToOriginalPosition;

@end

@interface LBACenterVC : UIViewController <LBARightVCDelegate, LBALeftVCDelegate>

@property id<LBACenterVCDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favsButton;

@end
