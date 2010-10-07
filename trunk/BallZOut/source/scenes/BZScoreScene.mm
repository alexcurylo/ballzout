//
//  BZScoreScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZScoreScene.h"
#import "BZLevelScene.h"
#import "BZWonScene.h"
#import "BallZOutAppDelegate.h"
#import "BZSimpleButton.h"
#import "CDXPropertyModifierAction.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZScoreScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZScoreScene node];
	[s addChild:node];
	return s;
}

- (id)init
{
	if( (self=[super init]))
   {
		
		// Load all the sprites/platforms now
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"scene-score.jpg"];
		//background.rotation = -90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
      
      // stats  
      
      const int statsLeft = 174;
      float statsY = 330;
      const float statsLine = 37.9;
      
      NSString *scoreText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelScore];
		CCLabelBMFont *score = [CCLabelBMFont labelWithString:scoreText fntFile:@"bubblegum.fnt"];
		[self addChild:score z:1];
		[score setAnchorPoint:ccp(0,0.5f)];
		[score setPosition:ccp(statsLeft, statsY)];
      statsY -= statsLine;
 
      NSString *accuracyText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelAccuracy];
		CCLabelBMFont *accuracy = [CCLabelBMFont labelWithString:accuracyText fntFile:@"bubblegum.fnt"];
		[self addChild:accuracy z:1];
		[accuracy setAnchorPoint:ccp(0,0.5f)];
		[accuracy setPosition:ccp(statsLeft, statsY)];	
      statsY -= statsLine;
      
      NSString *ballsText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelBalls];
		CCLabelBMFont *balls = [CCLabelBMFont labelWithString:ballsText fntFile:@"bubblegum.fnt"];
		[self addChild:balls z:1];
		[balls setAnchorPoint:ccp(0,0.5f)];
		[balls setPosition:ccp(statsLeft, statsY)];	
      statsY -= statsLine;
     
      NSString *comboText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelMaxMultiplier];
		CCLabelBMFont *combo = [CCLabelBMFont labelWithString:comboText fntFile:@"bubblegum.fnt"];
		[self addChild:combo z:1];
		[combo setAnchorPoint:ccp(0,0.5f)];
		[combo setPosition:ccp(statsLeft, statsY)];	
      statsY -= statsLine;
     
      NSString *bonusText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelBonus];
		CCLabelBMFont *bonus = [CCLabelBMFont labelWithString:bonusText fntFile:@"bubblegum.fnt"];
		[self addChild:bonus z:1];
		[bonus setAnchorPoint:ccp(0,0.5f)];
		[bonus setPosition:ccp(statsLeft, statsY)];	
      statsY -= statsLine;
      
      NSString *totalText = [NSString stringWithFormat:@"%d", BZCurrentGame().levelTotal];
		CCLabelBMFont *total = [CCLabelBMFont labelWithString:totalText fntFile:@"bubblegum.fnt"];
		[self addChild:total z:1];
		[total setAnchorPoint:ccp(0,0.5f)];
		[total setPosition:ccp(statsLeft, statsY)];	
      statsY -= statsLine;
     
      // continue button
      
      BZSimpleButton *itemContinue = [BZSimpleButton
       simpleButtonAtPosition:ccp(size.width/2, kPositionBottomScreenEdge)
       imageFrame:@"button_continue.png"
       target:self
       selector:@selector(buttonContinue:)
       ];
      [self addChild:itemContinue z:5];
      [itemContinue startWaving];
      
		//[self schedule:@selector(wait1second:) interval:1];
      //sfxID_ = [[SimpleAudioEngine sharedEngine] playEffect:@"levelwin.wav"];
      winSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"levelwin.wav"] retain];
      [winSound play];
	}
	return self;
}

- (void)dealloc
{
   twrelease(winSound);
   
   [super dealloc];
}

- (void)wait1second:(ccTime)dt
{
   (void)dt;
   
   id destinationScene = nil;
   if (BZCurrentGame().isGameWon)
   {
      [TWDataModel() endGame:BZCurrentGame()];
      destinationScene = [BZWonScene scene];
   }
   else
      destinationScene = [BZLevelScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeUp transitionWithDuration:1.0f scene:destinationScene]];
   
   //[[SimpleAudioEngine sharedEngine] stopEffect:sfxID_];
	[CDXPropertyModifierAction fadeSoundEffect:2.0f finalVolume:0 curveType:kIT_SCurve shouldStop:YES effect:winSound];
}

- (void)buttonContinue:(id)sender
{
   (void)sender;
   [self wait1second:0];
}   

@end
