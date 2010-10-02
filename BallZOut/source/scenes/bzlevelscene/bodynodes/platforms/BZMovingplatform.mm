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

//
// BZMovingplatform: A Kinematic platfroms that uses cocos2d actions instead of box2d forces
//
// Supported parameters:
//	direction (string): "horizontal" is an horizontal movement. Else it will be a vertical movement
//  duration (float): the duration of the movement
//  translation (float): how many pixels does the platform move
//

@implementation BZMovingplatform


//-(id) initWithBody:(b2Body*)body game:(GameNode*)game
- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game
{
	if( (self=[super initWithBody:body gameScene:game]) ) {
		
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solid_platform.png"];
		[self setDisplayFrame:frame];
		
		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_PLATFORMS_PNG;
		
		isTouchable_ = NO;
		
		// Platforms are kinematic
		body->SetType(b2_kinematicBody);
		
		// boxes (platforms) needs a 0,1 anchor point
		[self setAnchorPoint:ccp(0,1)];
		
		origPosition = body->GetPosition();
				
		CGSize size = CGSizeZero;
		
		b2Fixture *fixture = body->GetFixtureList();
		
		b2Shape::Type t = fixture->GetType();
				
		if( t == b2Shape::e_polygon ) {
			b2PolygonShape *box = dynamic_cast<b2PolygonShape*>(fixture->GetShape());
			if( box->GetVertexCount() == 4 ) {
				size.width = box->GetVertex(2).x * kPhysicsPTMRatio;
				size.height = -box->GetVertex(0).y * kPhysicsPTMRatio;
				
				[self setTextureRect:CGRectMake(rect_.origin.x, rect_.origin.y, size.width, size.height)];				 
				
			} else
				CCLOG(@"LevelSVG: BZMovingplatform with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: BZMovingplatform with unsupported shape type");
				
	}
	return self;
}

-(void) setParameters:(NSDictionary*)dict
{
	[super setParameters:dict];

	NSString *dir = [dict objectForKey:@"direction"];
	if( [dir isEqualToString:@"horizontal"] )
		direction = kPlatformDirectionHorizontal;
	else 
		direction = kPlatformDirectionVertical;
	
	// default duration
	duration = (direction == kPlatformDirectionHorizontal ? 4 : 1.5f);
	
	// default translation
	translationInPixels = (direction == kPlatformDirectionHorizontal ? 250 : 150);

	NSString *dur = [dict objectForKey:@"duration"];
	if( dur )
		duration = [dur floatValue];

	NSString *trans = [dict objectForKey:@"translation"];
	if( trans )
		translationInPixels = [trans floatValue];
	
	// Move the plaform using actions
//	[self runAction: [self getAction]];
   
   self.body->ApplyTorque(5);
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

	b2Vec2 currVel = body_->GetLinearVelocity();
	
	b2Vec2 destPos;
	if( goingForward ) {
		body_->SetTransform( finalPosition, 0 );
		body_->SetLinearVelocity( -velocity );
		goingForward = NO;
	} else {
		body_->SetTransform( origPosition, 0 );
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
