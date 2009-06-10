//
//  TWC2AppDelegate.m
//
//  Copyright Trollwerks Inc 2009. All rights reserved.
//

#import "TWC2AppDelegate.h"

#import "SoundEngineManager.h"
#import "cocos2d.h"
#import "chipmunk.h"
#import "TWC2IntroNode.h"
/*
 #import "LocalScore.h"
*/

@implementation TWC2AppDelegate

@synthesize window;
@synthesize isPlaying;
//@synthesize scores, globalScores, database, isPaused, sendGlobalScores;

#pragma mark -
#pragma mark Life cycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   (void)application;
   
   twlog("launched %@ %@(%@)",
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
   );
   
   isPlaying = NO;
/*
 // "global variables" initialization
 sendGlobalScores = YES;
 isPaused = NO;
 
 // DB initialization
 [self createEditableCopyOfDatabaseIfNeeded];
 [self initializeDatabase];
 [self initGlobalScores];
 */

   // music initialization
   [SoundEngineManager setFrequency:44100];
   [self preloadSounds];

 /*
 #ifdef EXPERIMENTAL_PHYSICS_STEP
 // TIP: The iPhone won't refresh the screen faster than 1/60 seconds
 // but if you specify a smaller value, like 1/240 seconds, then if won't wait
 // for the vsync.
 //
 // It's like a "pseudo" fast director with this differences:
 //  * It works well with attach / detach from an UIView
 //  * Integration with UIView works OK
 //  * sometimes it can be faster than the FastDirector and sometimes it can be slower
 //
 // Don't put a very small number like 1/6000 because you will start losing events
 
 #ifndef __IPHONE_3_0
 [[Director sharedDirector] setAnimationInterval:1/240.0];
 #else // SDK 3.0
 // TIP: Since v0.7.3 the FastDirector works a little better with UI Kit componenet.
 // It still has some issues, but it works better in SDK 3.0 than in SDK 2.2
 [Director useFastDirector];
 #endif __IPHONE_3_0
 
 #else  // exprimental physics
 [[Director sharedDirector] setAnimationInterval:1/55.0];
 #endif EXPERIMENTAL_PHYSICS_STEP
 */
   [[Director sharedDirector] setAnimationInterval:1/55.0];

   // Init the window
   window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

   // create an openGL view inside a window
   [[Director sharedDirector] attachInView:window];	

   [window makeKeyAndVisible];	

   // cocos2d will inherit these values
   [window setUserInteractionEnabled:YES];	
   [window setMultipleTouchEnabled:NO];

   // cocos2d initialization
   //	[[Director sharedDirector] setPixelFormat:kRGBA8];

   [[Director sharedDirector] setLandscape: YES];

   // turn this feature On when testing the speed
   //	[[Director sharedDirector] setDisplayFPS:YES];

   // TIP:
   // Sapus Tongue uses almost all of the images with gradients.
   // The look good in 32 bit mode (RGBA8888) but the consume lot of memory.
   // If your game doesn't such precision in the images, use 16-bit textures.
   // RGBA4444 or RGB5_A1
   [Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];

   // TIP:
   // to prevent a blink from the "Default.png", the following code shall be added
   // before running an scene.
   // This makes an smooth transition between the "loading" screen and the
   // next Scene
   Sprite *sprite = [[Sprite spriteWithFile:@"Default.png"] retain];
   sprite.transformAnchor = cpvzero;
   [sprite draw];	
   [[[Director sharedDirector] openGLView] swapBuffers];
   [sprite release];


   // 
   // TIP:
   //  Instead of using the GL_SRC_ALPHA (the default one in cocos2d)
   //  I'm using GL_ONE to show the angle & speed arrows not so transparent
   //  Depending on the game, it might be a good idea to use this blend func.
   //  WARNING: If you use the opacity property won't work as expected
   //
   // in cococs2d v0.8 this won't be needed anymore.
   //	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    // Run the intro Scene
    [[Director sharedDirector] runWithScene: [TWC2IntroNode scene]];	
}

// Called when an SMS, call or 'turn off' event is executed
// So pause the music & code. This will save energy consuption
- (void)applicationWillResignActive:(UIApplication *)application
{
   (void)application;
/*
	[[Director sharedDirector] pause];
*/
	[[SoundEngineManager sharedManager] pause];
}

//
// Resume everything
// If we were playing the show the "Resume dialog".
//
- (void)applicationDidBecomeActive:(UIApplication *)application
{
   (void)application;

/*
 if( !isPaused && isPlaying) {
		// Dialog
		UIAlertView *pauseAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Game Paused"
                                 message:nil
                                 delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"Resume",nil];	
		[pauseAlert show];
		[pauseAlert release];
	} else
		[[Director sharedDirector] resume];
*/
	[[SoundEngineManager sharedManager] resume];
}

// next delta time will be zero
- (void)applicationSignificantTimeChange:(UIApplication *)application
{
   (void)application;

	/*
    [[Director sharedDirector] setNextDeltaTimeZero:YES];
*/
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
{
   (void)application;
   twlog("applicationDidReceiveMemoryWarning!! -- calling removeAllTextures");
/*
 
	[[TextureMgr sharedTextureMgr] removeAllTextures];
*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   (void)application;
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
	[window release];
   window = nil;
   
/*
 [scores release];
 [globalScores release];
*/
   
	[super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   (void)alertView;
   (void)buttonIndex;
/*   
   [[Director sharedDirector] resume];
*/
}

#pragma mark -
#pragma mark Application support

// prevent delay when the sound is played for the 1st time
- (void)preloadSounds
{
   [[SoundEngineManager sharedManager] addSound:@"TWC2ButtonTap.caf"];
   
   twlog("preloadSounds should preload more?");
   /*
   [[SoundEngineManager sharedManager] addSound:@"snd-select-monus.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-select-sapus.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-select-sapus-burp.caf"];
   
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-boing.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-yupi.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-yaaa.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-mama.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-geronimo.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-argh.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-waka.caf"];
   [[SoundEngineManager sharedManager] addSound:@"snd-gameplay-ohno.caf"];
    */
}

/* 
 #pragma mark GlobalScores
 -(void) initGlobalScores {
 self.globalScores = [[NSMutableArray alloc] initWithCapacity:50];
 }
 
 #pragma mark Database Stuff
 // Creates a writable copy of the bundled default database in the application Documents directory.
 - (void)createEditableCopyOfDatabaseIfNeeded {
 // First, test for existence.
 BOOL success;
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSError *error;
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
 success = [fileManager fileExistsAtPath:writableDBPath];
 if (success) return;
 
 // The writable database does not exist, so copy the default to the appropriate location.
 NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scores.sqlite"];
 success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
 if (!success) {
 NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
 }
 }
 
 // Creates the angle & speed column in case they don't exists
 // This can happen when migrating from Sapus Tongue v1.0 to v1.2
 //
 // TIP:
 //   If you are chaning the schema of your game, then you should provide
 //   a migration "tool" (like this function) to update the old schema.
 //   Updates don't remove the old data, it will be reused.
 -(void) updateDBSchema {
 
 sqlite3_stmt	*alter1_stmt = nil;
 sqlite3_stmt	*alter2_stmt = nil;
 sqlite3_stmt	*test_rows_stmt = nil;
 int rc;
 
 char *alter1_sql = "ALTER TABLE scores ADD COLUMN angle INTEGER DEFAULT 0";
 char *alter2_sql = "ALTER TABLE scores ADD COLUMN speed INTEGER DEFAULT 0";	
 
 rc = sqlite3_prepare_v2(database, "SELECT angle,speed FROM scores", -1, &test_rows_stmt, NULL);
 if( rc != SQLITE_OK ) {
 // Query failed... using old schema.
 // So, update schema
 twlog(@"%s", sqlite3_errmsg(database));
 twlog(@"Updated Sapus Tongue schema");
 
 rc = sqlite3_prepare_v2( database, alter1_sql, -1, &alter1_stmt, NULL);
 if( rc != SQLITE_OK)
 NSAssert1(0, @"Error: failed to update scheme message '%s'.", sqlite3_errmsg(database));
 sqlite3_step( alter1_stmt);
 
 rc = sqlite3_prepare_v2( database, alter2_sql, -1, &alter2_stmt, NULL);
 if( rc != SQLITE_OK)
 NSAssert1(0, @"Error: failed to update scheme message '%s'.", sqlite3_errmsg(database));
 sqlite3_step( alter2_stmt);		
 }
 if (alter1_stmt)
 sqlite3_finalize( alter1_stmt );
 if (alter2_stmt)
 sqlite3_finalize( alter2_stmt );
 if (test_rows_stmt)
 sqlite3_finalize( test_rows_stmt );
 }
 
 // Open the database connection and retrieve minimal information for all objects.
 - (void)initializeDatabase {
 NSMutableArray *scoresArray = [[NSMutableArray alloc] init];
 self.scores = scoresArray;
 [scoresArray release];
 // The database is stored in the application bundle. 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString *path = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
 // Open the database. The database was prepared outside the application.
 
 
 if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
 
 [self updateDBSchema];
 
 [self loadScoresFromDB];
 
 } else {
 // Even though the open failed, call close to properly clean up resources.
 sqlite3_close(database);
 NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
 // Additional error handling, as appropriate...
 }
 }
 
 -(void) loadScoresFromDB {
 [scores removeAllObjects];
 
 //
 // Load only the best 50 scores
 //
 const char *sql = "SELECT pk FROM scores ORDER BY score DESC LIMIT 50";
 sqlite3_stmt *statement;
 // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
 // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
 if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
 // We "step" through the results - once for each row.
 while (sqlite3_step(statement) == SQLITE_ROW) {
 // The second parameter indicates the column index into the result set.
 int primaryKey = sqlite3_column_int(statement, 0);
 // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
 // autorelease is slightly more expensive than release. This design choice has nothing to do with
 // actual memory management - at the end of this block of code, all the book objects allocated
 // here will be in memory regardless of whether we use autorelease or release, because they are
 // retained by the books array.
 LocalScore *score = [[LocalScore alloc] initWithPrimaryKey:primaryKey database:database];
 [scores addObject:score];
 [score release];
 }
 // "Finalize" the statement - releases the resources associated with the statement.
 sqlite3_finalize(statement);
 }
 }
 */

@end

#pragma mark -
#pragma mark Conveniences

TWC2AppDelegate *TWAppDelegate(void)
{
   return (TWC2AppDelegate *)[[UIApplication sharedApplication] delegate];
}
