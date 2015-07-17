//
//  LBAFavsTVCell.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/11/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAFavsTVCell.h"

@implementation LBAFavsTVCell

- (void)awakeFromNib {
    self.favsTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.favsTextField resignFirstResponder];
    self.favsTextField.userInteractionEnabled = NO;
    [self.delegate keyboardResigned];
    return YES;
}

@end
