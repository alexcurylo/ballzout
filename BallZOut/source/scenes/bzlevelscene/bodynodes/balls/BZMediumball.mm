//
//  BZMediumball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZMediumball.h"


enum
{
   kMediumballWidth = 48,
};

NSString *kMediumballName = nil; // @"marble48.png";

@implementation BZMediumball

//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game
{
	if ( (self = [super initWithBody:body params:params gameScene:game diameter:kMediumballWidth spriteFrame:kMediumballName]) )
   {
	}
   
	return self;
}

@end
