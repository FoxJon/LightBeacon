//
//  AppDelegate.m
//  LightBeacon
//
//  Created by Jonathan Fox on 6/6/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "AppDelegate.h"
#import <Gimbal/Gimbal.h>

@interface AppDelegate ()
@property PHBridgeSearching *phBridgeSearching;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    NSString *GimbalAPIKey = [dictionary objectForKey:@"GimbalAPIKey"];
    [Gimbal setAPIKey:GimbalAPIKey options:nil];
    
    self.phHueSDK = [PHHueSDK new];
    [self.phHueSDK enableLogging:YES];
    [self.phHueSDK startUpSDK];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[LBAMainVC alloc] initWithNibName:@"LBAMainVC" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    [self enableLocalHeartbeat];
    
return YES;
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    [self enableLocalHeartbeat];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
    [self disableLocalHeartbeat];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


#pragma mark - LOCAL PHNotificationManager callbacks
/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // If connection is successful this method will be called every heartbeat interval
    // Update UI to show connected state and cached data
    [self.delegate removeSpinnerView];
    NSLog(@"HEARTBEAT");
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Inform user to resolve connectivity issues or connect to other bridge
    [self.delegate handleBridgeConnectionFailure];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    // We are not authenticated so start the authentication/pushlink process
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection) forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge) forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:) forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the Hue SDK to start the pushlinking process
    [self.phHueSDK startPushlinkAuthentication];
}

#pragma mark - PHNotification PUSHLINK Manager callbacks
- (void)authenticationSuccess {
    [self.delegate handleAuthenticationSuccess];

    // You can now enable a heartbeat to connect to this bridge
    [self enableLocalHeartbeat];
}

/**
 Notification receiver which is called when the pushlinking failed because the time limit was reached
 */
- (void)authenticationFailed {
    // Authentication failed because time limit was reached, inform the user about this and let him try again
    [self.delegate handleAuthenticationFailure];
}


/**
 Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
 */
- (void)noLocalBridge {
    // Authentication failed because the SDK has not been configured yet to connect to a specific bridge adress. This is a coding error, make sure you have called [PHHueSDK setBridgeToUseWithIpAddress:macAddress:] before starting the pushlink process
}

/**
 This method is called when the pushlinking is still ongoing but no button was pressed yet.
 @param notification The notification which contains the pushlinking percentage which has passed.
 */
- (void)buttonNotPressed:(NSNotification *)notification {
    // Fetch percentage of time elapsed from notification
    [self.delegate handleButtonNotTapped];
}


#pragma mark - HUE HELPERS
- (void)enableLocalHeartbeat{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        [self.delegate showSpinnerViewWithText:@"Connecting..."];
        [self.phHueSDK enableLocalConnection];
    }else{
        [self searchForLocalBridge];
    }
}

-(void)disableLocalHeartbeat{
    [self.phHueSDK disableLocalConnection];
    [self.phHueSDK cancelPushLinkAuthentication];
}

- (void) searchForLocalBridge{
    [self.delegate showSpinnerViewWithText:@"Loading..."];

    self.phBridgeSearching = [[PHBridgeSearching alloc]initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.phBridgeSearching startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        [self.delegate removeSpinnerView];
        if (bridgesFound.count > 0) {
            NSLog(@"Bridge Found");
            NSString *bridgeId = [[bridgesFound allKeys]objectAtIndex:0];
            NSString *ipAddress = [bridgesFound objectForKey:bridgeId];
            [self.phHueSDK setBridgeToUseWithId:bridgeId ipAddress:ipAddress];
            [self.phHueSDK enableLocalConnection];
        }else{
            [self.delegate handleBridgeConnectionFailure];
        }
    }];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jonfox.LightBeacon" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LightBeacon" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LightBeacon.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


@end
