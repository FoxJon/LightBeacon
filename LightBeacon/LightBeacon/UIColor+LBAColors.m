//
//  UIColor+LBAColors.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/20/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "UIColor+LBAColors.h"

@implementation UIColor (LBAColors)

+ (UIColor *)lbaLightOnLiteTintColor{
    return [UIColor lightGrayColor];
}

+ (UIColor *)lbaLightOnDarkTintColor{
    return  [UIColor darkGrayColor];
}

+ (UIColor *)lbaLightOnWhiteTintColor{
    return [UIColor colorWithRed:1.000f green:1.000f blue:1.000f alpha:1.0f];
}

+ (UIColor *)lbaLightOffLiteTintColor{
    return [UIColor colorWithRed:0.580f green:0.580f blue:0.580f alpha:1.0f];
}

+ (UIColor *)lbaLightOffDarkTintColor{
    return [UIColor colorWithRed:0.208f green:0.220f blue:0.239f alpha:1.0f];
}

@end
