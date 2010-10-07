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

@synthesize platformColor;

//-(id) initWithBody:(b2Body*)body game:(GameNode*)game
//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game
{
	if( (self=[super initWithBody:body params:params scene:game]))
   {
      [self setParameters:params];
      twcheck(self.platformColor);
      
		//CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"platform.png"];
		//CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"texture-space.png"];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"texture-gray.png"];
		[self setDisplayFrame:frame];

      // keep in sync with BZPlatform
      // http://efreedom.com/Question/1-3339955/Cocos2d-Solid-Color-Rectangular-Sprite
      // http://lukehatcher.com/post/449164972/coloring-sprites-with-cocos2d-iphone
      // http://death-mountain.com/2010/04/rgb-hsv-and-hue-shifting/
      if (self.platformColor)
      {
         const CGFloat *components = CGColorGetComponents(self.platformColor.CGColor);
         twcheck(4 == CGColorGetNumberOfComponents(self.platformColor.CGColor));
         ccColor3B spriteColor = ccc3(
                                      components[0] * 255.0, // red
                                      components[1] * 255.0, // green
                                      components[2] * 255.0  // blue
                                      // components[3] is alpha
                                      );
         self.color = spriteColor;
      }
      
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

            // this doesn't seem to repeat like we want;
            //[self setTextureRect:CGRectMake(rect_.origin.x, rect_.origin.y, size.width, size.height)];
            // so we'll just leave size at the { 128, 128 } size of texture-white it is, and set scale instead
            // that'll work fine as long as our platforms are solid colors
            float xScale = size.width / self.textureRect.size.width;
            float yScale = size.height / self.textureRect.size.height;
            [self setScaleX:xScale];
            [self setScaleY:yScale];
			} else
				CCLOG(@"LevelSVG: BZPlatform1 with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: BZPlatform1 with unsupported shape type");

      // was here before color, make any difference?
      //[self setParameters:params];
      
      // Tell the game, that this instace is an obstacle
		[game addObstacle:self];
   }
	return self;
}

- (void)dealloc
{
   twrelease(platformColor);
   
   [super dealloc];
}

-(void) setParameters:(NSDictionary*)params
{
	[super setParameters:params];
   
   NSString *colorName = [params objectForKey:@"color"];
   if (colorName.length)
   {
      SEL selector = NSSelectorFromString(colorName);
      BOOL okSelector = [UIColor respondsToSelector:selector];
      twcheck(okSelector);
      if (okSelector)
         self.platformColor = [UIColor performSelector:selector];
   }
   
   if (self.platformColor)
   {
      twlog("BZPlatform1 color named '%@' is: %@ ", colorName, self.platformColor);
   }
   else 
   {
      twlog("BZPlatform1 had no color parameter!");
   }
   
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
