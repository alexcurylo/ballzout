//
//  HeroBox.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/02/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "SimpleAudioEngine.h"

#import "HeroBox.h"
#import "GameConfiguration.h"
#import "GameConstants.h"
#import "GameNode.h"
#import "Bullet.h"


#define SPRITE_WIDTH 20
#define SPRITE_HEIGHT 44

// Forces & Impulses
#define	JUMP_IMPULSE (2.3f)
#define MOVE_FORCE (5.0f)

#define FIRE_FREQUENCY (0.2f)

//
// Hero: The main character of the game.
//
@implementation Herobox

-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {

		//
		// Set up the right texture
		//
		
		// Set the default frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"walk-right_01.png"];
		[self setDisplayFrame:frame];

		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

		//
		// box2d stuff: Create the "correct" fixture
		//
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		
		b2PolygonShape shape;
		
		// Sprite size is SPRITE_WIDTH x SPRITE_HEIGHT
		float height = (SPRITE_HEIGHT / kPhysicsPTMRatio) / 2;
		float width = (SPRITE_WIDTH/ kPhysicsPTMRatio) / 2;
		
		// vertices should be in Counter Clock-Wise order, orderwise it will crash
		b2Vec2 vertices[4];
		vertices[0].Set(-width,-height);	// bottom-left
		vertices[1].Set(width,-height);		// bottom-right
		vertices[2].Set(width,height);		// top-right
		vertices[3].Set(-width,height);		// top-left
		shape.Set(vertices, 4);

		// TIP: friction should be 0 to avoid sticking into walls
		fd.friction		= 0.0f;
		fd.density		= 1.0f;
		fd.restitution	= 0.0f;
				

		// TIP: fixed rotation. The hero can't rotate. Very useful for Super Mario like games
		body->SetFixedRotation(true);

		fd.shape = &shape;
		
		// Collision filtering between Hero and Bullet
		// If the groupIndex is negative, then the fixtures NEVER collide.
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;

		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);
		
		//
		// Setup physics forces & impulses
		//
		jumpImpulse = JUMP_IMPULSE;
		moveForce = MOVE_FORCE;

		//
		// Setup custom HeroBox ivars
		//
		facingRight_ = YES;
		gettimeofday( &lastFire_, NULL);	
		
	}
	return self;
}

#pragma mark HeroBox - Movements

-(void) move:(CGPoint)direction
{
	
	//
	// TIP:
	// HeroRound uses ApplyForce to move the hero.
	// HeroBox uses SetLinearVelocity (simpler to code, and probably more realistic)
	//
	
	// HeroBox is optimized for platform games, so it can only move right/left


	float xVel = moveForce *direction.x;

	b2Vec2 velocity = body_->GetLinearVelocity();
	
	velocity.x = xVel;
	body_->SetLinearVelocity( velocity );
	
	// needed for bullets. Don't update if x==0
	//if( xVel != 0 )
   // avoid float comparison warning ...alex
   if (twNotEqualFloats(0, xVel))
		facingRight_ = (xVel > 0);
	
	[self updateFrames:direction];
}

-(void) fire
{
	struct timeval now;
	gettimeofday( &now, NULL);	
	ccTime dt = (now.tv_sec - lastFire_.tv_sec) + (now.tv_usec - lastFire_.tv_usec) / 1000000.0f;
	
	if( dt > FIRE_FREQUENCY ) {

		lastFire_ = now;

		Bullet *bullet = [[Bullet alloc] initWithPosition:body_->GetPosition() direction:(facingRight_ ? 1 : -1) game:game_];
		[game_ addBodyNode:bullet z:0];
		[bullet release];
	}
}

-(void) jump
{
	BOOL touchingGround = NO;

	if( contactPointCount > 0 ) {
		
		int foundContacts=0;
		
		//
		// TIP:
		// only take into account the normals that have a Y component greater that 0.3
		// You might want to customize this value for your game.
		//
		// Explanation:
		// If the hero is on top of 100% horizontal platform, then Y==1
		// If it is on top of platform rotate 45 degrees, then Y==0.5
		// If it is touching a wall Y==0
		// If it is touching a ceiling then, Y== -1
		//

		for( int i=0; i<kMaxContactPoints && foundContacts < contactPointCount;i++ ) {
			ContactPoint* point = contactPoints + i;
			if( point->otherFixture ) {
				foundContacts++;
				
				//
				// Use the greater Y normal
				//
				if( point->normal.y > 0.5f) {
					touchingGround = YES;

					b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
					
					//
					// It's possible that while touching ground, the Hero already started to jump
					// so, the 2nd time, the impulse should be lower
					//					
					float impulseYFactor = 1;
					b2Vec2 vel = body_->GetLinearVelocity();
					if( vel.y > 0 )
						impulseYFactor = vel.y / 40;
					
					
					//
					// TIP:
					// The impulse always is "up". To simulate a more realistic
					// jump, see HeroRound.mm, since it uses the normal, but it this realism is not
					// needed in Mario-like games
					//
					body_->ApplyLinearImpulse( b2Vec2(0, jumpImpulse * impulseYFactor), p );

					//
					// TIP:
					// Another way (less realistic) to simulate a jump, is by
					// using SetLinearVelocity()
					// eg:
					//
					//		b2Vec2 vel = body_->GetLinearVelocity();
					//		body_->SetLinearVelocity( b2Vec2(vel.x, 6) );
					
					
					break;
				}
			}
		}
		
	}

	if( ! touchingGround ) {
		
		//
		// TIP:
		// Reduce the impulse if the jump button is still pressed, and the Hero is in the air
		//		
		b2Vec2 vel = body_->GetLinearVelocity();

		// going up ? so apply little impulses
		if( vel.y > 0 ) {
			b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
			
			// 160 is just a constant to get the impulse a N times lower
			float impY = jumpImpulse * vel.y/160;
			body_->ApplyLinearImpulse( b2Vec2(0,impY), p);
		}
	}
}

-(void) updateFrames:(CGPoint)force
{
	// rect is the texture rect of the sprite
	CGRect r = rect_;

	//if( force.x == 0 )
   // avoid float comparison warning ...alex
   if (twNotEqualFloats(0, force.x))
		return;

	const char *dir = "left";
	
	if( force.x > 0 )
		dir = "right";

	// There are 8 frames
	// And every 20 pixels a new frame should be displayed
	unsigned int x = ((unsigned int)position_.x /20) % 8;
	
	// increase frame index, since frame names go from 1 to 8 and not from 0 to 7.
	x++;
	
	NSString *str = [NSString stringWithFormat:@"walk-%s_%02d.png", dir, x];
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:str];
	[self setDisplayFrame:frame];
}


@end
