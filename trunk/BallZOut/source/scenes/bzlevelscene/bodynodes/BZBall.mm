//
//  BZBall.mm
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

//#import "GameNode.h"
#import "BZLevelScene.h"
#import "BZLevelConstants.h"
#import "BZBall.h"


@implementation BZBall

- (id)initWithBody:(b2Body*)body
         gameScene:(BZLevelScene*)game
          diameter:(CGFloat)diameter
       spriteFrame:(NSString *)spriteFrame;
{
	if ( (self=[super initWithBody:body gameScene:game]) )
   {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrame];
		[self setDisplayFrame:frame];

		preferredParent_ = BN_PREFERRED_PARENT_MARBLES_PNG;

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		// listen to beginContact, endContact and presolve
		//reportContacts_ = BN_CONTACT_BEGIN | BN_CONTACT_END | BN_CONTACT_PRESOLVE;

      // this body can't be dragged
		isTouchable_ = NO;

		//
		// box2d stuff: Create the "correct" fixture
		//

		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		b2CircleShape	shape;
		shape.m_radius = (diameter / kPhysicsPTMRatio) / 2.f;		// 1 meter of diameter (optimized size)
		fd.friction		= kPhysicsDefaultBallFriction;
		fd.density		= kPhysicsDefaultBallDensity;
		fd.restitution	= kPhysicsDefaultBallRestitution;
		fd.shape = &shape;
		
		// filtering... in case you want to avoid collisions between enemies
//		fd.filter.groupIndex = - kCollisionFilterGroupIndexEnemy;
		
		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);	
		
      // added for balls ...alex
      body->SetLinearDamping(kPhysicsDefaultBallLinearDamping);
      body->SetAngularDamping(kPhysicsDefaultBallAngularDamping);
      
		//patrolActivated_ = NO;

      removeMe_ = NO;

		[self schedule:@selector(update:)];
	}
   
	return self;
}

- (void)setParameters:(NSDictionary *)params
{
	[super setParameters:params];

   /*
	NSString *patrolTime = [params objectForKey:@"patrolTime"];
	NSString *patrolSpeed = [params objectForKey:@"patrolSpeed"];
	
	if( patrolTime ) {
		patrolTime_ = [patrolTime floatValue];
		
		patrolSpeed_ = 2; // default value
		if( patrolSpeed )
			patrolSpeed_ = [patrolSpeed floatValue];

		patrolActivated_ = YES;
	}
    */
}

- (void)outsideBounds
{
	[game_ removeB2Body:body_];
}

- (void)update:(ccTime)dt
{
   (void)dt;
   
   /*
    //if (!self.body->IsActive())
      //return;
   float velsquared = self.body->GetLinearVelocity().LengthSquared();
   if (0.001 > velsquared)
      return;
   twlog("ball %@ velocity length squared: %f", self, velsquared);
   */
   
   b2Vec2 ballPosition = self.body->GetWorldCenter();
   if ((0 > ballPosition.x) || (0 > ballPosition.y))
      removeMe_ = YES;
   else if (ballPosition.x > (kLevelWidth / kPhysicsPTMRatio))
      removeMe_ = YES;
   else if (ballPosition.y > (kLevelHeight / kPhysicsPTMRatio))
      removeMe_ = YES;

	if (removeMe_)
   {
      [self outsideBounds];
      return;
	}
   
	/*
   // move the enemy if "patrol" is activated
	// In this example the enemy is moved using Box2d, and not cocos2d actions.
	//
	if( patrolActivated_ ) {
		patrolDT_ += dt;
		if( patrolDT_ >= patrolTime_ ) {
			patrolDT_ = 0;
			
			// This line eliminates the inertia
			body_->SetAngularVelocity(0);
			
			// Change the direction of the movement
			if( patrolDirectionLeft_ ) {
				body_->SetLinearVelocity( b2Vec2(-patrolSpeed_,0) );
			} else {
				body_->SetLinearVelocity( b2Vec2(patrolSpeed_,0) );
			}
			patrolDirectionLeft_ = ! patrolDirectionLeft_;
		}
	}
    */
}

/*
-(void) touchedByBullet:(id)bullet
{
   (void)bullet;
	[game_ removeB2Body:body_];
	[[SimpleAudioEngine sharedEngine] playEffect: @"enemy_killed.wav"];
	[game_ increaseScore:10];

}
*/

@end
