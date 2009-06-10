//
//  TWC2IntroNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 23/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TWC2IntroNode.h"
#import "SoundEngineManager.h"
#import "chipmunk.h"
#import "TWC2MainMenuNode.h"

/*
#import "GameNode.h"
#import "CreditsNode.h"
*/

//
// Small scene that plays the background music and makes a transition to the Menu scene
//
@implementation TWC2IntroNode

+ (id)scene
{
	Scene *s = [Scene node];
	id node = [TWC2IntroNode node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( ![super init])
		return nil;

	[[SoundEngineManager sharedManager] playTrack:@"TWC2BackgroundMusic.mp3"];
	
	Sprite *back = [Sprite spriteWithFile:@"TWC2IntroBackground.png"];
	back.transformAnchor = cpvzero;
	[self addChild:back];
		
	[self schedule: @selector(timeout:) interval:0.8f];
	return self;
}

-(void) timeout: (ccTime) dt
{
   (void)dt;
   
	[self unschedule:_cmd];
	[[Director sharedDirector] replaceScene: [FadeTRTransition transitionWithDuration:1.0f scene:[TWC2MainMenuNode scene]]];

//	[[Director sharedDirector] replaceScene: [ZoomFlipYTransition transitionWithDuration:1.5 scene:[MainMenuNode scene]]];
//	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0 scene:[IntroNode scene]]];
//	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0 scene:[GameNode scene]]];
//	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0 scene:[CreditsNode scene]]];
	
}

@end
