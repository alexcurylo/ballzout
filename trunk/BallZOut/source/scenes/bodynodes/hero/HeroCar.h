//
//  HeroCar.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 7/07/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Hero.h"

// The wheels
@interface WheelNode : BodyNode
{
	// sprite is blinking
	BOOL	isBlinking;

	// collision detection stuff, needed for jumping
@public
	ContactPoint			contactPoints[kMaxContactPoints];
	int32					contactPointCount;	
}
@end

// The car
@interface Herocar : Hero {
	// weak references
	WheelNode			*wheel1Node, *wheel2Node;

	b2Body				*wheel1;
	b2Body				*wheel2;
	
	b2PrismaticJoint	*spring1;
	b2PrismaticJoint	*spring2;
	b2RevoluteJoint		*motor1;
	b2RevoluteJoint		*motor2;
	
	float				baseSpringForce;
}

@end
