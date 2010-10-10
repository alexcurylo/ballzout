//
//  BZMainScene.mm
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "BZMainScene.h"
//#import "MenuScene.h"
//#import "HelloWorldScene.h"
//#import "Level2.h"
#import "BZLevelScene.h"
#import "BallZOutAppDelegate.h"
#import "SimpleAudioEngine.h"
#import "BZMenuItem.h"
#import "BZSimpleButton.h"
#import "BZMoreGamesScene.h"
#import "BZOptionsScene.h"
#import "BZInstructionsScene.h"
#import "BZGameCenterFAILScene.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZMainScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZMainScene node];
	[s addChild:node];
	return s;
}

- (id)init
{
	if ( (self = [super init]) )
   {
      // background is splash screen
      
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		//background.rotation = -90; // we're using portrait mode
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background z:-10];

      // load up our buttons
      
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];

      itemPlay_ = [BZSimpleButton
       simpleButtonAtPosition:ccp(size.width/2, 290)
       imageFrame:@"button_playgame.png"
       target:self
       selector:@selector(buttonPlayGame:)
       ];
      [self addChild:itemPlay_ z:5];
      // seems to be only crossfade that makes this jump
      [self waveIfSafe];
     
      BZSimpleButton *itemInstructions = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,200)
         imageFrame:@"button_instructions.png"
         target:self
         selector:@selector(buttonInstructions:)
      ];
      [self addChild:itemInstructions z:4];

      BZSimpleButton *itemOptions = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionRightScreenEdge,145)
         imageFrame:@"button_options.png"
         target:self
         selector:@selector(buttonOptions:)
         ];
      [self addChild:itemOptions z:3];

      BZSimpleButton *itemLeaderboard = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,85)
         imageFrame:@"button_leaderboard.png"
         target:self
         selector:@selector(buttonLeaderboard:)
         ];
      [self addChild:itemLeaderboard z:2];

      BZSimpleButton *itemAchievements = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,30)
         imageFrame:@"button_achievements.png"
         target:self
         selector:@selector(buttonAchievements:)
         ];
      [self addChild:itemAchievements z:1];

      BZSimpleButton *itemMoreGames = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionRightScreenEdge,kPositionBottomScreenEdge)
         imageFrame:@"button_moregames.png"
         target:self
         selector:@selector(buttonMoreGames:)
         ];
      [self addChild:itemMoreGames z:0];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(gameCenterLoginResolved:)
         name:kGameCenterLoginResolvedNotification
         object:nil
      ];
      
      // load resources once it's displayed
		
		[self schedule:@selector(loadSpritesAndSounds:) interval:0.1];
	}
	return self;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)loadSpritesAndSounds:(ccTime)dt
{
   (void)dt;
   
   static BOOL sPreloadedSpritesAndSounds = NO;  
   if (!sPreloadedSpritesAndSounds)
   {
      sPreloadedSpritesAndSounds = YES;
      twlog("loading sprites!");
      
      // Load all the sprites/platforms now
      //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
      //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"obstacles.plist"];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"marbles.plist"];

      // ui
      // startup.caf not preloaded; it's already been played the once-only time by now
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpush.caf"];
      
      // game
      // won't preload big ones where delay is ok: gameover.caf, gamewin.caf, levelwin.caf, loselife.caf
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch.caf"];
      //[[SimpleAudioEngine sharedEngine] preloadEffect:@"ballhit.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"targetpop.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"herosmash.caf"];
      //[[SimpleAudioEngine sharedEngine] preloadEffect:@"pause.caf"];
      
       /*
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"you_are_hit.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"enemy_killed.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"new_life.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup_star.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"teleport.caf"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"you_won.caf"];
       */

      // play startup sound after preload
      
      [[SimpleAudioEngine sharedEngine] playEffect:@"startup.caf"];
   }
   
   [self unschedule:@selector(loadSpritesAndSounds:)];
   //[self schedule:@selector(startWaving:) interval:.5];
   
   //[self waveIfSafe];
}

/*
- (void)onEnterTransitionDidFinish
{
 [super onEnterTransitionDidFinish];

 [self performSelector:@selector(waveIfSafe) withObject:nil afterDelay:.5];
}
*/

- (void)waveIfSafe;
{
   // this seemed to go off wacky behind dialogs sometimes
   //if (!itemPlayWaving && TWDataModel().gameCenterLoginResolved)
   // think we don't need to worry about that if we're not shaking?
   if (!itemPlayWaving)
   {
      itemPlayWaving = YES;
      [itemPlay_ startWaving];
   }
}

- (void)gameCenterLoginResolved:(NSNotification *)note
{
   (void)note;
   [self waveIfSafe];
}

/*
-(void) wait1second:(ccTime)dt
{
   (void)dt;
   
   [TWDataModel() startNewGame];
   
   //id destinationScene = [MenuScene scene];
   //id destinationScene = [HelloWorld scene];
   // id destinationScene = [Level2 scene];
   id destinationScene = [BZLevelScene scene];

	//[[CCDirector sharedDirector] replaceScene:[CCTransitionRadialCW transitionWithDuration:1.0f scene:destinationScene]];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1.0f scene:destinationScene]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}
*/

- (void)buttonPlayGame:(id)sender
{
   (void)sender;
   
   // this crashes here, but not anywhere else???
   // ah ... something to do with continue/newgame menu perhaps
   //[itemPlay_ stopWaving];
   
   if (!TWDataModel().isGameSaved)
   {
      [self buttonNewGame:sender];
   }
   else
   {
      // remove current menu items
      // assume all non-background objects have z at least 0
      NSArray *childArray = self.children.getNSArray;
      for (CCNode* node in childArray)
         if (0 <= node.zOrder)
            [node removeFromParentAndCleanup:YES];
      
      // add new/continue menu
      BZMenuItem *itemContinue = [BZMenuItem
       itemFromNormalSpriteFrameName:@"button_continuegame.png"
       selectedSpriteFrameName:nil
       target:self
       selector:@selector(buttonContinueGame:)
       ];
      [itemContinue startWaving];
      BZMenuItem *itemNew = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_newgame.png"
         selectedSpriteFrameName:nil
         target:self
         selector:@selector(buttonNewGame:)
         ];
      CCMenu *playMenu = [CCMenu menuWithItems:
        itemContinue,
        itemNew,
        (id)nil
        ];
      //[playMenu setPosition:ccp(0,0)];
      [self addChild:playMenu z:100];
      [playMenu alignItemsVertically];
   }
}

- (void)buttonNewGame:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
  
//#warning testing CrashReporter
//   int CRASH = *(int*)0L;
   
   [TWDataModel() startGame];
   
   id destinationScene = [BZLevelScene scene];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:1.0f scene:destinationScene]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeTR transitionWithDuration:0.5f scene:destinationScene]];
}

- (void)buttonContinueGame:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
   
   [TWDataModel() loadGame];
   
   id destinationScene = [BZLevelScene scene];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:1.0f scene:destinationScene]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeTR transitionWithDuration:0.5f scene:destinationScene]];
}

- (void)buttonInstructions:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
   
   id destinationScene = [BZInstructionsScene scene];
	// nope, that uggily shows sprites out of bounds
   //[[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInL transitionWithDuration:1.0f scene:destinationScene]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:0.25f scene:destinationScene]];
}

- (void)buttonOptions:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
   
   id destinationScene = [BZOptionsScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}

- (void)buttonLeaderboard:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
   
   if (TWAppDelegate().showLeaderboard)
      return;
   
   //twlog("buttonLeaderboard gameCenterManager FAIL!");
   id destinationScene = [BZGameCenterFAILScene scene];
   [[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0f scene:destinationScene]];      
}

- (void)buttonAchievements:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
  
   if (TWAppDelegate().showAchievements)
      return;
   
   //twlog("buttonAchievements gameCenterManager FAIL!");
   id destinationScene = [BZGameCenterFAILScene scene];
   [[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0f scene:destinationScene]];
}

- (void)buttonMoreGames:(id)sender
{
   (void)sender;
   //[itemPlay_ stopWaving];
  
   id destinationScene = [BZMoreGamesScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f scene:destinationScene]];
}

@end
