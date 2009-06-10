//
//  TWC2GameNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "chipmunk.h"

typedef enum
{
	kGameWaiting,
	kGameStart,
	kGameFlying,
	kGameOver,
	kGameTryAgain,
	kGameDrawTongue,
	kGameIsBeingReplaced,
} tGameState;

@interface TWC2GameNode : Layer <UIAccelerometerDelegate>
{
	
/*
 ccTime		flyingDeltaAccum;
	Texture2D	*tongue;
*/
	// bug in hardware accelerometer
	BOOL		_accelValsRecieved;
	int        _accelDelay;
/*	
	// accumulator for the physics engine
	float		physicsAccumulator;

	// TIP:
	// GameHUD will access these variables, and instead of creating properties for each one of these,
	// it is faster to make them public
	// In general, I don't recommend making public every variable, but sometimes it is
	// faster
@public
	AtlasSprite			*sapusSprite;
*/
	
	cpSpace		*space;
/*
 cpJoint		*joint;
	cpBody		*pivotBody;
	cpBody		*sapusBody;
*/
	cpVect accelerometerForce;
/*
	BOOL		jointAdded;
	
	float		throwAngle;
	float		throwVelocity;
	*/
   
	tGameState	state;
	/*
	int			displayFrame;
 */
   
   //Sprite *pinballSprite;
   //Sprite *brickSprite1;
	cpBody		*pinballBody;
	//cpBody		*brickBody1;
	//cpBody		*brickBody2;
}

+(Scene*) scene;
+(int) score;
-(void) step: (ccTime) dt;

/*
-(void) addJoint;
*/

@end
