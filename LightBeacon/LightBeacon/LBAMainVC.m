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
@end

@implementation LBAMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpContainerView];
}

- (void)setUpContainerView{
    self.centerVC = [[LBACenterVC alloc] initWithNibName:@"LBACenterVC" bundle:nil];
    self.centerVC.view.backgroundColor = [UIColor blackColor];
    self.centerVC.view.tag = CENTER_TAG;
    self.centerVC.delegate = self;
    self.centerVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.centerVC.view];
    [self addChildViewController:self.centerVC];
    [self.centerVC didMoveToParentViewController:self];
}


#pragma mark - LBACenterVC Delegate

-(void)moveCenterPanelToTheRight{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:0 animations:^{
        self.centerVC.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.centerVC.settingsButton.tag = 0;
        }
    }];
}

-(void)moveRightPanelToTheLeft{
    UIView *childView = [self getRightView];
    [self.view addSubview:childView];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:0 animations:^{
        self.rightVC.view.frame = CGRectMake(75, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.centerVC.favsButton.tag = 0;
        }
    }];
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.rightVC.view.frame = CGRectMake(self.rightVC.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

#pragma mark - HELPERS

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
    
    [self showViewWithShadow:YES andView:self.centerVC.view withOffset:-2];
    
    UIView *view = self.leftVC.view;
    return view;
}

-(UIView *)getRightView{
    if (self.rightVC == nil) {
        self.rightVC = [[LBARightVC alloc] initWithNibName:@"LBARightVC" bundle:nil];
        self.rightVC.view.tag = RIGHT_PANEL_TAG;
        
        [self.view addSubview: self.rightVC.view];
        self.rightVC.delegate = self.centerVC;
        
        [self addChildViewController:self.rightVC];
        [self.rightVC didMoveToParentViewController:self];
        
        self.rightVC.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [self showViewWithShadow:YES andView:self.rightVC.view withOffset:-2];
    
    UIView *view = self.rightVC.view;
    return view;
}

-(void)showViewWithShadow:(BOOL)value andView:(UIView *)view withOffset:(double)offset {
    if (value) {
        [view.layer setCornerRadius:CORNER_RADIUS];
        [view.layer setShadowColor:[UIColor blackColor].CGColor];
        [view.layer setShadowOpacity:0.8];
        [view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [view.layer setCornerRadius:0.0f];
        [view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

-(void)resetMainView {
    // remove left and right views, and reset variables, if needed
    if (self.leftVC != nil) {
        [self.leftVC.view removeFromSuperview];
        self.leftVC = nil;
        self.centerVC.settingsButton.tag = 1;
    }
    if (self.rightVC != nil) {
        [self.rightVC.view removeFromSuperview];
        self.rightVC = nil;
        self.centerVC.favsButton.tag = 1;
    }
    // remove view shadows
    [self showViewWithShadow:NO andView:self.centerVC.view withOffset:0];
    self.centerVC.settingsButton.enabled = YES;
}

@end
