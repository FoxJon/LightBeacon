//
//  LBAFavsTVCell.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/11/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBAFavsTVCellProtocol <NSObject>

-(void)keyboardResigned;

@end

@interface LBAFavsTVCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *favsSwatch;
@property (weak, nonatomic) IBOutlet UITextField *favsTextField;
@property (nonatomic) UIColor *cellSwatchBackgroundColor;
@property id<LBAFavsTVCellProtocol> delegate;

@end
