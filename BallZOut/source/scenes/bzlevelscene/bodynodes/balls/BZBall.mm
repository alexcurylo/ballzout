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
params:(NSDictionary *)params
         gameScene:(BZLevelScene*)game
          diameter:(CGFloat)diameter
       spriteFrame:(NSString *)spriteFrame;
{
	if ( (self=[super initWithBody:body params:params scene:game]) )
   {
      if (!spriteFrame.length)
      {
         /*
         // we will expect a parameter with color for the actual frame name later
         framePrefix_ = [[NSString stringWithFormat:@"ball%d", lrintf(diameter)] retain];
         // for now we'll put in a placeholder so it gets added without crashing
         spriteFrame = @"ball25-aqua.png";
          */
         NSString *prefix = [NSString stringWithFormat:@"ball%d", lrintf(diameter)];
         NSString *color = [params objectForKey:@"color"];
         if (!color.length)
         {
            twlog("color MISSING for a BZBall with no explicit frame name!! -- using yellow");
            color = @"yellow";
         }
         spriteFrame = [NSString stringWithFormat:@"%@-%@.png", prefix, color];
      }
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrame];
      [self setDisplayFrame:frame];


		preferredParent_ = BN_PREFERRED_PARENT_MARBLES_PNG;

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		// no, we're just going to skip contact sounds
      //reportContacts_ = BN_CONTACT_BEGIN;
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
   NSString *color = [params objectForKey:@"color"];
   if (color.length)
   {
      NSString *frameName = [NSString stringWithFormat:@"%@-%@.png", framePrefix_, color];
      twrelease(framePrefix_);
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
      [self setDisplayFrame:frame];
   }
*/
   
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
   else if (ballPosition.y > ( (kLevelHeight - kTopHUDHeight) / kPhysicsPTMRatio))
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
	[[SimpleAudioEngine sharedEngine] playEffect: @"enemy_killed.caf"];
	[game_ increaseScore:10];

}
*/

// set BN_CONTACT_BEGIN to call
// http://blog.xyris.ca/?p=40
// http://www.cocos2d-iphone.org/forum/topic/2702
// http://www.raywenderlich.com/457/intro-to-box2d-with-cocos2d-tutorial-bouncing-balls
// http://www.raywenderlich.com/505/how-to-create-a-simple-breakout-game-with-box2d-and-cocos2d-tutorial-part-22
-(void) beginContact:(b2Contact*)contact
{
   (void)contact;
//#warning not doing any contact sounds
   return;
  
   /*
   if (!contact->IsTouching() || !contact->IsEnabled())
   {
      twlog("BZBall beginContact: non-[touching|enabled] ball contact??");
      return;
   }
   
   // MyContactListener::BeginContact() calls both parties consecutively
   static BOOL _sSkipNext = NO;
   if (_sSkipNext)
   {
      _sSkipNext = NO;
      return;
   }
	
   // only one sound every .05 seconds, .2 seconds per pair, 6 max
   const NSTimeInterval kSoundLimit = .09f;
   const NSTimeInterval kSoundPairLimit = .3f;
   const NSInteger kOverallSounds = 6;
   
   static NSTimeInterval _slastTriggeredSound = 0;
   NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
   if (kSoundLimit > now - _slastTriggeredSound)
   {
      twlog("BZBall beginContact: contact too quick!");
      return;
   }
   
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"BZBall beginContact: Box2d bug #1");
 	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	NSAssert( bodyA != bodyB, @"BZBall beginContact: Box2d bug #2");
	BZBodyNode *sprite1 = (BZBodyNode*)bodyA->GetUserData();
	BZBodyNode *sprite2 = (BZBodyNode*)bodyB->GetUserData();
   if ([sprite1 isKindOfClass:[BZBall class]] && [sprite2 isKindOfClass:[BZBall class]])
      _sSkipNext = YES; // MyContactListener::BeginContact() calls both partiesconsecutively
	
   twlog("BZBall beginContact: '%@' and '%@'", [sprite1 class], [sprite2 class]);
   
   // yeah, we should have a list of objects and only trigger sounds every so often.
   // Platforms and balls seem to generate a lot of contacts.

   BOOL playSound = NO;
   
   typedef struct SPlayingPair
   {
      SPlayingPair() : spriteA(nil), spriteB(nil), when(0) {}
      BZBodyNode *spriteA;
      BZBodyNode *spriteB;
      NSTimeInterval when;
   } SPlayingPair;
   static SPlayingPair _sMaxTicks[kOverallSounds];
   
   // first, see if pair exists
   for (int soundIdx = 0; soundIdx < kOverallSounds; soundIdx++)
   {
      BOOL sprite1MatchesA = _sMaxTicks[soundIdx].spriteA == sprite1; 
      BOOL sprite2MatchesA = _sMaxTicks[soundIdx].spriteA == sprite2; 
      BOOL sprite1MatchesB = _sMaxTicks[soundIdx].spriteB == sprite1; 
      BOOL sprite2MatchesB = _sMaxTicks[soundIdx].spriteB == sprite2; 
      
      if ((sprite1MatchesA && sprite2MatchesB) || (sprite2MatchesA && sprite1MatchesB))
      {
         if (kSoundPairLimit > now - _slastTriggeredSound)
         {
            twlog("BZBall beginContact: sound quicker than pair limit");
            return;
         }
         else
         {
            twlog("BZBall beginContact: sound pair passed limit");
            playSound = YES;
            break;
         }
      }
   }
   
   // ok, look for empty/reusable slot
   if (!playSound)
   {
      NSTimeInterval oldestTime = 99999.f;
      int oldestSlot = 0;
      for (int soundIdx = 0; soundIdx < kOverallSounds; soundIdx++)
      {
         if (!_sMaxTicks[soundIdx].spriteA)
         {
            _sMaxTicks[soundIdx].spriteA = sprite1;
            _sMaxTicks[soundIdx].spriteB = sprite2;
            _sMaxTicks[soundIdx].when = now;
            playSound = YES;
            break;
         }
         NSTimeInterval slotTime = _sMaxTicks[soundIdx].when;
         if (slotTime < oldestTime)
         {
            oldestTime = slotTime;
            oldestSlot = soundIdx;
         }
      }
      if (!playSound)
      {
         if (0 <= oldestSlot)
         {
            _sMaxTicks[oldestSlot].spriteA = sprite1;
            _sMaxTicks[oldestSlot].spriteB = sprite2;
            _sMaxTicks[oldestSlot].when = now;
            playSound = YES;            
         }
         else
         {
            twlog("BZBall beginContact: couldn't find an oldest slot???");
         }
      }
   }
   
   // ok, play or not
   if (playSound)
   {
      twlog("BZBall beginContact: sound ok to play");
      [[SimpleAudioEngine sharedEngine] playEffect:@"ballhit.caf"];
      _slastTriggeredSound = now;
   }
   else
   {
      twlog("BZBall beginContact: sound not ok to play, probably because too many playing");
   }
*/
   
   /*
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	
	// Box2d doesn't guarantees the order of the fixtures
	BOOL otherIsA = (bodyA == body_) ? NO : YES;
   
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
   */
}

/*
 // set BN_CONTACT_END to call
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
*/

@end
