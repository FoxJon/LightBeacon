//
//  LBALeftVC.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBALeftVCDelegate <NSObject>

-(void)updateEntrySliderValue:(int)value;
-(void)updateExitSliderValue:(int)value;
-(void)updateExitDelaySliderValue:(int)value;

@end

@interface LBALeftVC : UIViewController

@property id<LBALeftVCDelegate> delegate;

@end
