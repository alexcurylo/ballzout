//
//  BZTargetball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZTargetball.h"

@implementation BZTargetball

- (id)initWithBody:(b2Body*)body
         gameScene:(BZLevelScene*)game
          diameter:(CGFloat)diameter
       spriteFrame:(NSString *)spriteFrame
{
	if ( (self = [super initWithBody:body gameScene:game diameter:diameter spriteFrame:spriteFrame]) )
   {
      // Tell the game, that this instace is a target
		[game addTargetball:self];
	}
   
	return self;
}

- (void)outsideBounds
{
	//[game_ increaseScore:kScoreBallOut];
	[game_ targetBallOut];
	[game_ removeTargetball:self];

   [super outsideBounds];
}

@end
