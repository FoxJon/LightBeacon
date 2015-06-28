//
//  LBASettingsPlusSign.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/28/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBASettingsPlusSign.h"

@implementation LBASettingsPlusSign

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.6);
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
}

@end
