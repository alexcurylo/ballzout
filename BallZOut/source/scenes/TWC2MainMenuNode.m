//
//  TWC2MainMenuNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

// Main Menu Node
// A simple menu that let's you choose between:
//   * start
//   * instructions
//   * credits
//   * high scores
//   You can turn sound off/on from here

#import "TWC2MainMenuNode.h"
#import "SoundEngineManager.h"
#import "chipmunk.h"
#import "TWC2GradientLayer.h"
#import "TWC2SoundMenuItem.h"
#import "TWC2CreditsNode.h"
#import "TWC2HighScoresNode.h"
#import "TWC2InstructionsNode.h"
#import "TWC2GameNode.h"
//#import "SelectCharNode.h"

//
// Only in Sapus Tongue Lite
//
#ifdef LITE_VERSION
#import "BuyNode.h"
#import "AdMobView.h"
#endif

#ifdef LITE_VERSION
static BOOL firstTime = YES;
#endif

@implementation TWC2MainMenuNode

+(id) scene {

#ifdef LITE_VERSION
	float r = CCRANDOM_0_1();
	
	if( firstTime ) {
		firstTime = NO;
		r = 1.0f;
	}
	
	if( r < 0.4 ) {
		return [BuyNode scene];
	} else {
#endif
		Scene *s = [Scene node];	
		TWC2MainMenuNode *node = [TWC2MainMenuNode node];
		[s addChild:node];
		return s;
#ifdef LITE_VERSION
	}
#endif
}


-(id) init {
	if( ! [super init] )
		return nil;

#ifdef LITE_VERSION
	// AdMob
	inStage = YES;
	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
	[adMobAd retain]; // this will be released when it loads (or fails to load)		
#endif
	
	// back color
	TWC2GradientLayer *g = [TWC2GradientLayer layerWithColor:0];
	[g setBottomColor:0xb3e2e6ff topColor:0x83b2b6ff];
	[g changeHeight:320];
	[g changeWidth:480];
	[self addChild: g z:-10];	

	

	// backgorund
#ifdef LITE_VERSION
	Sprite *background = [Sprite spriteWithFile:@"TWC2MainMenuBackground.png"];
#else
	Sprite *background = [Sprite spriteWithFile:@"TWC2MainMenuBackground.png"];
#endif
	background.transformAnchor = cpvzero;
	[self addChild:background z:-1];

	// Menu Items
	MenuItemImage *item1 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(startCallback:)];
	MenuItemImage *item2 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-instructions-normal.png" selectedImage:@"btn-instructions-selected.png" target:self selector:@selector(instructionsCallback:)];
	MenuItemImage *item3 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" target:self selector:@selector(highScoresCallback:)];
	MenuItemImage *item4 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" target:self selector:@selector(creditsCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, item4, nil];
	[menu alignItemsVertically];
	[self addChild: menu z:2];
	menu.position = cpv(480/2,140);

	// Sound ON/OFF button
	TWC2SoundMenuItem *soundButton = [TWC2SoundMenuItem itemFromNormalImage:@"btn-music-on.png" selectedImage:@"btn-music-pressed.png" target:self selector:@selector(musicCallback:)];
	Animation *sounds = [Animation animationWithName:@"sound" delay:0.1f images:@"btn-music-on.png", @"btn-music-off.png", nil];
	[[soundButton normalImage] addAnimation:sounds];
	
	BOOL m = [[SoundEngineManager sharedManager] muted];
	[[soundButton normalImage] setDisplayFrame:@"sound" index: m ? 1 : 0];

	menu = [Menu menuWithItems:soundButton, nil];
	[self addChild: menu z:2];
	menu.position = cpv(20,300);

	/*
    // Buy Sapus Sources
	TWC2SoundMenuItem *buyButton = [TWC2SoundMenuItem itemFromNormalImage:@"btn-buy-normal.png" selectedImage:@"btn-buy-selected.png" target:self selector:@selector(buyCallback:)];	
	menu = [Menu menuWithItems:buyButton, nil];
	[self addChild: menu z:0];
    */
   
#ifdef LITE_VERSION
	// Avoid collision with AdMob view
//	menu.position = cpv(427,70);
	menu.position = cpv(395,170);
#else
	menu.position = cpv(430,40);
#endif
	
	return self;
}

-(void) dealloc {
#ifdef LITE_VERSION
	[adMobAd release];
#endif

	[super dealloc];
}


#pragma mark Menu callback

-(void) musicCallback: (id) sender {
	BOOL m = [[SoundEngineManager sharedManager] muted];
	if( m )
		[[sender normalImage] setDisplayFrame:@"sound" index:0];
	else
		[[sender normalImage] setDisplayFrame:@"sound" index:1];

	[[SoundEngineManager sharedManager] setMuted: ~m];
}

-(void) startCallback: (id) sender {
   (void)sender;
#ifdef LITE_VERSION
	[self removeAd];
#endif
   //[[Director sharedDirector] replaceScene: [FlipXTransition transitionWithDuration:1.0f scene:[SelectCharNode scene] orientation:kOrientationRightOver]];
   [[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:1.0f scene:[TWC2GameNode scene]]];	
}

-(void) instructionsCallback: (id) sender {
   (void)sender;
#ifdef LITE_VERSION
	[self removeAd];
#endif	
	[[Director sharedDirector] replaceScene: [ShrinkGrowTransition transitionWithDuration:1.0f scene:[TWC2InstructionsNode scene]]];
}

-(void) highScoresCallback: (id) sender {
   (void)sender;
#ifdef LITE_VERSION
	[self removeAd];
#endif	
	[[Director sharedDirector] replaceScene: [SplitRowsTransition transitionWithDuration:1.0f scene:[TWC2HighScoresNode sceneWithPlayAgain:NO]]];
}

-(void) creditsCallback: (id) sender {
   (void)sender;
#ifdef LITE_VERSION
	[self removeAd];
#endif	
	[[Director sharedDirector] replaceScene: [TurnOffTilesTransition transitionWithDuration:1.0f scene:[TWC2CreditsNode scene] ]];
}

-(void) buyCallback: (id) sender {
   (void)sender;
	// Launches Safari and opens the requested web page
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sapusmedia.com/sources.html"]];
}

#ifdef LITE_VERSION
-(void) removeAd {
	[adMobAd removeFromSuperview];
	inStage = NO;	
}
#endif

#pragma mark -
#pragma mark AdMobDelegate methods

#ifdef LITE_VERSION
- (NSString *)publisherId {
	return @"a14920333ec4f90"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)adTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (BOOL) useTestAd {
	return NO;
}

- (BOOL)mayAskForLocation {
	return NO; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	CCLOG(@"AdMob: Did receive ad");
	if( inStage ) {
		adMobAd.frame = CGRectMake(-138, -55, 48, 320); // put the ad at the bottom of the screen
		adMobAd.transform = CGAffineTransformMakeRotation((float)M_PI / 2.0f); // 180 degrees
		[[[Director sharedDirector] openGLView] addSubview:adMobAd];
		[self schedule:@selector(refreshAd:) interval:AD_REFRESH_PERIOD];	
	}
}

// Request a new ad. If a new ad is successfully loaded, it will be animated into location.
- (void)refreshAd:(NSTimer *)timer {
	[adMobAd requestFreshAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	CCLOG(@"AdMob: Did fail to receive ad");
	[adMobAd release];
	adMobAd = nil;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
}
#endif // LITE_VERSION

@end
