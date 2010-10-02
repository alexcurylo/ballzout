//
//  BZSmallball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZSmallball.h"


enum
{
   kSmallballWidth = 36,
};

NSString *kSmallballName = nil; // @"marble48.png";

@implementation BZSmallball

- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
{
	if ( (self = [super initWithBody:body gameScene:game diameter:kSmallballWidth spriteFrame:kSmallballName]) )
   {
	}
   
	return self;
}

@end
