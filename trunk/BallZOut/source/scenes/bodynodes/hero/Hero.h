//
//  Hero.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2D/Box2D.h>
#import "BodyNode.h"
#import "GameConfiguration.h"


// forward declarations
@class GameScene;
@class Joystick;

const int32 kMaxContactPoints = 128;

struct ContactPoint
{
	b2Fixture*	otherFixture;
	b2Vec2		normal;
	b2Vec2		position;
	b2PointState state;
};

@interface Hero : BodyNode <UIAccelerometerDelegate> {
	
	// b2 world. weak ref
	b2World *world;
	
	// sprite is blinking
	BOOL	isBlinking_;
	
	// weak ref. The joystick status is read by the hero
	Joystick	*joystick_;

	// elapsed time on the game
	ccTime					elapsedTime;
	
	// last time that a forced was applied to our hero
	ccTime					lastTimeForceApplied;
	
	// collision detection stuff
	ContactPoint			contactPoints[kMaxContactPoints];
	int32					contactPointCount;	
	
	// optimization
	ControlDirection controlDirection;
	
	float					jumpImpulse;
	float					moveForce;
}

/** HUD should set the joystick */
@property (nonatomic,readwrite,assign) Joystick *joystick;

/** Is the hero blinking */
@property (nonatomic, readonly) BOOL isBlinking;

// Hero movements
-(void) jump;
-(void) fire;
-(void) move:(CGPoint)direction;
-(void) blinkHero;

-(void) update:(ccTime)dt;

// update sprite frames
-(void) updateFrames:(CGPoint)p;
@end
