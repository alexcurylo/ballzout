//
//  BZMovingplatform.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "BZLevelConstants.h"
#import "BZMovingplatform.h"
#import "BZLevelScene.h"

//
// BZMovingplatform: A Kinematic platfroms that uses cocos2d actions instead of box2d forces
//
// Supported parameters:
//	direction (string): "horizontal" is an horizontal movement. Else it will be a vertical movement
//  duration (float): the duration of the movement
//  translation (float): how many pixels does the platform move
//

@implementation BZMovingplatform

@synthesize platformColor;


//-(id) initWithBody:(b2Body*)body game:(GameNode*)game
//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game
{
	if( (self=[super initWithBody:body params:params scene:game]) )
   {		
      [self setParameters:params];
      twcheck(self.platformColor);

		//CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solid_platform.png"];
      //CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"texture-rocks.png"];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"texture-marble.png"];
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
		
		// Moving platforms are kinematic, as opposed to non-moving platforms being whatever the default is
		body->SetType(b2_kinematicBody);
		
		// boxes (platforms) needs a 0,1 anchor point
		[self setAnchorPoint:ccp(0,1)];
		
		// this is only tracked by monving platforms
		origPosition = body->GetPosition();
				
		CGSize size = CGSizeZero;
		
		b2Fixture *fixture = body->GetFixtureList();
		
		b2Shape::Type t = fixture->GetType();
				
		if( t == b2Shape::e_polygon ) {
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
				CCLOG(@"LevelSVG: BZMovingplatform with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: BZMovingplatform with unsupported shape type");
      
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

   // shared with BZPlatform
   
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
      twlog("BZMovingplatform color named '%@' is: %@ ", colorName, self.platformColor);
   }
   else 
   {
      twlog("BZMovingplatform had no color parameter!");
   }
   
   
   // for moving
   
	NSString *dir = [params objectForKey:@"direction"];
	if( [dir isEqualToString:@"horizontal"] )
		direction = kPlatformDirectionHorizontal;
	else 
		direction = kPlatformDirectionVertical;
	
	// default duration
	duration = (direction == kPlatformDirectionHorizontal ? 4 : 1.5f);
	
	// default translation
	translationInPixels = (direction == kPlatformDirectionHorizontal ? 250 : 150);

	NSString *dur = [params objectForKey:@"duration"];
	if( dur )
		duration = [dur floatValue];

	NSString *trans = [params objectForKey:@"translation"];
	if( trans )
		translationInPixels = [trans floatValue];
	
	// Move the plaform using actions
//	[self runAction: [self getAction]];
   
   // this was an experiment? Seems to have no effect
   //self.body->ApplyTorque(5);
}

//
// Needed when the platform is updated using SetLinearVelocity()
//
-(void) onEnter
{
	[super onEnter];
	goingForward = YES;
	
	float vel = (translationInPixels / duration) /kPhysicsPTMRatio;

	if( direction == kPlatformDirectionHorizontal ) {
		velocity = b2Vec2( vel, 0 );
		finalPosition = origPosition + b2Vec2(translationInPixels/kPhysicsPTMRatio, 0);
	}
	else {
		velocity = b2Vec2( 0, vel );
		finalPosition = origPosition + b2Vec2(0, translationInPixels/kPhysicsPTMRatio);
	}
	
	body_->SetLinearVelocity( velocity );
	
	[self schedule: @selector(updatePlatform:) interval:duration];

}

//
// Platform is being moved by SetLinearVelocity()
//
-(void) updatePlatform:(ccTime)dt
{
   (void)dt;

   // don't update if obstacles are ghosted
   
   if (!body_->IsActive())
      return;
   
   // or if game is paused
   
   if (kLevelStatePaused == game_.levelState)
       return;
   
   // right, we can update then
   
	b2Vec2 currVel = body_->GetLinearVelocity();
	
	b2Vec2 destPos;
	if( goingForward ) {
		//body_->SetTransform( finalPosition, 0 );
      // for rotated platforms ...alex
		body_->SetTransform( finalPosition, body_->GetAngle() );
		body_->SetLinearVelocity( -velocity );
		goingForward = NO;
	} else {
		//body_->SetTransform( origPosition, 0 );
      // for rotated platforms ...alex
		body_->SetTransform( origPosition, body_->GetAngle() );
		body_->SetLinearVelocity( velocity );
		goingForward = YES;
	}
}

//-(CCAction*) getAction
//{	
//	
//	id forward;
//	if( direction == kPlatformDirectionHorizontal)
//		// Horizontal Movement
//		forward = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(translation,0)] rate:3];
//	else 
//		// Vertical Movement
//		forward = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,translation)] rate:3];
//		
//	
//	id back = [forward reverse];
//	id seq = [CCSequence actions:forward, back, nil];
//	return [CCRepeatForever actionWithAction:seq];
//}

@end
