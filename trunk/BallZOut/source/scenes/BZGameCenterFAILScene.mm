//
//  BZGameCenterFAILScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZGameCenterFAILScene.h"
#import "BZMainScene.h"
#import "BZSimpleButton.h"
#import "SimpleAudioEngine.h"
#import "BallZOutAppDelegate.h"
#import "BZMenuItem.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZGameCenterFAILScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZGameCenterFAILScene node];
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
		CCSprite *background = [CCSprite spriteWithFile:@"scene-gamecenterfail.jpg"];
		//background.rotation = -90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
      
      BZSimpleButton *itemReturn = [BZSimpleButton
         simpleButtonAtPosition:ccp(kPositionLeftScreenEdge, kPositionTopScreenEdge)
         imageFrame:@"button_returnarrow.png"
         target:self
         selector:@selector(buttonReturn:)
         ];
      [self addChild:itemReturn z:5];
      
		//[self schedule:@selector(wait1second:) interval:1];
      //[[SimpleAudioEngine sharedEngine] playEffect:@"gamewin.wav"];
	}
	return self;
}

- (void)buttonReturn:(id)sender
{
   (void)sender;
   id destinationScene = [BZMainScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0f scene:destinationScene]];
}   
   
@end
