//
//  BallZOutAppDelegate.h
//
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#import "BZDataModel.h"

//@class RootViewController;

@interface BallZOutAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	//RootViewController	*viewController;
   
   BZDataModel *dataModel;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) BZDataModel *dataModel;

#pragma mark -
#pragma mark Life cycle

+ (void)initialize;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)initSounds;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)cleanup;
- (void)applicationSignificantTimeChange:(UIApplication *)application;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

@end

#pragma mark -
#pragma mark Conveniences

BallZOutAppDelegate *TWAppDelegate(void);
BZDataModel *TWDataModel(void);
BZGame *BZCurrentGame(void);
