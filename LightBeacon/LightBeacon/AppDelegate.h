//
//  AppDelegate.h
//  LightBeacon
//
//  Created by Jonathan Fox on 6/6/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LBAMainVC.h"
#import <HueSDK_iOS/HueSDK.h>

@protocol AppDelegateDelegate <NSObject>

- (void)handleButtonNotTapped;
- (void)handleAuthenticationSuccess;
- (void)handleAuthenticationFailure;
- (void)showSpinnerViewWithText:(NSString *)text;
- (void)removeSpinnerView;
- (void)showBridgeSelectionTVC;
- (void)handleBridgeConnectionFailure;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic)  LBAMainVC *viewController;
@property (nonatomic) PHHueSDK *phHueSDK;
@property id<AppDelegateDelegate> delegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) searchForLocalBridge;
- (void)enableLocalHeartbeat;
- (void)disableLocalHeartbeat;

@end

