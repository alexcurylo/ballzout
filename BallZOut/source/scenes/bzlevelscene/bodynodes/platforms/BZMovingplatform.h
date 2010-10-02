//
//  BZMovingplatform.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//#import "KinematicNode.h"
#import "BZBodyNode.h"


enum{
	kPlatformDirectionHorizontal,
	kPlatformDirectionVertical,
};


//
// TIP:
// If you want to move the platforms using cocos2d actions
// then you must make it a subclass of StaticNode
//
//@interface BZMovingplatform : StaticNode {
//

@interface BZMovingplatform : BZBodyNode {

	int		direction;
	float	duration;
	float	translationInPixels;
	b2Vec2	origPosition;
	b2Vec2	finalPosition;
	b2Vec2	velocity;
	BOOL	goingForward;
}

//-(CCAction*) getAction;

-(void) updatePlatform:(ccTime)dt;

@end
