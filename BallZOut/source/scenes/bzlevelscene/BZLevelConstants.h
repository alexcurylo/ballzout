//
//  BZLevelConstants.h
//
//  Copyright 2009 Sapus Media. All rights reserved.
//

//#define SHOW_PHYSICS 1

#pragma mark -
#pragma mark Physics - General

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define kPhysicsPTMRatio (48.0f)


// how many segments per bezier curve
// Try to reduce this value if you have lot of bezier curves and you also have performance problems
#define kPhysicsDefaultBezierSegments (15)

#pragma mark Physics - Bodies

// default friction used by all physics objects
#define kPhysicsDefaultFriction (0.2f)

// default density used by all physics objects. Default is static objects
#define kPhysicsDefaultDensity (0.0f)

// default restitution used by all physics objects.
#define kPhysicsDefaultRestitution (0.0f)

// default Enemy friction
#define kPhysicsDefaultEnemyFriction	(0.2f);

// default Enemy density
#define kPhysicsDefaultEnemyDensity		(0.3f)

// default Enemy Restitution
#define kPhysicsDefaultEnemyRestitution	(0.2f)

// default ball settings
// http://stackoverflow.com/questions/2962344/making-billiards-in-box2d
#define kPhysicsDefaultBallFriction	(0.2f);
#define kPhysicsDefaultBallDensity		(0.3f)
#define kPhysicsDefaultBallRestitution	(0.2f)
// "Normally you will use a damping value between 0 and 0.1."
#define kPhysicsDefaultBallLinearDamping	(0.4f)
#define kPhysicsDefaultBallAngularDamping	(0.3f)

// 0.016555 is where it was when we hit stop and it really wasn't moving
#define kPhysicsShotEndedLengthSquared	(0.02f)


#pragma mark Physics - Forces and Impulses

// set to 1 to apply torque instead of force
//#define kPhysicsApplyTorque		1

// seconds that must elpase before a force is applied to the hero
#define kPhysicsHeroForceInterval (0.2f)

// gravity
#define kPhysicsWorldGravityX	(0)
//#define kPhysicsWorldGravityY	(-10)
#define kPhysicsWorldGravityY	(0)

// How many nodes can be removed per cycle
#define kMaxNodesToBeRemoved	6


#pragma mark -
#pragma mark Layering 

#define kPriorityShootForce 10
#define kPriorityShoot 100


#pragma mark -
#pragma mark Game Constants 

#define kLevelHeight (480.f)
#define kLevelWidth (320.f)

#define kLevelHeroballCount 3
#define kLevelHeroballY 30

#define kScoreBallOut 100

