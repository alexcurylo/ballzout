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
#import "BZLevelHUD.h"
#import "BZLevelConstants.h"
#import "SVGParser.h"
#import "Box2DCallbacks.h"
#if SHOW_PHYSICS
#import "Box2dDebugDrawNode.h"
#endif SHOW_PHYSICS
#import "BZHeroball.h"

//#import "BodyNode.h"
//#import "Hero.h"
//#import "HeroRound.h"
//#import "HeroBox.h"
//#import "BonusNode.h"
//#import "Bullet.h"


@interface BZLevelScene ()
-(void) initPhysics;
-(void) initGraphics;
-(void) updateSprites;
-(void) updateCamera;
-(void) updateGame;
- (void)destroyB2Body:(b2Body *)body;
-(void) removeB2Bodies;

-(void) physicsCallbackWithBody:(b2Body*)body attribs:(NSString*)gameAttribs;

@end

// HelloWorld implementation
@implementation BZLevelScene

@synthesize world=world_;
@synthesize score=score_;
@synthesize lives=lives_;
@synthesize gameState=gameState_;
//@synthesize hero=hero_;
@synthesize heroballs=heroballs_;
@synthesize targetballs=targetballs_;
@synthesize hud=hud_;
@synthesize cameraOffset=cameraOffset_;

#pragma mark BZLevelScene -Initialization

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'game' is an autorelease object.
	BZLevelScene *game = [self node];

	// BZLevelHUD
	BZLevelHUD *hud = [BZLevelHUD BZLevelHUDWithLevelScene:game];
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
	if( (self=[super init]))
   {
		// enable touches
		self.isTouchEnabled = YES;
		
		score_ = 0;
		lives_ = 3;
		//hero_ = nil;
      heroballs_ = [[NSMutableArray array] retain];
      targetballs_ = [[NSMutableArray array] retain];
		
		// game state
		gameState_ = kGameStatePaused;
		
		// camera
		cameraOffset_ = CGPointZero;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		//CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// init box2d physics
		[self initPhysics];
		
		// Init graphics
		[self initGraphics];
		
		// Box2d iterations default values
		worldVelocityIterations_ = 6;
		worldPositionIterations_ = 1;
		
		// nodes to be removed
		nukeCount = 0;
      
      [self layoutLevel];

		[self scheduleUpdateWithPriority:0];
	}
	return self;
}

- (void)cleanLevel
{
   [self.heroballs removeAllObjects];
   [self.targetballs removeAllObjects];
   [self.hud hideActiveRing];
   
   b2Body *bodyList = self.world->GetBodyList();
   while (bodyList)
   {
      b2Body *thisBody = bodyList;
      bodyList = thisBody->GetNext();
      [self destroyB2Body:thisBody];
   }
   
   for (int i = 0; i < kMaxNodesToBeRemoved; i++)
      nuke[i] = nil;
   nukeCount = 0;
}

- (void)layoutLevel
{
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
   
   [self createHeroballs];
}

- (void)createHeroballs
{
   twcheck(!self.heroballs.count);
   
   for (int i = 0; i < kLevelHeroballCount; i++)
   {
		BZHeroball *heroball = [[[BZHeroball alloc] initWithPosition:[self heroballSlot:i] gameScene:self] autorelease];
      [self addBodyNode:heroball z:0];
   }
}

- (b2Vec2)heroballSlot:(NSInteger)idx
{
   float segmentWidth = kLevelWidth / (kLevelHeroballCount + 1);
   b2Vec2 where(
      (segmentWidth * (idx + 1)) / kPhysicsPTMRatio,
      kLevelHeroballY / kPhysicsPTMRatio
   );
   return where;
}

- (void)addHeroball:(BZHeroball *)heroball
{
   [self.heroballs addObject:heroball];
}

- (void)removeHeroball:(BZHeroball *)heroball
{
   [self.heroballs removeObject:heroball];
   
   /* doing this while removing the last hero isn't a good idea; move to -updateGame
   if (!self.heroballs.count)
   {
      [self increaseLife:-1];
      if (kGameStateGameOver != gameState_)
      {
         [self cleanLevel];
         [self layoutLevel];
      }
   }
    */
}

- (void)resetHeroball:(BZHeroball *)heroball
{
   // removed already?
   if (NSNotFound == [self.heroballs indexOfObject:heroball])
      return;

   // in motion?
   if (heroball.inMotion)
      return;
   
   // on any of the slots?
   b2Vec2 emptySlot;
   BOOL emptySlotReady = NO;
   for (int i = 0; i < kLevelHeroballCount; i++)
   {
      b2Vec2 slot = [self heroballSlot:i];
      /*
       //b2AABB aabb; QueryAABB??
      b2Fixture* heroballFixture = ballBody->GetFixtureList();
      twcheck(!heroballFixture->GetNext());
      if (heroballFixture->TestPoint(slot))
         return;
      */
      if ([heroball coversPoint:slot])
         return;
      
      // need an empty slot?
      // Actually, should check length for each to hit the *closest* empty slot
      if (!emptySlotReady)
      {
         BOOL slotFilled = NO;
         for (BZHeroball* ball in self.heroballs)
         {
            if (ball == heroball)
               continue;
            /*
            b2Fixture* ballFixture = ballBody->GetFixtureList();
            twcheck(!ballFixture->GetNext());
            if (ballFixture->TestPoint(slot))
             */
            if ([ball coversPoint:slot])
            {
               slotFilled = YES;
               break;
            }
         }
         if (!slotFilled)
         {
            emptySlot = slot;
            emptySlotReady = YES;
         }
      }
   }
   
   twcheck(emptySlotReady);
   // ideally, it would move like in MythicMarbles, and to closest not first empty
   b2Body *ballBody = heroball.body;
   ballBody->SetLinearVelocity(b2Vec2());
   ballBody->SetAngularVelocity(0);
	ballBody->SetTransform(emptySlot, 0);

   if (heroball.isHero)
      [self.hud showActiveRing:emptySlot];
}

- (BZHeroball *)readyHeroball
{
   BZHeroball *hero = nil;
   
   if (kGameStatePlaying == self.gameState)
      for (BZHeroball* ball in self.heroballs)
      {
         if (ball.isHero)
         {
             if (ball.inMotion)
                return nil;
            return ball;
         }
         
         // hero will be first nonhero one, if any
         if (!hero)
            hero = ball;
      }
   
   hero.isHero = YES;
   return hero;
}

- (void)addTargetball:(BZBall *)targetball
{
   (void)targetball;
   
   [self.targetballs addObject:targetball];
}

- (void)removeTargetball:(BZBall *)targetball
{
   [self.targetballs removeObject:targetball];

   // check on update when there's a ready ball, which should be after last one gets set
   //if (1 > targetballs_)
      //[self gameOver];
};

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	gameState_ = kGameStatePlaying;
	
	//CGRect rect = [self contentRect];
	//CCFollow *action = [CCFollow actionWithTarget:hero_ worldBoundary:rect];
	//[self runAction:action];
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
   
#if SHOW_PHYSICS
#warning showing physics
  // TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
	[self addChild:b2node z:20];
#endif SHOW_PHYSICS
   
   // batchnodes: platforms should be drawn before sprites
	[self addChild:platformBatchNode_ z:1];
	[self addChild:spritesBatchNode_ z:2];
   [self addChild:marblesBatchNode_ z:3];

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
	
   twrelease(heroballs_);
   twrelease(targetballs_);
   
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
	// BZLevelHUD (dragging screen): 100
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kPriorityShoot swallowsTouches:YES];
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
	//[self updateCamera];
   
   // check to see if level is done
	[self updateGame];
}

- (void)removeB2Body:(b2Body*)body
{
   twcheck(body);
	NSAssert( nukeCount < kMaxNodesToBeRemoved, @"LevelSVG: Increase the kMaxNodesToBeRemoved in GameConstants.h");

	nuke[nukeCount++] = body;
	
}

- (void)destroyB2Body:(b2Body *)body
{
   twcheck(body);
  // IMPORTANT: don't alter the order of the following commands, or it might crash.
   
   // 1. obtain a weak ref to the BodyNode
   BZBodyNode *node = (BZBodyNode*) body->GetUserData();
   
   // 2. destroy the b2body
   world_->DestroyBody(body);
   
   // 3. set the the body to NULL
   [node setBody:NULL];
   
   // 4. remove BodyNode
   [node removeFromParentAndCleanup:YES];
}

- (void)removeB2Bodies
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

      [self destroyB2Body:b];
	}
	
	nukeCount = 0;
}

-(void)updateCamera
{
   /*
	if( hero_ ) {
		CGPoint pos = position_;

		[self setPosition:ccp(pos.x+cameraOffset_.x,pos.y+cameraOffset_.y)];
	}
    */
}

- (void)updateGame
{
   if (!self.heroballs.count)
   {
      [self increaseLife:-1];
      if (kGameStateGameOver != gameState_)
      {
         [self cleanLevel];
         [self layoutLevel];
      }
      return;
   }
   
   if (!self.readyHeroball)
      // still moving, might go offscreen
      return;
   
   // all balls off? We win then
   if (1 > self.targetballs.count)
      [self gameOver];
   
   // need to show the ready ball?
   if (!self.hud.showingActiveRing)
   {
      BZHeroball *hero = self.readyHeroball;
      if (hero)
         [self.hud showActiveRing:hero.body->GetPosition()];
   }
}

-(void) updateSprites
{
	for (b2Body* b = world_->GetBodyList(); b; b = b->GetNext())
	{
		BZBodyNode *node = (BZBodyNode*) b->GetUserData();
		
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

	BZBodyNode *node = nil;

	for( NSString *propertyValue in nse )
   {
		NSArray *arr = [propertyValue componentsSeparatedByString:@"="];
		NSString *key = [arr objectAtIndex:0];
		NSString *value = [arr objectAtIndex:1];

		key = [key lowercaseString];
	
		if( [key isEqualToString:@"object"] )
      {
			NSString *classname = [@"BZ" stringByAppendingString:[value capitalizedString]];
			Class klass = NSClassFromString( classname );
		
			if( klass ) {
				// The BodyNode will be added to the scene graph at init time
				node = [[klass alloc] initWithBody:body gameScene:self];
				
				[self addBodyNode:node z:0];
				[node release];					
			} else {
				CCLOG(@"BZLevelScene: WARNING: Don't know how to create class: %@", classname);
			}

		}
      else if( [key isEqualToString:@"objectparams"] )
      {
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

		}
      else
			NSLog(@"Game Scene callback: unrecognized key: %@", key);
	}
}

// This is the default behavior
-(void) addBodyNode:(BZBodyNode*)node z:(int)zOrder
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
	//twlog("BZLevelSceme ccTouchBegan pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
	
	return [self mouseDown: b2Vec2(nodePosition.x / kPhysicsPTMRatio ,nodePosition.y / kPhysicsPTMRatio)];	
}

- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)event;
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
   //twlog("BZLevelScene ccTouchMoved pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);

	[self mouseMove:b2Vec2(nodePosition.x/kPhysicsPTMRatio,nodePosition.y/kPhysicsPTMRatio)];
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)event;
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
   //twlog("BZLevelScene ccTouchEnded pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
	
	[self mouseUp: b2Vec2(nodePosition.x/kPhysicsPTMRatio,nodePosition.y/kPhysicsPTMRatio)];
}

- (void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event
{
   (void)touch;
   (void)event;
   twlog("BZLevelScene ccTouchCancelled!!");
	[self ccTouchEnded:touch withEvent:event];
}

#pragma mark BZLevelScene - Touches (Mouse simulation)

//
// mouse code based on Box2d TestBed example: http://www.box2d.org
//

// 'button' is being pressed.
// Attach a mouseJoint if we are touching a box2d body
-(BOOL) mouseDown:(b2Vec2) p
{
   // do nothing unless actively playing
   
   if (kGameStatePlaying != self.gameState)
      return NO;
   
   // is it trying to select a heroball?
   
   for (BZHeroball *ball in self.heroballs)
   {
      if (![ball coversPoint:p])
         continue;
    
      // can't select a moving heroball
      if (ball.inMotion)
         return NO;
      
      // selecting current one is redundant
      if (ball.isHero)
         return NO;
      
      // ok, unhero current (if any) and heroize this one
      for (BZHeroball *unhero in self.heroballs)
         unhero.isHero = NO;
      ball.isHero = YES;
      [self.hud hideActiveRing];
      // next update should show correct ring
      return NO;
   }   
   
   // ok, it's an attempted targeting; see if there's a heroball to target with
   
   BZHeroball *ball = self.readyHeroball;
   if (!ball)
   {
      twlog("no heroball ready!");
      return NO;
   }
   
   return YES;
   
   /*
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
		BZBodyNode *node = (BZBodyNode*) body->GetUserData();
		if( node && node.isTouchable )
      {
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
    */
}

//
// The mouse is moving: drag the mouseJoint
- (void)mouseMove:(b2Vec2)p
{	
   (void)p;
/*
 if (mouseJoint_)
		mouseJoint_->SetTarget(p);
*/
}

//
// 'button' is not being pressed any more. Destroy the mouseJoint
//
// Shoot the heroball!
//
- (void)mouseUp:(b2Vec2)targetPosition
{
   BZHeroball *ball = self.readyHeroball;
   if (!ball)
   {
      twlog("no heroball ready!");
      return;
   }
   
   [self.hud hideActiveRing];
   
   // direction from
   // http://www.box2d.org/forum/viewtopic.php?f=3&t=5590&start=10

   b2Vec2 ballPosition = ball.body->GetWorldCenter();
   b2Vec2 direction = targetPosition - ballPosition;
   float length = direction.Normalize();
   if (!(length > 0))
   {
      twlog("length to target is 0!");
      return;
   }
   
   // other interesting links
   // http://stackoverflow.com/questions/3382232/box2dapply-velocity-in-a-direction
   // http://www.cocos2d-iphone.org/forum/topic/6719
   // http://board.flashkit.com/board/showthread.php?t=805417
   // http://box2d.org/forum/viewtopic.php?f=8&t=4519&hilit=normal+vector
   //b2Vec2 impulseUp(0, shootForce);  // this is straight up
   
   float shootForce = self.hud.shootForce;
   
   b2Vec2 impulse(direction);
   impulse *= shootForce;
   ball.body->ApplyLinearImpulse(impulse, ballPosition );

   /*
	if (mouseJoint_)
	{
		world_->DestroyJoint(mouseJoint_);
		mouseJoint_ = NULL;
	}
    */
}


@end
