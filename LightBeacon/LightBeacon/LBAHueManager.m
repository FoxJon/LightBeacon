//
//  LBAHueManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/28/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAHueManager.h"

@interface LBAHueManager()
@property (nonatomic) PHBridgeSendAPI *bridgeSendAPI;
@property (nonatomic) PHLightState *lightState;
@property (nonatomic) BOOL requestTimerIsOn;
@end

@implementation LBAHueManager

+(instancetype)sharedManager{
    static LBAHueManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

-(instancetype)init{
    if((self = [super init])){
        self.bridgeSendAPI = [PHBridgeSendAPI new];
        self.lightState = [PHLightState new];
    }
    return self;
}


-(void)updateLightState:(UIColor *)color andBrightness:(int)brightness forLight:(PHLight *)light {
    if (!self.requestTimerIsOn) {
        self.requestTimerIsOn = YES;
        [self performSelector:@selector(turnOffRequestTimer) withObject:nil afterDelay:0.1];
        CGPoint xy = [PHUtilities calculateXY:color forModel:light.modelNumber];
        [self.lightState setX:[NSNumber numberWithFloat:xy.x]];
        [self.lightState setY:[NSNumber numberWithFloat:xy.y]];
        [self.lightState setBrightness:[NSNumber numberWithFloat:brightness]];
        
        [self.bridgeSendAPI updateLightStateForId:light.identifier withLightState:self.lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
        }];
    }
}


-(void)updateLightState:(BOOL)isOn forLight:(PHLight *)light {
    [self.lightState setOnBool:isOn];
    
    [self.bridgeSendAPI updateLightStateForId:light.identifier withLightState:self.lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            
            NSLog(@"Response: %@",message);
        }
    }];
}


- (void) turnOffRequestTimer {
    self.requestTimerIsOn = NO;
}

@end
