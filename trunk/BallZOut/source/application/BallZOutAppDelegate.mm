//
//  BallZOutAppDelegate.mm
//  BallZOut
//
//  Created by alex on 10-09-24.
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#import "cocos2d.h"

#import "BallZOutAppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldScene.h"
#import "RootViewController.h"

@implementation BallZOutAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
   (void)application;
   twlog("launched %@ %@(%@)",
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
   );

	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
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
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To enable Hi-Red mode (iPhone4)
	//	[director setContentScaleFactor:2];
	
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
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];		
}


- (void)applicationWillResignActive:(UIApplication *)application {
   (void)application;
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   (void)application;
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
   (void)application;
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
   (void)application;
	[[CCDirector sharedDirector] stopAnimation];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
   (void)application;
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
   (void)application;
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	

   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
   (void)application;
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Conveniences

BallZOutAppDelegate *TWAppDelegate(void)
{
   return (BallZOutAppDelegate *)[[UIApplication sharedApplication] delegate];
}
