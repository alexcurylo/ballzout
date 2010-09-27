//
//  BZLevelScene.mm
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//


//
// This class implements the game logic like:
//
//	- scores
//	- lives
//	- updates the Box2d world
//  - object creation
//  - renders background and sprites
//  - register touch event: supports dragging box2d's objects
//

//
// Level2:
//
// Details:
//
// It uses 2 batch nodes:
//
//  * 1 batch node for the sprites
//  * 1 batch node for the platorms
//
// Why ?
// Becuase the platforms uses a different a different texture parameter
// When you using batch nodes, all the sprites MUST share the same texture and the same texture parameters
//
// TIP:
// The platforms used in this level uses the GL_REPEAT texture parameter.
// If you open the platforms.png file, you will notice the both images are 128x128. This is on purpose. You can't add more images horizontally.
// But you can add more images vertically... (only if the platforms are not higher than 128 pixels).
//
// It also uses a Parallax with 3 children:
//  - background image
//  - platforms
//  - sprites (hero, fruits, princess, etc)
//
//
// How to create a similar level ?
//	1. Open Inkscape and create a new document of 480x320. Actually it can be of any size, but it is useful as a reference.
//		-> Inkscape -> File -> Document Properties -> Custom size: width=480, height=320
//	2. Create 1 layer:
//		-> physics:objects
//	3. Start designing the world.
//
// IMPORTANT: gravity and controls are read from the svg file
//


// sound imports
#import "SimpleAudioEngine.h"

// Import the interfaces
#import "BZLevelScene.h"
#import "BallZOutAppDelegate.h"

#import "SVGParser.h"
#import "GameConstants.h"
#import "Box2DCallbacks.h"
#import "GameConfiguration.h"
#import "HUD.h"
#import "BodyNode.h"
#import "Hero.h"
#import "HeroRound.h"
#import "HeroBox.h"
#import "Box2dDebugDrawNode.h"
#import "BonusNode.h"
#import "Bullet.h"


@interface BZLevelScene ()
-(void) initPhysics;
-(void) initGraphics;
-(void) updateSprites;
-(void) updateCamera;
-(void) removeB2Bodies;

-(void) physicsCallbackWithBody:(b2Body*)body attribs:(NSString*)gameAttribs;

@end

// HelloWorld implementation
@implementation BZLevelScene

@synthesize world=world_;
@synthesize score=score_, lives=lives_;
@synthesize gameState=gameState_;
@synthesize hero=hero_;
@synthesize hud=hud_;
@synthesize cameraOffset=cameraOffset_;

#pragma mark BZLevelScene -Initialization

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'game' is an autorelease object.
	BZLevelScene *game = [self node];

	// HUD
#warning fix up game calls to this
	HUD *hud = [HUD HUDWithGameNode:nil];
	[scene addChild:hud z:10];
	
	// link gameScene with HUD
	game.hud = hud;
	
	// add game as a child to scene
	[scene addChild: game];
	
	// return the scene
	return scene;
}


// initialize your instance here
-(id) init
{
	if( (self=[super init])) {

		// enable touches
		self.isTouchEnabled = YES;
		
		score_ = 0;
		lives_ = 5;
		hero_ = nil;
		
		// game state
		gameState_ = kGameStatePaused;
		
		// camera
		cameraOffset_ = CGPointZero;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// init box2d physics
		[self initPhysics];
		
		// Init graphics
		[self initGraphics];
		
		// default physics settings
		SVGParserSettings settings;
		settings.defaultDensity = kPhysicsDefaultDensity;
		settings.defaultFriction = kPhysicsDefaultFriction;
		settings.defaultRestitution = kPhysicsDefaultRestitution;
		settings.PTMratio = kPhysicsPTMRatio;
		settings.defaultGravity = ccp( kPhysicsWorldGravityX, kPhysicsWorldGravityY );
		settings.bezierSegments = kPhysicsDefaultBezierSegments;
		
		// create box2d objects from SVG file in world
		[SVGParser parserWithSVGFilename:[self SVGFileName] b2World:world_ settings:&settings target:self selector:@selector(physicsCallbackWithBody:attribs:)];	

		// Box2d iterations default values
		worldVelocityIterations_ = 6;
		worldPositionIterations_ = 1;
		
		// nodes to be removed
		nukeCount = 0;

		[self scheduleUpdateWithPriority:0];
	}
	return self;
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	gameState_ = kGameStatePlaying;
	
	CGRect rect = [self contentRect];
	CCFollow *action = [CCFollow actionWithTarget:hero_ worldBoundary:rect];
	[self runAction:action];
}

-(void) initGraphics
{
	//CCLOG(@"LevelSVG: BZLevelScene#initGraphics: override me");
   
   // sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	// platforms
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
	// marbles
   [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"marbles.plist"];

	//
	// TIP
	// Use 16-bit texture in background. It consumes half the memory
	//
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	//CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
	//CCSprite *background = [CCSprite spriteWithFile:@"arena1.jpg"];
	CCSprite *background = [CCSprite spriteWithFile:BZCurrentGame().backgroundFileName];
	background.anchorPoint = ccp(0,0);
   //background.position = ccp(size.width/2, size.height/2);
   
	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	
	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	
   // weak ref
	marblesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"marbles.png" capacity:20];

	// weak ref
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[platformBatchNode_.texture setTexParameters:&params];
	
	//
	// Parallax Layers
	//
   /*
    CCParallaxNode *parallax = [CCParallaxNode node];
    
    // background is parallaxed
    [parallax addChild:background z:-10 parallaxRatio:ccp(0.08f, 0.08f) positionOffset:ccp(-30,-30)];
    
    // TIP: Disable this node in release mode
    // Box2dDebug draw in front of background
    Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
    [parallax addChild:b2node z:0 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
    
    // batchnodes: platforms should be drawn before sprites
    [parallax addChild:platformBatchNode_ z:5 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
    [parallax addChild:spritesBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
    
    [self addChild:parallax];
    */
   
   [self addChild:background z:-10];
   
   // TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
	[self addChild:b2node z:0];
   
   // batchnodes: platforms should be drawn before sprites
	[self addChild:platformBatchNode_ z:3];
	[self addChild:spritesBatchNode_ z:6];
   [self addChild:marblesBatchNode_ z:9];

   [self setContentSize:[background contentSize]];   
}

-(NSString*) SVGFileName
{
	//CCLOG(@"LevelSVG: BZLevelScene:SVGFileName: override me");
	//return nil;
   
   return BZCurrentGame().levelFileName;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	
	// physics stuff
	if( world_ )
		delete world_;
	
	// delete box2d callback objects
	if( m_contactListener )
		delete m_contactListener;
	if( m_contactFilter )
		delete m_contactFilter;
	if( m_destructionListener )
		delete m_destructionListener;
	
	// don't forget to call "super dealloc"
	[super dealloc];	
}

-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// BZLevelScene (dragging objects): 50
	// HUD (dragging screen): 100
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:50 swallowsTouches:YES];
}

-(void) initPhysics
{
	// Define the gravity vector.
	b2Vec2 gravity;
	//gravity.Set(0.0f, -10.0f);
	gravity.Set(kPhysicsWorldGravityX, kPhysicsWorldGravityY);
	
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = true;
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world_ = new b2World(gravity, doSleep);
	
	world_->SetContinuousPhysics(true);
	
	// contact listener
	m_contactListener = new MyContactListener();
	world_->SetContactListener( m_contactListener );
	
	// contact filter
//	m_contactFilter = new MyContactFilter();
//	world_->SetContactFilter( m_contactFilter );
	
	// destruction listener
	m_destructionListener = new MyDestructionListener();
	world_->SetDestructionListener( m_destructionListener );
	
	// init mouse stuff
	mouseJoint_ = NULL;
	b2BodyDef	bodyDef;
	mouseStaticBody_ = world_->CreateBody(&bodyDef);	
}

- (CGRect)contentRect
{
	//NSLog(@"BZLevelScene#contentRect");
	//NSAssert( NO, @"You override this method in your Level class. It should return the rect that contains your map");
	//return CGRectMake(0,0,0,0);

	// These values were obtained from Inkscape -- the size of the "dimensions" object
	//return CGRectMake(-313, -120, 1240, 464);
	return CGRectMake(0, 0, 320, 480);
}

#pragma mark BZLevelScene - MainLoop

-(void) update: (ccTime) dt
{
	// Only step the world if status is Playing or GameOver
	if( gameState_ != kGameStatePaused ) {
		
		//It is recommended that a fixed time step is used with Box2D for stability
		//of the simulation, however, we are using a variable time step here.
		//You need to make an informed choice, the following URL is useful
		//http://gafferongames.com/game-physics/fix-your-timestep/
		
		// Instruct the world to perform a single step of simulation. It is
		// generally best to keep the time step and iterations fixed.
		world_->Step(dt, worldVelocityIterations_, worldPositionIterations_ );
	}

	// removed box2d bodies scheduled to be removed
	[self removeB2Bodies];
	 
	// update cocos2d sprites from box2d world
	[self updateSprites];
	
	// update camera
	[self updateCamera];

}

-(void) removeB2Body:(b2Body*)body
{
	NSAssert( nukeCount < kMaxNodesToBeRemoved, @"LevelSVG: Increase the kMaxNodesToBeRemoved in GameConstants.h");

	nuke[nukeCount++] = body;
	
}

-(void) removeB2Bodies
{
	// Sort the nuke array to group duplicates.
	std::sort(nuke, nuke + nukeCount);
	
	// Destroy the bodies, skipping duplicates.
	unsigned int i = 0;
	while (i < nukeCount)
	{
		b2Body* b = nuke[i++];
		while (i < nukeCount && nuke[i] == b)
		{
			++i;
		}

		// IMPORTANT: don't alter the order of the following commands, or it might crash.
		
		// 1. obtain a weak ref to the BodyNode
		BodyNode *node = (BodyNode*) b->GetUserData();
		
		// 2. destroy the b2body
		world_->DestroyBody(b);

		// 3. set the the body to NULL
		[node setBody:NULL];
		
		// 4. remove BodyNode
		[node removeFromParentAndCleanup:YES];

		
	}
	
	nukeCount = 0;
}

-(void) updateCamera
{
	if( hero_ ) {
		CGPoint pos = position_;

		[self setPosition:ccp(pos.x+cameraOffset_.x,pos.y+cameraOffset_.y)];
	}
}

-(void) updateSprites
{
	for (b2Body* b = world_->GetBodyList(); b; b = b->GetNext())
	{
		BodyNode *node = (BodyNode*) b->GetUserData();
		
		//
		// Only update sprites that are meant to be updated by the physics engine
		//
		if( node && (node->properties_ & BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS) ) {
			//Synchronize the sprites' position and rotation with the corresponding body
			b2Vec2 pos = b->GetPosition();
			node.position = ccp( pos.x * kPhysicsPTMRatio, pos.y * kPhysicsPTMRatio);
			if( ! b->IsFixedRotation() )
				node.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}	
}

-(void) gameOver
{
	gameState_ = kGameStateGameOver;
	[hud_ displayMessage:@"You Won!"];
}

-(void) increaseLife:(int)lives
{
	lives_ += lives;
	[hud_ onUpdateLives:lives_];
	
	if( lives < 0 && lives_ == 0 ) {
		gameState_ = kGameStateGameOver;
		[hud_ displayMessage:@"Game Over"];
	}
}

-(void) increaseScore:(int)score
{
	score_ += score;
	[hud_ onUpdateScore:score_];
}

#pragma mark BZLevelScene - Box2d Callbacks

// will be called for each created body in the parser
-(void) physicsCallbackWithBody:(b2Body*)body attribs:(NSString*)gameAttribs
{
	NSArray *values = [gameAttribs componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];

	
	BodyNode *node = nil;

	for( NSString *propertyValue in nse ) {
		NSArray *arr = [propertyValue componentsSeparatedByString:@"="];
		NSString *key = [arr objectAtIndex:0];
		NSString *value = [arr objectAtIndex:1];

		key = [key lowercaseString];
	
		if( [key isEqualToString:@"object"] ) {
			
			value = [value capitalizedString];
			Class klass = NSClassFromString( value );
		
			if( klass ) {
				// The BodyNode will be added to the scene graph at init time
#warning fix up game calls to this
				node = [[klass alloc] initWithBody:body game:nil];
				
				[self addBodyNode:node z:0];
				[node release];					
			} else {
				CCLOG(@"BZLevelScene: WARNING: Don't know how to create class: %@", value);
			}

		} else if( [key isEqualToString:@"objectparams"] ) {
			// Format of parameters:
			// objectParams=direction:vertical;target:1;visible:NO;
			NSDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
			NSArray *params = [value componentsSeparatedByString:@";"];
			for( NSString *param in params) {
				NSArray *keyVal = [param componentsSeparatedByString:@":"];
				[dict setValue:[keyVal objectAtIndex:1] forKey:[keyVal objectAtIndex:0]];
			}
			[node setParameters:dict];
			[dict release];

		} else
			NSLog(@"Game Scene callback: unrecognized key: %@", key);
	}
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
   //(void)node;
   //(void)zOrder;
	//CCLOG(@"LevelSVG: BZLevelScene#addBodyNode override me");

	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
         
			// Add to sprites' batch node
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
         
		case BN_PREFERRED_PARENT_PLATFORMS_PNG:
			// Add to platform batch node
			[platformBatchNode_ addChild:node z:zOrder];
			break;
			
		case BN_PREFERRED_PARENT_MARBLES_PNG:
			// Add to platform batch node
			[marblesBatchNode_ addChild:node z:zOrder];
			break;
			
		default:
			CCLOG(@"addBodyNode: Unknonw preferred parent");
			break;
	}
}

#pragma mark BZLevelScene - Touch Events Handler

- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)event;
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	//	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
	
	return [self mouseDown: b2Vec2(nodePosition.x / kPhysicsPTMRatio ,nodePosition.y / kPhysicsPTMRatio)];	
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)event;
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	
	[self mouseMove: b2Vec2(nodePosition.x/kPhysicsPTMRatio,nodePosition.y/kPhysicsPTMRatio)];
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)event;
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	
	[self mouseUp: b2Vec2(nodePosition.x/kPhysicsPTMRatio,nodePosition.y/kPhysicsPTMRatio)];
}

#pragma mark BZLevelScene - Touches (Mouse simulation)

//
// mouse code based on Box2d TestBed example: http://www.box2d.org
//

// 'button' is being pressed.
// Attach a mouseJoint if we are touching a box2d body
-(BOOL) mouseDown:(b2Vec2) p
{
	bool ret = false;
	
	if (mouseJoint_ != NULL)
		return false;
	
	// Make a small box.
	b2AABB aabb;
	b2Vec2 d;
	d.Set(0.001f, 0.001f);
	aabb.lowerBound = p - d;
	aabb.upperBound = p + d;
	
	// Query the world for overlapping shapes.
	MyQueryCallback callback(p);
	world_->QueryAABB(&callback, aabb);

	// only return yes if the fixture is touchable.
	if (callback.m_fixture )
	{
		b2Body *body = callback.m_fixture->GetBody();
		BodyNode *node = (BodyNode*) body->GetUserData();
		if( node && node.isTouchable ) {
			//
			// Attach touched body to static body with a mouse joint
			//
			body = callback.m_fixture->GetBody();
			b2MouseJointDef md;
			md.bodyA = mouseStaticBody_;
			md.bodyB = body;
			md.target = p;
			md.maxForce = 1000.0f * body->GetMass();
			mouseJoint_ = (b2MouseJoint*) world_->CreateJoint(&md);
			body->SetAwake(true);
			
			ret = true;
		}
	}
	
	return ret;
}

//
// 'button' is not being pressed any more. Destroy the mouseJoint
//
-(void) mouseUp:(b2Vec2)p
{
   (void)p;
	if (mouseJoint_)
	{
		world_->DestroyJoint(mouseJoint_);
		mouseJoint_ = NULL;
	}	
}

//
// The mouse is moving: drag the mouseJoint
-(void) mouseMove:(b2Vec2)p
{	
	if (mouseJoint_)
		mouseJoint_->SetTarget(p);
}
@end
