//
//  BZIntroScene.mm
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "BZIntroScene.h"
//#import "MenuScene.h"
//#import "HelloWorldScene.h"
//#import "Level2.h"
#import "BZLevelScene.h"
#import "BallZOutAppDelegate.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZIntroScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [BZIntroScene node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( (self=[super init])) {
		
		// Load all the sprites/platforms now
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"marbles.plist"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		//background.rotation = -90; // we're using portrait mode
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		
		[self schedule:@selector(wait1second:) interval:1];
	}
	return self;
}


-(void) wait1second:(ccTime)dt
{
   (void)dt;
   
   [TWDataModel() startNewGame];
   
   //id destinationScene = [MenuScene scene];
   //id destinationScene = [HelloWorld scene];
   // id destinationScene = [Level2 scene];
   id destinationScene = [BZLevelScene scene];

	[[CCDirector sharedDirector] replaceScene:[CCTransitionRadialCW transitionWithDuration:1.0f scene:destinationScene]];
}

@end
