//
//  LBARightVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBARightVC.h"

@interface LBARightVC ()

@end

@implementation LBARightVC

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate handleCloseButtonTap];
}

@end
