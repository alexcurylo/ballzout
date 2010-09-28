//
//  BZBodyNode.m
//
//  Copyright 2009 Sapus Media. All rights reserved.
//


#import <Box2D/Box2D.h>

#import "BZBodyNode.h"
#import "BZLevelConstants.h"
//#import "GameNode.h"
#import "BZLevelScene.h"

@implementation BZBodyNode

@synthesize body = body_;
@synthesize reportContacts=reportContacts_;
@synthesize isTouchable=isTouchable_;
@synthesize preferredParent=preferredParent_;
@synthesize properties=properties_;

//-(id) initWithBody:(b2Body*)body game:(GameNode*)game
-(id) initWithBody:(b2Body*)body gameScene:(BZLevelScene *)game
{
	if( (self=[super init]) ) {

		reportContacts_ = BN_CONTACT_NONE;
		body_ = body;
		isTouchable_ = NO;
		body->SetUserData(self);
		
		game_ = game;
		
		preferredParent_ = BN_PREFERRED_PARENT_IGNORE;
		
		properties_ = BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS;
		
		// Position the sprite
		b2Vec2 bPos = body->GetPosition();
		self.position = ccp( bPos.x * kPhysicsPTMRatio, bPos.y * kPhysicsPTMRatio );
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"LevelSVG: deallocing %@", self);
	
	[super dealloc];
}

#pragma mark BZBodyNode - Parameters
-(void) setParameters:(NSDictionary *)params
{
   (void)params;
	// override me
}

// moving at a non-trivial rate?
- (BOOL)inMotion
{
   float lengthSquared = body_->GetLinearVelocity().LengthSquared();
   BOOL inMotion = kPhysicsShotEndedLengthSquared < lengthSquared;
   return inMotion;
}

// covering a point?
- (BOOL)coversPoint:(b2Vec2)point
{
   //b2AABB aabb; QueryAABB??
   b2Fixture* fixture = body_->GetFixtureList();
   twcheck(!fixture->GetNext()); // we expect balls to have one fixture
   if (fixture->TestPoint(point))
      return YES;
   return NO;
}

// box2d contact protocol
#pragma mark BZBodyNode - Contact protocol

-(void) beginContact:(b2Contact*) contact
{
   (void)contact;
	// override me
}
-(void) endContact:(b2Contact*) contact
{
   (void)contact;
	// override me
}
-(void) preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*) oldManifold
{
   (void)contact;
   (void)oldManifold;
	// override me
}
-(void) postSolveContact:(b2Contact*)contact impulse:(const b2ContactImpulse*) impulse
{
   (void)contact;
   (void)impulse;
	// override me
}

// helper functions
-(void) destroyAllFixturesFromBody:(b2Body*)body
{
	b2Fixture *fixture = body->GetFixtureList();
	while( fixture != nil ) {
		b2Fixture *tmp = fixture;
		fixture = fixture->GetNext();
		body->DestroyFixture(tmp);
	}
}
@end
