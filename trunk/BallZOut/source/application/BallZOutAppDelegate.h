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

@end

#pragma mark -
#pragma mark Conveniences

BallZOutAppDelegate *TWAppDelegate(void);
BZDataModel *TWDataModel(void);
BZGame *BZCurrentGame(void);
