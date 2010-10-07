//
//  BZMoreGamesScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZMoreGamesScene.h"
#import "BZMainScene.h"
#import "BZSimpleButton.h"
#import "SimpleAudioEngine.h"
#import "BallZOutAppDelegate.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZMoreGamesScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZMoreGamesScene node];
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
		CCSprite *background = [CCSprite spriteWithFile:@"scene-qmaster.jpg"];
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

      BZSimpleButton *itemTryNow = [BZSimpleButton
        simpleButtonAtPosition:ccp(size.width/2, kPositionBottomScreenEdge)
        imageFrame:@"button_tryfreenow.png"
        target:self
        selector:@selector(buttonTryNow:)
        ];
      [self addChild:itemTryNow z:5];
      
		//[self schedule:@selector(wait1second:) interval:1];
      //[[SimpleAudioEngine sharedEngine] playEffect:@"gamewin.wav"];
	}
	return self;
}

- (void)buttonReturn:(id)sender
{
   (void)sender;
   id destinationScene = [BZMainScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5f scene:destinationScene]];
}   

- (void)buttonTryNow:(id)sender
{
   (void)sender;
   
   NSString *referralLink = @"http://click.linksynergy.com/fs-bin/stat?id=goXYUj1aTb0&amp;offerid=146261&amp;type=3&amp;subid=0&amp;u1=BallzOutQM&amp;tmpid=1826&amp;RD_PARM1=http%253A%252F%252Fphobos.apple.com%252FWebObjects%252FMZStore.woa%252Fwa%252FviewSoftware%253Fid%253D362004815%2526mt%253D8%2526partnerId%253D30";
   [TWAppDelegate() launchStoreLink:referralLink];
}
   
@end
