//
//  BZHeroball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

//#import "GameNode.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZHeroball.h"

enum
{
   kHeroballWidth = 48,
};

NSString *kHeroballName = @"marble48.png";

@implementation BZHeroball

@synthesize isHero = isHero_;

// when placed in scene file
- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
{
	if ( (self = [super initWithBody:body gameScene:game diameter:kHeroballWidth spriteFrame:kHeroballName]) )
   {
      // Tell the game, that this instace is the Hero
		[game addHeroball:self];
	}
   
	return self;
}

// when created by game
- (id)initWithPosition:(b2Vec2)position gameScene:(BZLevelScene*)game
{
	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.position = position;
	b2Body *body = [game world]->CreateBody(&bd);

	if ( (self = [super initWithBody:body gameScene:game diameter:kHeroballWidth spriteFrame:kHeroballName]) )
   {
      // Tell the game, that this instace is the Hero
		[game addHeroball:self];
	}
   
	return self;
}

- (void)outsideBounds
{
	[game_ removeHeroball:self];
   if (kGameStatePlaying == game_.gameState)
      [[SimpleAudioEngine sharedEngine] playEffect: @"you_are_hit.wav"];
   
   [super outsideBounds];
}

// see if we need to move back
- (void)update:(ccTime)dt
{
   [super update:dt];
   
   [game_ resetHeroball:self];
}

@end
