//
//  TWC2InstructionsNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "chipmunk.h"

/*
 typedef enum {
	kGameWaiting,
	kGameStart,
	kGameFlying,
	kGameOver,
	kGameTryAgain,
	kGameDrawTongue,
} tGameState;
*/

@interface TWC2InstructionsNode : Layer /*<UIAccelerometerDelegate>*/ {
	/*
	Sprite		*sapusSprite;
	
	ccTime		flyingDeltaAccum;
	Texture2D	*tongue;
	
	NSURL *mMovieURL;
	
	BOOL		_accelValsRecieved;
	int			_accelDelay;


@public
	cpSpace		*space;
	cpJoint		*joint;
	cpBody		*pivotBody;
	cpBody		*sapusBody;
	cpVect		force;
	BOOL		jointAdded;
	
	float		throwAngle;
	float		throwVelocity;
	
	tGameState	state;
	*/
}

+ (Scene*)scene;
/*
+(int) score;
-(void) step: (ccTime) dt;
-(void) addJoint;
 */
@end
