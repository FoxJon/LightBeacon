//
//  LBAAlert.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBAAlert : NSObject

+(instancetype)sharedAlert;
-(void)withTitle:(NSString *)title message:(NSString *)aMessage;

@end
