//
//  LBARightVC.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBARightVCDelegate <NSObject>

@optional
- (void)handleDoneButtonTap;

@end

@interface LBARightVC : UIViewController

@property id<LBARightVCDelegate> delegate;

@end