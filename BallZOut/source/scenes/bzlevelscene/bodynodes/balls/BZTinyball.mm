//
//  BZTinyball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZTinyball.h"


enum
{
   kTinyballWidth = 25,
};

NSString *kTinyballName = nil; // @"marble48.png";

@implementation BZTinyball

- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
{
	if ( (self = [super initWithBody:body gameScene:game diameter:kTinyballWidth spriteFrame:kTinyballName]) )
   {
	}
   
	return self;
}

@end
