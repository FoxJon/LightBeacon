//
//  Favorite.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/16/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * tag;

@end
