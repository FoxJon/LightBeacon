//
//  LBAMinusSign.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/12/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAMinusSign.h"

@implementation LBAMinusSign


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.6);
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextStrokePath(context);
}

@end
