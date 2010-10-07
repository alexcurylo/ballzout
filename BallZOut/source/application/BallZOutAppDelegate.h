//
//  BallZOutAppDelegate.h
//
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#import "BZDataModel.h"
#import "CrashReportSender.h"

@class BZRootViewController;

extern NSString *kBZPrefPlaySound; // = @"BZPlaySound";
extern NSString *kBZPrefUseGameCenter; // = @"BZUseGameCenter";
extern NSString *kBZPrefCurrentGame; // = @"BZCurrentGame";
//extern NSString *kBZPrefPendingGCUpdates; // = @"BZPendingGCUpdates";

@interface BallZOutAppDelegate : NSObject <
   UIApplicationDelegate,
   GKLeaderboardViewControllerDelegate,
   GKAchievementViewControllerDelegate,
   CrashReportSenderDelegate
>
{
	UIWindow *window;
	BZRootViewController	*viewController;
 
   NSURL *iTunesURL;

   BZDataModel *dataModel;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, copy) NSURL *iTunesURL;
@property (nonatomic, retain) BZDataModel *dataModel;

#pragma mark -
#pragma mark Life cycle

+ (void)initialize;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
//- (void)initSounds;
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

- (void)launchStoreLink:(NSString *)link;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (BOOL)soundOn;
- (void)toggleSound;

- (BOOL)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)lvController;
- (BOOL)showAchievements;
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)achController;

#pragma mark -
#pragma mark CrashReportSenderDelegate

/*
 -(NSString *) crashReportUserID;					// Return the userid the crashreport should contain, empty by default
 -(NSString *) crashReportContact;					// Return the contact value (e.g. email) the crashreport should contain, empty by default
 -(NSString *) crashReportDescription;				// Return the description the crashreport should contain, empty by default 
 */
- (void)connectionOpened;
- (void)connectionClosed;

@end

#pragma mark -
#pragma mark Conveniences

// necessary for .m files to access when implementation is .mm, apparently
#ifdef __cplusplus
extern "C" {
#endif __cplusplus
   
BallZOutAppDelegate *TWAppDelegate(void);
BZDataModel *TWDataModel(void);
BZGame *BZCurrentGame(void);
   
#ifdef __cplusplus
}
#endif __cplusplus
