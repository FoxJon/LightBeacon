//
//  LBACoreDataManager.h
//  LightBeacon
//
//  Created by Jonathan Fox on 7/18/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface LBACoreDataManager : NSObject

+(LBACoreDataManager *)sharedManager;
- (void)saveContextForEntity:(NSString *)entityName;
- (void)deleteManagedObject:(id)object;

- (NSManagedObjectContext *)getContext;
- (id)insertNewManagedObjectWithName:(NSString *)entityName;
- (NSMutableArray *)fetchEntityWithName:(NSString *)entityName;
- (NSMutableArray *)fetchEntityWithName:(NSString *)entityName andSortDescriptor:(NSString *)sortDescriptor ascending:(BOOL)isAscending;

@end
