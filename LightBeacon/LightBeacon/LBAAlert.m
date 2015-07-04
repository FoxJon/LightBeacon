//
//  LBAAlert.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/3/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBAAlert.h"

@interface LBAAlert ()
@property (copy) void (^alertHandler)(NSString *title, NSString *message);
@end

@implementation LBAAlert

+(instancetype)sharedAlert{
    static LBAAlert *sharedAlert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlert = [self new];
    });
    return sharedAlert;
}

-(instancetype)init{
    if((self = [super init])){
        __weak LBAAlert *weakSelf = self;
        _alertHandler = ^(NSString *title, NSString *message){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        };
    }
    return self;
}

-(void)withTitle:(NSString *)title message:(NSString *)aMessage{
    [self withTitle:title format:@"%@", aMessage];
}

-(void)withTitle:(NSString *)title format:(NSString *)format, ...{
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self alertHandler](title, message);
}

@end
