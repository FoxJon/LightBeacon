//
//  LBARectangleView.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/12/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBARectangleView.h"
#import "LBAColorConstants.h"

@implementation LBARectangleView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.6);
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);

    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
}

@end
