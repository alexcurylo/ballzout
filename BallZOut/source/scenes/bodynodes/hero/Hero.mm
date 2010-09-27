//
//  Hero.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "Joystick.h"
#import "GameNode.h"
#import "GameConfiguration.h"
#import "GameConstants.h"
#import "Hero.h"
#import "Platform1.h"
#import "BadGuy.h"
//#import "Princess.h"
#import "BonusNode.h"

@interface Hero (Private)
-(void) readJoystick;
-(void) updateCollisions;

-(void) stopBlinking:(id)sender;

@end

//
// Hero: Base class of the Hero.
// The Hero is the main character, is the sprite that is controlled by the player.
// The base class handles all the collisions, and the input (d-pad or accelerometer)
//
@implementation Hero

@synthesize joystick=joystick_;
@synthesize isBlinking=isBlinking_;

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		// listen to beginContact, endContact and presolve
		reportContacts_ = BN_CONTACT_BEGIN | BN_CONTACT_END | BN_CONTACT_PRESOLVE;
		
		// this body can't be dragged
		isTouchable_ = NO;
		
		// It only blinks after touching an enemy
		isBlinking_ = NO;

		// weak ref
		world = [game_ world];
		
		// Tell the game, that this instace is the Hero
		[game setHero:self];
		
		// hero collisions
		contactPointCount = 0;
		
		// hero 
		elapsedTime = lastTimeForceApplied = 0;
	
		// optimization: calculate the direction at init time
		controlDirection = [[GameConfiguration sharedConfiguration] controlDirection];

		// schedule the Hero main loop
		[self scheduleUpdate];
	}
	return self;
}

#pragma mark Hero - Contact Listener

//
// To know at any moment the list of contacts of the hero, you should mantain a list based on being/endContact
//
-(void) beginContact:(b2Contact*)contact
{
	// 
	BOOL otherIsA = YES;
	
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"Hero: Box2d bug");

	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	
	NSAssert( bodyA != bodyB, @"Hero: Box2d bug");
	
	// Box2d doesn't guarantees the order of the fixtures
	otherIsA = (bodyA == body_) ? NO : YES;


	// find empty place
	int emptyIndex;
	for(emptyIndex=0; emptyIndex<kMaxContactPoints;emptyIndex++) {
		if( contactPoints[emptyIndex].otherFixture == NULL )
			break;
	}
	NSAssert( emptyIndex < kMaxContactPoints, @"LevelSVG: Can't find an empty place in the contacts");
		
	// XXX: should support manifolds
	ContactPoint* cp = contactPoints + emptyIndex;
	cp->otherFixture = ( otherIsA ? fixtureA :fixtureB );
	cp->position = b2Vec2_zero;
	cp->normal = otherIsA ? worldManifold.normal : -worldManifold.normal;
	cp->state = b2_addState;
	contactPointCount++;
}

-(void) endContact:(b2Contact*)contact
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	b2Body *body = fixtureA->GetBody();
	
	b2Fixture *otherFixture = (body == body_) ? fixtureB : fixtureA;
	
	int emptyIndex;
	for(emptyIndex=0; emptyIndex<kMaxContactPoints;emptyIndex++) {
		if( contactPoints[emptyIndex].otherFixture == otherFixture ) {
			contactPoints[emptyIndex].otherFixture = NULL;
			contactPointCount--;
			break;
		}
	}	
}

//
// Presolve is needed for one-sided platforms
// If you are not going to use them, you can disable this callback
//
-(void) preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*) oldManifold
{
   (void)oldManifold;
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	b2Fixture *fixtureA = contact->GetFixtureA();
	b2Fixture *fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"preSolveContact: BOX2D bug");
	
	b2Body	*bodyA = fixtureA->GetBody();
	b2Body	*bodyB = fixtureB->GetBody();
	NSAssert( bodyA != bodyB, @"preSolveContact: BOX2D bug");

	BodyNode *dataA = (BodyNode*) bodyA->GetUserData();
	BodyNode *dataB = (BodyNode*) bodyB->GetUserData();
	
	// check if the other fixture is a one-sided platform.
	
	Class p1 = [Platform1 class];
	if( [dataA isKindOfClass:p1] ||
	   [dataB isKindOfClass:p1] ) {

		// Box2d doesn't guarantees the order of the fixtures
		BOOL heroIsA = (bodyA == body_) ? YES : NO;
		b2Fixture *otherFixture = heroIsA ? fixtureB : fixtureA;
		
		// check for normal
		if( (!heroIsA && worldManifold.normal.y < 0) || (heroIsA && worldManifold.normal.y > 0) )
		{
			contact->SetEnabled(false);
			
		} else {
			// update contact. Why ?
			// Because if the sprite is passing through a "one sided platform" probably it will
			// have a normal.y < 0, but after passing through, the normal.y won't be < 0 anymore since it
			// has already passed trhough, and the "jump" logic depends on the normal
			for( int i=0; i<kMaxContactPoints;i++ ) {
				ContactPoint* point = contactPoints + i;
				if( point && point->otherFixture == otherFixture ) {
					point->normal = heroIsA ? -worldManifold.normal : worldManifold.normal;
					break;
				}
			}
		}
	}
	
}

#pragma mark Hero - Main Loop
-(void) update:(ccTime)dt
{
	elapsedTime += dt;

	GameState state = [game_ gameState];
	if( state == kGameStatePlaying ) {
		[self readJoystick];
		[self updateCollisions];
	}
}

-(void) readJoystick
{
	if( [joystick_ isPadEnabled] ) {
		CGPoint v = [joystick_ getCurrentNormalizedVelocity];
		[self move:v];
	}
	
	if( [joystick_ isButtonPressed:BUTTON_A] )
		[self jump];
	
	if( [joystick_ isButtonPressed:BUTTON_B] )
		[self fire];
}

-(void) updateCollisions
{
	// We are going to destroy some bodies according to contact
	// points. We must buffer the bodies that should be destroyed
	// because they may belong to multiple contact points.
	const int32 k_maxNuke = 6;
	b2Body* nuke[k_maxNuke];
	int32 nukeCount = 0;
	
	// Traverse the contact results.
	int found = 0;
	for (int32 i = 0; i < kMaxContactPoints && found < contactPointCount; i++)
	{
		ContactPoint* point = contactPoints + i;
		b2Fixture *otherFixture = point->otherFixture;
		
		if( otherFixture ) {
		
			found++;
			b2Body* body = otherFixture->GetBody();
			
			BodyNode *node = (BodyNode*) body->GetUserData();
			
			// nuke "bonus nodes" when collided with hero
			if( [node isKindOfClass:[BonusNode class]] ) {

				// destroy the object
				nuke[nukeCount++] = body;
				
				// remove it from contact list
				point->otherFixture = NULL;
				contactPointCount--;
			}
			
			// Send the "touchByHero" message

			// special case for "BadGuy"
			if( [node isKindOfClass:[BadGuy class]]) {
				if( !isBlinking_  ) {
					[(BadGuy*) node performSelector:@selector(touchedByHero)];
					[self blinkHero];
				}
			}
			
			else if( [node respondsToSelector:@selector(touchedByHero)] )
				[node performSelector:@selector(touchedByHero)];

		}
	}	
}

#pragma mark Hero - Movements
-(void) move:(CGPoint)direction
{
   (void)direction;
	// override me
}


-(void) jump
{
	// override me
}

-(void) fire
{
	// override me
}

-(void) blinkHero
{
	CCBlink *blink = [CCBlink actionWithDuration:1.5f blinks:10];
	CCSequence *seq = [CCSequence actions:
					   blink,
					   [CCCallFuncN actionWithTarget:self selector:@selector(stopBlinking:)],
					   (id)nil
    ];
	isBlinking_ = YES;
	[self runAction:seq];
}
	
-(void) stopBlinking:(id)sender
{
   (void)sender;
	isBlinking_ = NO;
}

-(void) updateFrames:(CGPoint)p
{
   (void)p;
	// Override this method if you want to udpate the sprite frame after it has been moved
}

#pragma mark Hero - Accelerometer
-(void) onEnter
{
	[super onEnter];
	
	ControlType type = [[GameConfiguration sharedConfiguration] controlType];
	if( type==kControlTypeTilt ) {
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
}

-(void) onExit
{
	[super onExit];
	ControlType type = [[GameConfiguration sharedConfiguration] controlType];
	if( type==kControlTypeTilt ) {
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	}
}

// will be called only if using Tilt controls
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
   (void)accelerometer;
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	GameState state = [game_ gameState];
	// only update controls if game is "playing"
	if( state == kGameStatePlaying ) {
		float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
		float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
		
		prevX = accelX;
		prevY = accelY;
		
		// tilt control
		// accelerometer values are in "Portrait" mode. Change them to Landscape left
		float x = -accelY;
		float y = accelX;
		
		// if using tilt 2 way, then set y=0
		if(  controlDirection == kControlDirection2Way )
			y = 0;
		
		[self move:ccp(x,y)];
	}
}

@end
