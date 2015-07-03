//
//  LBAMainVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAMainVC.h"
#import "LBACenterVC.h"
#import "LBARightVC.h"
#import "LBALeftVC.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define RIGHT_PANEL_TAG 3

#define CORNER_RADIUS 4

#define SLIDE_TIMING .25
#define PANEL_WIDTH 90

@interface LBAMainVC () <LBACenterVCDelegate>

@property (nonatomic) LBACenterVC *centerVC;
@property (nonatomic) LBALeftVC *leftVC;
@property (nonatomic) LBARightVC *rightVC;
@property (nonatomic) BOOL showingLeftPanel;
@end

@implementation LBAMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpContainerView];
}

- (void)setUpContainerView{
    self.centerVC = [[LBACenterVC alloc] initWithNibName:@"LBACenterVC" bundle:nil];
    self.centerVC.view.tag = CENTER_TAG;
    self.centerVC.delegate = self;
    self.centerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.centerVC.view];
    [self addChildViewController:self.centerVC];
    [self.centerVC didMoveToParentViewController:self];
}

-(void)moveCenterPanelToTheRight{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:0 animations:^{
        self.centerVC.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.centerVC.settingsButton.tag = 0;
        }
    }];
}

-(void)moveRightPanelToTheLeft{
    
}

-(void)moveCenterPanelToOriginalPosition{
    self.centerVC.settingsButton.tag = 0;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:^{
        self.centerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

-(void)moveRightPanelToOriginalPosition{
    
}

-(UIView *)getLeftView{
    if (self.leftVC == nil) {
        self.leftVC = [[LBALeftVC alloc] initWithNibName:@"LBALeftVC" bundle:nil];
        self.leftVC.view.tag = LEFT_PANEL_TAG;
        
        [self.view addSubview: self.leftVC.view];
//        self.leftVC.delegate = self.centerVC;
        
        [self addChildViewController:self.leftVC];
        [self.leftVC didMoveToParentViewController:self];
        
        self.leftVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    self.showingLeftPanel = YES;
    
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftVC.view;
    return view;
}

-(void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset {
    if (value) {
        [self.centerVC.view.layer setCornerRadius:CORNER_RADIUS];
        [self.centerVC.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.centerVC.view.layer setShadowOpacity:0.8];
        [self.centerVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    } else {
        [self.centerVC.view.layer setCornerRadius:0.0f];
        [self.centerVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

-(void)resetMainView {
    // remove left and right views, and reset variables, if needed
    if (self.leftVC != nil) {
        [self.leftVC.view removeFromSuperview];
        self.leftVC = nil;
        self.centerVC.settingsButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    if (self.rightVC != nil) {
        [self.rightVC.view removeFromSuperview];
        self.rightVC = nil;
//        self.centerVC.rightButton.tag = 1;
//        self.showingRightPanel = NO;
    }
    // remove view shadows
    [self showCenterViewWithShadow:NO withOffset:0];
}

@end
