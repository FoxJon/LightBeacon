//
//  LBAHueManager.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/28/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HueSDK_iOS/HueSDK.h>

@interface LBAHueManager : NSObject

+(instancetype)sharedManager;

-(void)updateLightState:(BOOL)isOn forLight:(PHLight *)light;
-(void)updateLightState:(UIColor *)color andBrightness:(int)brightness forLight:(PHLight *)light;

@end
