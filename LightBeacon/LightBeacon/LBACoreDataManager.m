//
//  LBACoreDataManager.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/18/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBACoreDataManager.h"

@interface LBACoreDataManager()
@property (nonatomic) AppDelegate *appDelegate;
@end

@implementation LBACoreDataManager

+ (LBACoreDataManager *)sharedManager{
    static LBACoreDataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}


- (void)saveContextForEntity:(NSString *)entityName{
    NSManagedObjectContext *context = [self getContext];
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    [self.appDelegate saveContext];
}

- (void)deleteManagedObject:(id)object{
    NSManagedObjectContext *context = [self getContext];
    NSManagedObject *objectToDelete = object;
    [context deleteObject:object];
}


- (NSMutableArray *)fetchEntityWithName:(NSString *)entityName{
    NSManagedObjectContext *context = [self getContext];
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error]mutableCopy];
    
    return mutableFetchResults;
}

- (NSMutableArray *)fetchEntityWithName:(NSString *)entityName andSortDescriptor:(NSString *)sortDescriptor ascending:(BOOL)isAscending{
    NSManagedObjectContext *context = [self getContext];
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:sortDescriptor ascending:isAscending];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:descriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error]mutableCopy];
    
    return mutableFetchResults;
}


- (id)insertNewManagedObjectWithName:(NSString *)entityName{
    id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self getContext]];
    return object;
}


#pragma mark - HELPERS
- (NSManagedObjectContext *)getContext{
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = self.appDelegate.managedObjectContext;
    return context;
}

@end
