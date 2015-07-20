//
//  LBADefaultsManager.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBADefaultsManager : NSObject

+ (LBADefaultsManager *)sharedManager;
- (void)setUpDefaults;

@end
