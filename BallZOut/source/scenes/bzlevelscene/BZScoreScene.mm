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
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		//background.rotation = -90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
      
      BZSimpleButton *itemContinue = [BZSimpleButton
       simpleButtonAtPosition:ccp(size.width/2, kPositionBottomScreenEdge)
       image:@"button_continue.png"
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
      destinationScene = [BZWonScene scene];
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
