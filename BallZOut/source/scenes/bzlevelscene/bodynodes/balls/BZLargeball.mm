//
//  BZLargeball.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

//#import "GameNode.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZLargeball.h"


enum
{
   kLargeballWidth = 71,
};

NSString *kLargeballName = nil; // @"marble128.png";

@implementation BZLargeball

//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game
{
	if ( (self = [super initWithBody:body params:params gameScene:game diameter:kLargeballWidth spriteFrame:kLargeballName]) )
   {
	}
   
	return self;
}

@end
