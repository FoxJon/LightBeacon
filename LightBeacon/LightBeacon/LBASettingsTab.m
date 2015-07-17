//
//  LBASettingsTab.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/12/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBASettingsTab.h"

@implementation LBASettingsTab


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.6);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMinY(rect)+0.8);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect)+0.8);
    
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMaxY(rect)-0.8);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-0.8);
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
}


@end
