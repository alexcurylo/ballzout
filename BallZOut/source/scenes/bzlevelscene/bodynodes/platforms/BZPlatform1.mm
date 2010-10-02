//
//  BZPlatform1.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "BZLevelConstants.h"
#import "BZLevelScene.h"
#import "BZPlatform1.h"

//
// BZPlatform1: A one-sided platform. It uses the "platform.png" as a texture
//
// Supported parameters:
//	visible (string): "no" means that this will be an invisible platform
//

@implementation BZPlatform1

//-(id) initWithBody:(b2Body*)body game:(GameNode*)game
- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
{
	if( (self=[super initWithBody:body gameScene:game]))
   {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"platform.png"];
		[self setDisplayFrame:frame];

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_PLATFORMS_PNG;
		isTouchable_ = NO;
		
		[self setAnchorPoint: ccp(0,1)];

		CGSize size = CGSizeZero;

      /* this makes right side drop, and then it's bounceable
      if (YES) // make spinnable, as in Spinner.mm
      {
         /// *
         [self destroyAllFixturesFromBody:body];
         // 2. create 2 boxes
         b2FixtureDef	fd;
         fd.density = 20;
         fd.restitution = 0.2f;
         fd.friction = 0.3f;
         b2PolygonShape	shape;
         fd.shape = &shape;
         shape.SetAsBox(150.f/kPhysicsPTMRatio, 10.f/kPhysicsPTMRatio);
         body->CreateFixture(&fd);
         //shape.SetAsBox(width, radius);
         //body->CreateFixture(&fd);
          // * /
         body->SetType(b2_dynamicBody);
         
         // 3. create an static body
         b2BodyDef bodyDef;
         b2World *world = [game world];
         b2Body *static_body = world->CreateBody(&bodyDef);
         
         // 4. create the revolute joint with the 2 bodies
         b2RevoluteJointDef jointDef;
         jointDef.Initialize(static_body,body,body->GetWorldCenter());
         jointDef.maxMotorTorque = 1000 * body->GetMass();												
         world->CreateJoint(&jointDef);		
      }
   */

		b2Fixture *fixture = body->GetFixtureList();
		b2Shape::Type t = fixture->GetType();
      
		if( t ==  b2Shape::e_polygon ) {
			b2PolygonShape *box = dynamic_cast<b2PolygonShape*>(fixture->GetShape());
			if( box->GetVertexCount() == 4 ) {
				size.width = box->GetVertex(2).x * kPhysicsPTMRatio;
				size.height = -box->GetVertex(0).y * kPhysicsPTMRatio;

				[self setTextureRect:CGRectMake(rect_.origin.x, rect_.origin.y, size.width, size.height)];				 
			} else
				CCLOG(@"LevelSVG: BZPlatform1 with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: BZPlatform1 with unsupported shape type");
	}
	return self;
}

-(void) setParameters:(NSDictionary*)params
{
	[super setParameters:params];
	
	NSString *visible = [params objectForKey:@"visible"];
	if( [visible isEqual:@"no"] )
		[self setVisible:NO];
	else
		[self setVisible:YES];

	NSString *angular = [params objectForKey:@"angular"];
   if (angular.length)
   {
      float angularVelocity = angular.floatValue;
      self.body->ApplyTorque(angularVelocity);
   }
}
@end
