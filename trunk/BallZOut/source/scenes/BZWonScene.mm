//
//  BZWonScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZWonScene.h"
#import "BZMainScene.h"
#import "BZSimpleButton.h"
#import "SimpleAudioEngine.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZWonScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZWonScene node];
	[s addChild:node];
	return s;
}

-(id) init
{
	if( (self=[super init]))
   {
		
		// Load all the sprites/platforms now
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"scene-won.jpg"];
		//background.rotation = -90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
      
      BZSimpleButton *itemContinue = [BZSimpleButton
        simpleButtonAtPosition:ccp(size.width/2, kPositionBottomScreenEdge)
        imageFrame:@"button_continue.png"
        target:self
        selector:@selector(buttonContinue:)
        ];
      [self addChild:itemContinue z:5];
      [itemContinue startWaving];
      
		//[self schedule:@selector(wait1second:) interval:1];
      [[SimpleAudioEngine sharedEngine] playEffect:@"gamewin.caf"];
	}
	return self;
}

-(void) wait1second:(ccTime)dt
{
   (void)dt;
   
   id destinationScene = [BZMainScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:1.0f scene:destinationScene]];
}

- (void)buttonContinue:(id)sender
{
   (void)sender;
   [self wait1second:0];
}   

@end
