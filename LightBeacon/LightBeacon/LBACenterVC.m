//
//  LBACenterVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBACenterVC.h"

@interface LBACenterVC ()

@end

@implementation LBACenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsButtonTapped:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 0:{
            [self.delegate moveCenterPanelToOriginalPosition];
            break;
        }
        case 1: {
            [self.delegate moveCenterPanelToTheRight];
            break;
        }
        default:
            break;
    }
}

@end
