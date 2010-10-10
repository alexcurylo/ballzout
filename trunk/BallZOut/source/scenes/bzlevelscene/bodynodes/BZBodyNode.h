//
//  BZBodyNode.h
//
//  Copyright 2009,2010 Sapus Media. All rights reserved.
//


// box2d classes
class b2Body;
class b2Contact;
class b2ContactImpulse;
class b2Manifold;
//@class GameNode;
@class BZLevelScene;

#import "cocos2d.h"

@protocol Box2dCollisionProtocol
-(void) beginContact:(b2Contact*) contact;
-(void) endContact:(b2Contact*) contact;
-(void) preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*) oldManifold;
-(void) postSolveContact:(b2Contact*)contact impulse:(const b2ContactImpulse*) impulse;
@end

enum {
	//BN_PREFERRED_PARENT_SPRITES_PNG,
	BN_PREFERRED_PARENT_PLATFORMS_PNG,
	BN_PREFERRED_PARENT_MARBLES_PNG,
	BN_PREFERRED_PARENT_IGNORE,
};

enum {
	BN_CONTACT_NONE = 0,
	BN_CONTACT_BEGIN = 1 << 0,
	BN_CONTACT_END = 1 << 1,
	BN_CONTACT_PRESOLVE = 1 << 2,
	BN_CONTACT_POSTSOLVE = 1 << 3,
	BN_CONTACT_ALL = BN_CONTACT_BEGIN | BN_CONTACT_END | BN_CONTACT_PRESOLVE | BN_CONTACT_POSTSOLVE,
};

enum {
	BN_PROPERTY_NONE = 0,
	BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS = 1 << 0,
};

// box2d filtering
enum {
	kCollisionFilterGroupIndexEnemy = 1 << 0,
	kCollisionFilterGroupIndexHero = 1 << 1,
};

/** A CocosNode that links a b2Body with the cocos2d world.
 It also receives contact callbacks.
 If you move this node, it will move the box2d body.
 For example, you can apply actions to this node.
 
 IMPORTANT: In order to move the b2 body using actions, the body must be "kinematic" or "static" type.
 */
@interface BZBodyNode : CCSprite <Box2dCollisionProtocol> {

	// weak ref to box2d body
	b2Body			*body_;
	
	// weak ref to BZLevelScene
	//GameNode		*game_;
	BZLevelScene		*game_;

	// report contacts
	unsigned int	reportContacts_;
	
	// is this node touchable
	BOOL			isTouchable_;	
	
	// preferred parent (helper)
	int				preferredParent_;

	// TIP:
	// Are you going to access an ivar many times per step ?
	// To impromve the performance you can make it public, or compile the accessor method
@public
	// properties:
	unsigned int	properties_;
}

/** box2d body */
@property (readwrite, nonatomic, assign) b2Body *body;

/** contacts that will receive. None by default */
@property (readwrite, nonatomic) unsigned int reportContacts;

/** is this node touchable ? */
@property (readwrite, nonatomic) BOOL isTouchable;

/** prefered parent for the node */
@property (readwrite,nonatomic) int preferredParent;

/** properties of the node */
//@property (readonly, nonatomic) unsigned int properties;
// why was this readonly? We'd like to change it whilst doing animation, like resetting heroball
@property (readwrite, nonatomic) unsigned int properties;


/** initializes the node with a box2d body */
//-(id) initWithBody:(b2Body*)body game:(BZLevelScene*)game;
//-(id) initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game;
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game;

/** destroy all fixtures from body */
-(void) destroyAllFixturesFromBody:(b2Body*)body;

/** the possibility to customize the node using SVG
 @since v2.4
 */
-(void) setParameters:(NSDictionary*)params;

// moving at a non-trivial rate?
- (BOOL)isMoving;

// covering a point?
- (BOOL)coversPoint:(b2Vec2)point;

@end

// protocols
@protocol BZBodyNodeBulletProtocol
-(void) touchedByBullet:(id)bullet;
@end

