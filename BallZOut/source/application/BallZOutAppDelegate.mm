//
//  BallZOutAppDelegate.mm
//  BallZOut
//
//  Created by alex on 10-09-24.
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "BallZOutAppDelegate.h"
//#import "GameConfig.h"
#import "BZMainScene.h"
//#import "HelloWorldScene.h"
//#import "RootViewController.h"

@implementation BallZOutAppDelegate

@synthesize window;
@synthesize iTunesURL;
@synthesize dataModel;

#pragma mark -
#pragma mark Life cycle

NSString *kBZPrefPlaySound = @"BZPlaySound";

+ (void)initialize
{
	if ( self == [BallZOutAppDelegate class])
   {
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], kBZPrefPlaySound,
         (id)nil
         ];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   (void)application;
   (void)launchOptions;
   
   twlog("launched %@ %@(%@)",
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
   );
   
   self.dataModel = [[[BZDataModel alloc] init] autorelease];

	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
 
	CCDirector *director = [CCDirector sharedDirector];
	
   // portrait orientation ...alex
	// before creating any layer, set the  mode
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];

	// Init the View Controller
	//viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	//viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	
	// Enable multiple touches, or not
	[glView setMultipleTouchEnabled:YES]; // joystick + jump in SVG levels

	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To enable Hi-Res mode (iPhone4)
	//	[director setContentScaleFactor:2];
	
/* no autorotation ...alex
 //
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
#if GAME_AUTOROTATION == kGameAutorotationNone
   // added because we want it to be portrait not landscape like template ...alex
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
*/
	
	[director setAnimationInterval:1.0/60];
#if DISPLAY_FPS
#warning displaying FPS
	[director setDisplayFPS:YES];
#endif DISPLAY_FPS
	
	// make the OpenGLView a child of the view controller
	//[viewController setView:glView];
   // make the View Controller a child of the main window
	//[window addSubview: viewController.view];
	
   // or, just make the OpenGLView a child of the main window
	[window addSubview:glView];

	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
   // Init sounds ... no, we'll do this in main scene
	//[self initSounds];
   
   BOOL soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBZPrefPlaySound];
   [[SimpleAudioEngine sharedEngine] setEnabled:soundOn];

	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [BZMainScene scene]];
	//[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];		

   // return NO if URL in launchOptions cannot be handled
   return YES;
}

/*
- (void)initSounds
{
}
*/

- (void)applicationWillResignActive:(UIApplication *)application
{
   (void)application;
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   (void)application;
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
   (void)application;
   
   twlog("applicationDidReceiveMemoryWarning! -- calling purgeCachedData");

	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
   (void)application;
	[[CCDirector sharedDirector] stopAnimation];
   
   [self cleanup];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
   (void)application;
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   (void)application;
   
   [self cleanup];
   
   CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	//[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)cleanup
{
   
   // TIP:
	// Save the game state here
   //[self.dataModel save];

   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
   (void)application;
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
   
   twrelease(window);
   twrelease(iTunesURL);
   twrelease(dataModel);

   [super dealloc];
}

#pragma mark -
#pragma mark Application support

- (void)launchStoreLink:(NSString *)referralLink
{
   self.iTunesURL = [NSURL URLWithString:referralLink];
   NSURLRequest *referralRequest = [NSURLRequest requestWithURL:self.iTunesURL];
   NSURLConnection *referralConnection = [[NSURLConnection alloc] initWithRequest:referralRequest delegate:self startImmediately:YES];
   [referralConnection release];
   
}

// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
   (void)connection;
   
   self.iTunesURL = response.URL;
   
   // note that it is correct to use response.URL and not request.URL,
   // because the very last redirected link loses your LinkShare affiliate identification!
   
   //twlog("redirectResponse, self.iTunesURL now response.URL: %@", self.iTunesURL);
   //twlog("should that actually be request.URL? : %@", request.URL);
   
   return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   (void)connection;
   
   //twlog("connectionDidFinishLoading, opening: %@", self.iTunesURL);
   
   [[UIApplication sharedApplication] openURL:self.iTunesURL];
}

- (BOOL)soundOn
{
   BOOL soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBZPrefPlaySound];
   return soundOn;
}

- (void)toggleSound
{
   BOOL soundOn = !self.soundOn;
   [[NSUserDefaults standardUserDefaults] setBool:soundOn forKey:kBZPrefPlaySound];
   [[NSUserDefaults standardUserDefaults] synchronize];
   
   [[SimpleAudioEngine sharedEngine] setEnabled:soundOn];
}

@end

#pragma mark -
#pragma mark Conveniences

BallZOutAppDelegate *TWAppDelegate(void)
{
   return (BallZOutAppDelegate *)[[UIApplication sharedApplication] delegate];
}

BZDataModel *TWDataModel(void)
{
   return ((BallZOutAppDelegate *)[[UIApplication sharedApplication] delegate]).dataModel;
}

BZGame *BZCurrentGame(void)
{
   return ((BallZOutAppDelegate *)[[UIApplication sharedApplication] delegate]).dataModel.currentGame;
}
