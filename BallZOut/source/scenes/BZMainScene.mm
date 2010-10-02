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
	if( (self = [super init]) )
   {
      // background is splash screen
      
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		//background.rotation = -90; // we're using portrait mode
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background z:-10];

      // load up our buttons
      
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];

      BZSimpleButton *itemPlay = [BZSimpleButton
       simpleButtonAtPosition:ccp(size.width/2, 290)
       image:@"button_playgame.png"
       target:self
       selector:@selector(buttonPlayGame:)
       ];
      [self addChild:itemPlay z:5];
      [itemPlay startWaving];
       
      BZSimpleButton *itemInstructions = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,200)
         image:@"button_instructions.png"
         target:self
         selector:@selector(buttonInstructions:)
      ];
      [self addChild:itemInstructions z:4];

      BZSimpleButton *itemOptions = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionRightScreenEdge,145)
         image:@"button_options.png"
         target:self
         selector:@selector(buttonOptions:)
         ];
      [self addChild:itemOptions z:3];

      BZSimpleButton *itemLeaderboard = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,85)
         image:@"button_leaderboard.png"
         target:self
         selector:@selector(buttonLeaderboard:)
         ];
      [self addChild:itemLeaderboard z:2];

      BZSimpleButton *itemAchievements = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge,30)
         image:@"button_achievements.png"
         target:self
         selector:@selector(buttonAchievements:)
         ];
      [self addChild:itemAchievements z:1];

      BZSimpleButton *itemMoreGames = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionRightScreenEdge,kPositionBottomScreenEdge)
         image:@"button_moregames.png"
         target:self
         selector:@selector(buttonMoreGames:)
         ];
      [self addChild:itemMoreGames z:0];

      /*
      BZMenuItem *itemPlay = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_playgame.png"
         selectedSpriteFrameName:@"button_playgame.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemPlay.position = ccp(size.width/2,280);
      itemPlay.anchorPoint = ccp(0,1);

      CCMenuItem *itemInstructions = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_instructions.png"
         selectedSpriteFrameName:@"button_instructions.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemInstructions.position = ccp(0,250);
      itemInstructions.anchorPoint = ccp(0,1);
      
      CCMenuItem *itemOptions = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_options.png"
         selectedSpriteFrameName:@"button_options.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemOptions.position = ccp(size.width - itemOptions.contentSize.width,190);
      itemOptions.anchorPoint = ccp(0,1);
      
      CCMenuItem *itemLeaderboard = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_leaderboard.png"
         selectedSpriteFrameName:@"button_leaderboard.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemLeaderboard.position = ccp(0,70);
      itemLeaderboard.anchorPoint = ccp(0,1);
      
      CCMenuItem *itemAchievements = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_achievements.png"
         selectedSpriteFrameName:@"button_achievements.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemAchievements.position = ccp(0,10);
      itemAchievements.anchorPoint = ccp(0,1);
      
      CCMenuItem *itemMoreGames = [BZMenuItem
         itemFromNormalSpriteFrameName:@"button_moregames.png"
         selectedSpriteFrameName:@"button_moregames.png"
         target:self
         selector:@selector(buttonPlayGame:)
      ];
 		itemMoreGames.position = ccp(size.width - itemMoreGames.contentSize.width,100);
      itemMoreGames.anchorPoint = ccp(0,1);
		
      CCMenu *menu = [CCMenu menuWithItems:
         itemPlay,
         itemInstructions,
         itemOptions,
         itemLeaderboard,
         itemAchievements,
         itemMoreGames,
         (id)nil
      ];
		[menu setPosition:ccp(0,0)];
      [self addChild:menu z:0];
       */
  
      static BOOL playedStartupEffect = NO;
      if (!playedStartupEffect)
      {
         [[SimpleAudioEngine sharedEngine] playEffect:@"startup.wav"];
         playedStartupEffect = YES;
      }
      
      // load resources once it's displayed
		
		[self schedule:@selector(loadSpritesAndSounds:) interval:0.2];
	}
	return self;
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
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"marbles.plist"];

      // game
      // won't preload big ones where delay is ok: gameover.aif, gamewin.wav, levelwin.wav, loselife.wav
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"ballhit.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"targetpop.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"herosmash.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"pause.wav"];
      
      // ui
      // startup.wav not preloaded; it's already been played the once-only time by now
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonpush.wav"];
      
 
      // need replacements, pop and ?? respectively
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"you_are_hit.wav"];
     /*
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"enemy_killed.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"new_life.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup_star.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"teleport.wav"];
      [[SimpleAudioEngine sharedEngine] preloadEffect:@"you_won.wav"];
       */
   }
   
   [self unschedule:@selector(loadSpritesAndSounds:)];
   //[self schedule:@selector(startWaving:) interval:.5];
}

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

- (void)buttonPlayGame:(id)sender
{
   (void)sender;
   
   [TWDataModel() startNewGame];

   id destinationScene = [BZLevelScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:1.0f scene:destinationScene]];
}

- (void)buttonInstructions:(id)sender
{
   (void)sender;
   
   //id destinationScene = [BZLevelScene scene];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}

- (void)buttonOptions:(id)sender
{
   (void)sender;
   
   id destinationScene = [BZOptionsScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}

- (void)buttonLeaderboard:(id)sender
{
   (void)sender;
   
   //id destinationScene = [BZLevelScene scene];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}

- (void)buttonAchievements:(id)sender
{
   (void)sender;
   
   //id destinationScene = [BZLevelScene scene];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:destinationScene backwards:NO]];
}

- (void)buttonMoreGames:(id)sender
{
   (void)sender;
   
   id destinationScene = [BZMoreGamesScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5f scene:destinationScene]];
}

@end
