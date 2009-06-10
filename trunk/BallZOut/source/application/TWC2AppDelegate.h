//
//  TWC2AppDelegate.h
//
//  Copyright Trollwerks Inc 2009. All rights reserved.
//

/*
 #import <UIKit/UIKit.h>
 #import <sqlite3.h>
 
 
 // TIP: (See GameNode.m)
 // Use Experimental physics stepper to gain some FPS and have an smoother physics simulation
 #define EXPERIMENTAL_PHYSICS_STEP 1
*/

@interface TWC2AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate>
{
    UIWindow *window;

/*
 NSMutableArray *scores;
 NSMutableArray *globalScores;
 // Opaque reference to the SQLite database.
 sqlite3 *database;
 
 // is paused
 BOOL	isPaused;
 
 // send global scores
 BOOL	sendGlobalScores;
*/

   // game state
   BOOL isPlaying;
}

@property (nonatomic, readonly) IBOutlet UIWindow *window;
@property (readwrite, assign) BOOL isPlaying;
/*
@property (nonatomic, retain) NSMutableArray *scores, *globalScores;
@property (readonly) sqlite3 *database;
@property (readwrite, assign) BOOL isPaused, isPlaying;
@property (readwrite, assign) BOOL sendGlobalScores;
*/

#pragma mark -
#pragma mark Life cycle

- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationSignificantTimeChange:(UIApplication *)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)dealloc;

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

#pragma mark -
#pragma mark Application support

- (void)preloadSounds
;

/* 
 -(void) loadScoresFromDB;

 -(void) createEditableCopyOfDatabaseIfNeeded;
 -(void) initializeDatabase;
 -(void) initGlobalScores;
 */

@end

#pragma mark -
#pragma mark Conveniences

TWC2AppDelegate *TWAppDelegate(void);
