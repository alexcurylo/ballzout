//
//  BZLevelScene.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"

#import "GLES-Render.h"
#import "Box2DCallbacks.h"
#import "BZLevelConstants.h"

// forward declarations
@class BZLevelHUD;
@class BZBall;
@class BZHeroball;
@class BZBodyNode;
//@class BodyNode;
//@class BonusNode;

// game state
typedef enum
{
	kGameStatePaused,
	kGameStatePlaying,
	kGameStateGameOver,
} GameState;


// HelloWorld Layer
@interface BZLevelScene : CCLayer
{
	// box2d world
	b2World		*world_;
	
	// game state
	GameState		gameState_;
	
	// the camera will be centered on the Hero
	// If you want to move the camera, you should move this value
	CGPoint		cameraOffset_;
	
	// game scores
	unsigned int	score_;
	// game lives
	unsigned int	lives_;
	
	// Hero weak ref
	//Hero	*hero_;
	NSMutableArray *heroballs_;
   NSMutableArray *targetballs_;
   
	// BZLevelHUD weak ref
	BZLevelHUD		*hud_;

	// Box2d: Used when dragging objects
	b2MouseJoint	* mouseJoint_;
	b2Body			* mouseStaticBody_;
	
	// box2d callbacks
	// In order to compile on SDK 2.2.x or older, they have to be pointers
	MyContactFilter			*m_contactFilter;
	MyContactListener		*m_contactListener;
	MyDestructionListener	*m_destructionListener;	
	
	// box2d iterations. Can be configured by each level
	int	worldPositionIterations_;
	int worldVelocityIterations_;
	
	// BZLevelScene is responsible for removing "removed" nodes
	unsigned int nukeCount;
	b2Body* nuke[kMaxNodesToBeRemoved];	

// stuff that was in the LevelX subclasses
	CCSpriteBatchNode *spritesBatchNode_;
	CCSpriteBatchNode *platformBatchNode_;

	CCSpriteBatchNode *marblesBatchNode_;
}

/** Box2d World */
@property (readwrite,nonatomic) b2World *world;

/** score of the game */
@property (readonly,nonatomic) unsigned int score;

/** lives of the hero */
@property (readonly,nonatomic) unsigned int lives;

/** game state */
@property (readonly,nonatomic) GameState gameState;

/** weak ref to hero */
//@property (readwrite,nonatomic,assign) Hero *hero;
@property (readwrite,nonatomic, retain) NSMutableArray *heroballs;
@property (readwrite,nonatomic, retain) NSMutableArray *targetballs;

/** weak ref to BZLevelHUD */
@property (readwrite, nonatomic, assign) BZLevelHUD *hud;

/** offset of the camera */
@property (readwrite,nonatomic) CGPoint cameraOffset;

// returns a Scene that contains the GameLevel and a BZLevelHUD
+(id) scene;

// initialize game with level
-(id) init;

- (void)cleanLevel;
- (void)layoutLevel;
- (void)createHeroballs;
- (b2Vec2)heroballSlot:(NSInteger)idx;
- (void)addHeroball:(BZHeroball *)heroball;
- (void)removeHeroball:(BZHeroball *)heroball;
- (void)resetHeroball:(BZHeroball *)heroball;
- (BZHeroball *)readyHeroball;

- (void)addTargetball:(BZBall *)targetball;
- (void)removeTargetball:(BZBall *)targetball;

/** returns the SVGFileName to be loaded */
- (NSString *)SVGFileName;

// mouse (touches)
-(BOOL) mouseDown:(b2Vec2)p;
-(void) mouseMove:(b2Vec2)p;
-(void) mouseUp:(b2Vec2)p;

// game events
-(void) gameOver;
-(void) increaseScore:(int)score;
-(void) increaseLife:(int)lives;

// creates the foreground and background graphics
-(void) initGraphics;

// adds the BodyNode to the scene graph
-(void) addBodyNode:(BZBodyNode*)node z:(int)zOrder;

// schedule a b2Body to be removed
-(void) removeB2Body:(b2Body*)body;

// returns the content Rectangle of the Map
-(CGRect) contentRect;
@end
