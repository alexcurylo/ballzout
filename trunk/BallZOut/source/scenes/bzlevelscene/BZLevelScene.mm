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
#import "BZSimpleButton.h"
#import "BZMainScene.h"
#import "BZScoreScene.h"

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
//@synthesize score=score_;
//@synthesize lives=lives_;
@synthesize levelState=levelState_;
//@synthesize hero=hero_;
@synthesize heroballs=heroballs_;
@synthesize targetballs=targetballs_;
@synthesize obstacles=obstacles_;
@synthesize hud=hud_;
@synthesize cameraOffset=cameraOffset_;

#pragma mark -
#pragma mark Life cycle

+ (id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'game' is an autorelease object.
   // note that this may actually be a BZInstructions scene!
	BZLevelScene *game = [self node];
   // do this after init so tutorial game has a chance to get created
   [game setupLevel];

	// BZLevelHUD
	BZLevelHUD *hud = [BZLevelHUD BZLevelHUDWithLevelScene:game];
	//[scene addChild:hud z:10];
   [game addChild:hud z:50];

	// link gameScene with HUD
	game.hud = hud;
	
	// add game as a child to scene
	[scene addChild: game];
	
	// return the scene
	return scene;
}


// initialize your instance here
- (id)init
{
	if ( (self = [super init]) )
   {
      // setup moved to -setupLevel so instructions has a chance to create tutorial game
	}
   
	return self;
}

- (void)setupLevel
{
   [self.game levelBegin];
   
   // enable touches
   self.isTouchEnabled = YES;
   
   //score_ = 0;
   //lives_ = 3;
   //hero_ = nil;
   heroballs_ = [[NSMutableArray array] retain];
   targetballs_ = [[NSMutableArray array] retain];
   obstacles_ = [[NSMutableArray array] retain];
   
   // game state
   levelState_ = kLevelStatePaused;
   
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

#pragma mark -
#pragma mark Playing vs. Tutorial accessors

- (BZGame *)game
{
   return BZCurrentGame();
}

- (BOOL)userPlaying
{
   return kLevelStatePlaying == self.levelState;
}

#pragma mark -
#pragma mark - Operations

/*
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
*/

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
   [SVGParser parserWithSVGFilename:[self SVGFileName]
      b2World:world_
      settings:&settings
      target:self
      selector:@selector(physicsCallbackWithBody:attribs:)
    ];	
   
   [self createHeroballs];
}

- (void)createHeroballs
{
   twcheck(!self.heroballs.count);
   
   for (int i = 0; i < self.game.levelBalls; i++)
   {
		BZHeroball *heroball = [[[BZHeroball alloc] initWithPosition:[self heroballSlot:i] gameScene:self] autorelease];
      [self addBodyNode:heroball z:0];
   }
}

- (b2Vec2)heroballSlot:(NSInteger)idx
{
   float segmentWidth = kLevelWidth / (kLifeBallsCount + 1);
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
   [self.hud removeActiveRing:heroball];
   CCSprite *skull = [CCSprite spriteWithSpriteFrameName:@"skull.png"];
   [self runBallOutAnimation:skull around:heroball.position];

   [self.heroballs removeObject:heroball];

   [self.game ballOut];
   
   if (kLevelStatePlaying == levelState_)
      [[SimpleAudioEngine sharedEngine] playEffect: @"herosmash.caf"];
   
   // is it time to ghost out obstacles?
   if (1 == self.game.levelBalls)
   {
      //twcheck(m_contactFilter);
      //m_contactFilter->mObstaclesAreGhosts = true;
      
      for (BZBodyNode* obstacle in self.obstacles)
      {
         obstacle.body->SetActive(false);
         
         CCFadeTo *fade = [CCFadeTo actionWithDuration:0.5 opacity:64];
         [obstacle runAction:fade];
      }
   }
  
   /* doing this while removing the last hero isn't a good idea; move to -updateGame
   if (!self.heroballs.count)
   {
      [self increaseLife:-1];
      if (kLevelStateOver != gameState_)
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

   // in motion? Or resetting?
   if (heroball.isMoving || heroball.resetting)
      return;

   heroball.shooting = NO;

   // does nothing, for now
   [self.game ballStopped];

   b2Body *ballBody = heroball.body;
   b2Vec2 ballPosition = ballBody->GetWorldCenter();

   // on any of the slots?
   b2Vec2 emptySlot;
   float lengthToEmptySlot = 9999.f;
   for (int i = 0; i < kLifeBallsCount; i++)
   {
      b2Vec2 slot = [self heroballSlot:i];
      if ([heroball coversPoint:slot])
         return;
      
      // check length to see if this is *closest* empty slot
      BOOL slotFilled = NO;
      for (BZHeroball* ball in self.heroballs)
      {
         if (ball == heroball)
            continue;
         if ([ball coversPoint:slot])
         {
            slotFilled = YES;
            break;
         }
      }
      if (!slotFilled)
      {
         float lengthToSlot = fabsf((ballPosition - slot).Length());
         if (lengthToSlot < lengthToEmptySlot)
         {
            lengthToEmptySlot = lengthToSlot;
            emptySlot = slot;
         }
      }
   }
 
   heroball.body->SetActive(false);
   heroball.properties = BN_PROPERTY_NONE;
   heroball.opacity = 128;
   heroball.resetting = YES;

   CGPoint where = ccp(
      emptySlot.x * kPhysicsPTMRatio,
      emptySlot.y * kPhysicsPTMRatio
   );
   id move = [CCMoveTo actionWithDuration:0.3 position:where];
   id wait = [CCDelayTime actionWithDuration:0.05];
   id done = [CCCallFuncN actionWithTarget:self selector:@selector(heroResetAnimationDone:)];
   id sequence = [CCSequence actions:move, wait, done, (id)nil];
   [heroball runAction:sequence];
}
   
- (void)heroResetAnimationDone:(BZHeroball *)heroball
{
   b2Body *ballBody = heroball.body;

   heroball.resetting = NO;
   heroball.opacity = 255;
   heroball.properties = BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS;
   heroball.body->SetActive(true);

   ballBody->SetLinearVelocity(b2Vec2());
   ballBody->SetAngularVelocity(0);
   b2Vec2 heroSlot(
      heroball.position.x / kPhysicsPTMRatio,
      heroball.position.y / kPhysicsPTMRatio
   );
	ballBody->SetTransform(heroSlot, 0);
   if (!self.hud.showingActiveRing)
      [self.hud showActiveRing:self.readyHeroball];
}

- (BZHeroball *)readyHeroball
{
   BZHeroball *hero = nil;
   
   if (kLevelStatePlaying == self.levelState)
      for (BZHeroball* ball in self.heroballs)
      {
         if (ball.isHero)
         {
             //if (ball.isMoving || ball.resetting)
             if (ball.shooting || ball.resetting)
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
   [self.targetballs addObject:targetball];
}

- (void)removeTargetball:(BZBall *)targetball
{
   [self.targetballs removeObject:targetball];

   // check on update when there's a ready ball, which should be after last one gets set
   //if (1 > targetballs_)
      //[self gameOver];
}

- (void)addObstacle:(BZBodyNode *)obstacle
{
   [self.obstacles addObject:obstacle];
}

- (void)removeObstacle:(BZBodyNode *)obstacle
{
   [self.obstacles removeObject:obstacle];
}

- (void)setPaused:(BOOL)paused
{
   if (paused)
   {
      levelState_ = kLevelStatePaused;
   }
   else if (kLevelStatePaused == levelState_)
   {
      levelState_ = kLevelStatePlaying;
   }
   // otherwise game is over, probably; we'll ignore
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
   
	levelState_ = kLevelStatePlaying;
	
	//CGRect rect = [self contentRect];
	//CCFollow *action = [CCFollow actionWithTarget:hero_ worldBoundary:rect];
	//[self runAction:action];
}

-(void) initGraphics
{
	//CCLOG(@"LevelSVG: BZLevelScene#initGraphics: override me");
   
   // sprites
	//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	// platforms
	//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"obstacles.plist"];
	// marbles
   [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"marbles.plist"];

	//
	// TIP
	// Use 16-bit texture in background. It consumes half the memory
	//
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	//CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
	//CCSprite *background = [CCSprite spriteWithFile:@"arena1.jpg"];
	CCSprite *background = [CCSprite spriteWithFile:self.game.currentArenaFileName];
	background.anchorPoint = ccp(0,0);
   //background.position = ccp(size.width/2, size.height/2);
   
	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	
	// weak ref
	//spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	
   // weak ref
	marblesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"marbles.png" capacity:20];

	// weak ref
	//platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"obstacles.png" capacity:10];
	//ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	//[platformBatchNode_.texture setTexParameters:&params];
	
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
	//[self addChild:spritesBatchNode_ z:2];
   [self addChild:marblesBatchNode_ z:3];

   [self setContentSize:[background contentSize]];   
}

- (NSString*)SVGFileName
{
	//CCLOG(@"LevelSVG: BZLevelScene:SVGFileName: override me");
	//return nil;
   
   NSString *filename = self.game.currentLevelFileName;
   twlog("loading level %@", filename);
   return filename;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	
   twrelease(heroballs_);
   twrelease(targetballs_);
   twrelease(obstacles_);

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
   // unlike LevelSVG, we do want bodies to be contact filtered
   // no, we can just set active false on them?
   //m_contactFilter = new MyContactFilter();
   //world_->SetContactFilter( m_contactFilter );
	
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

- (void)update:(ccTime)dt
{
	// Only step the world if status is Playing or GameOver
	if (kLevelStatePaused != levelState_)
   {
		
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
   
	if (kLevelStatePlaying == levelState_)
      [self.hud updateForceCycle];
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
   // don't bother, it'll always be out of sync after level finishes
   //twlogif(!((int)self.heroballs.count == self.game.balls), "updateGame: level %d balls, game %d balls", self.heroballs.count, self.game.balls);
   
   // is this level lost?
   
   if (!self.heroballs.count)
   {
      if (kLevelStateOver != levelState_)
      {
         //[self increaseLife:-1];
         [self.game levelLost];
         [hud_ onUpdateLives:self.game.lives];
         levelState_ = kLevelStateOver;
         
         CGSize size = [[CCDirector sharedDirector] winSize];

         //if( lives < 0 && lives_ == 0 )
         if (self.game.isGameLost)
         {
            //[hud_ displayMessage:@"GAMEFAIL"];
            BZSimpleButton *gameOver = [BZSimpleButton
                simpleButtonAtPosition:ccp(size.width/2, size.height/2)
                imageFrame:@"button_gameover.png"
                target:self
                selector:@selector(buttonGameOver:)
                ];
            [self addChild:gameOver z:100];
            [gameOver startWaving];
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.caf"];
         }
         else
         {
            //[hud_ displayMessage:@"LEVELFAIL"];
            //[self cleanLevel];
            //[self layoutLevel];
            BZSimpleButton *tryAgain = [BZSimpleButton
                simpleButtonAtPosition:ccp(size.width/2, size.height/2)
                imageFrame:@"button_tryagain.png"
                target:self
                selector:@selector(buttonTryAgain:)
                ];
            [self addChild:tryAgain z:100];
            [tryAgain startWaving];
            [[SimpleAudioEngine sharedEngine] playEffect:@"loselife.caf"];
        }
      }

      return;
   }
   
   // still moving, might go offscreen?

   if (!self.readyHeroball)
      return;
   
   // ball ready and all balls off? We win then
   
   if (1 > self.targetballs.count)
   {
      //[self levelFinished];
      if (kLevelStateOver != levelState_)
      {
         [self.game levelWon];
         levelState_ = kLevelStateOver;

         if (self.game.isGameWon)
         {
            //[hud_ displayMessage:@"GAMEWIN"];
            [self buttonShowScore:nil];
         }
         else
         {
            //[hud_ displayMessage:@"LEVELWIN"];
            //[self cleanLevel];
            //[self layoutLevel];
            [self buttonShowScore:nil];
         }
      }
       
      return;
  }
   
   // need to show the ready ball?
   
   if (kLevelStateOver != levelState_)
      if (!self.hud.showingActiveRing)
      {
         BZHeroball *hero = self.readyHeroball;
         if (hero)
            [self.hud showActiveRing:hero]; //.body->GetPosition()];
      }
}

- (void)buttonTryAgain:(id)sender
{
   (void)sender;
     
   id destinationScene = [BZLevelScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:1.0f scene:destinationScene]];
}

- (void)buttonGameOver:(id)sender
{
   (void)sender;
   
   [TWDataModel() endGame:self.game];
   
      // CCTransitionFadeDown
   id destinationScene = [BZMainScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:1.0f scene:destinationScene]];
}

- (void)buttonShowScore:(id)sender
{
   (void)sender;
   
   id destinationScene = [BZScoreScene scene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1.0f scene:destinationScene]];
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

/*
-(void)levelFinished
{
	gameState_ = kLevelStateOver;
	[hud_ displayMessage:@"You Won!"];
}
*/
/*
-(void) increaseLife:(int)lives
{
	lives_ += lives;
	[hud_ onUpdateLives:lives_];
	
	if( lives < 0 && lives_ == 0 ) {
		gameState_ = kLevelStateOver;
		[hud_ displayMessage:@"Game Over"];
	}
}
*/

- (void)targetBallOut:(BZBall *)targetball
{
	//[game_ increaseScore:kScoreBallOut];
   NSString *scoreString = [self.game targetOut];
   
   if (scoreString.length)
   {
		CCLabelBMFont *score = [CCLabelBMFont labelWithString:scoreString fntFile:@"bubblegum.fnt"];
      [score setColor:ccc3(64,64,64)];
      [self runBallOutAnimation:score around:targetball.position];
   }
   
	[hud_ onUpdateScore:self.game.score];
	[[SimpleAudioEngine sharedEngine] playEffect: @"targetpop.caf"];
}

- (void)runBallOutAnimation:(CCNode *)animation around:(CGPoint)where
{
   [self addChild:animation z:90];
   [animation setScale:.1f];
   CGSize winSize = [[CCDirector sharedDirector] winSize];
   winSize.height -= kTopHUDHeight;
   CGPoint animationPosition = ccp(
      (where.x >= winSize.width) ? winSize.width : MAX(0,where.x),
      (where.y >= winSize.height) ? winSize.height : MAX(0,where.y)
   );
   // throws annoying shadow warnings
   //{ animationPosition.x = MIN(winSize.width, MAX(0,targetball.position.x)); }
   //{ animationPosition.y = MIN(winSize.height, MAX(0,targetball.position.y)); }
   
   CGPoint animationAnchor = ccp(
      animationPosition.x / winSize.width,
      animationPosition.y / winSize.height
   );
   [animation setAnchorPoint:animationAnchor];
   [animation setPosition:animationPosition];		
   
   id scaleTo = [CCScaleTo actionWithDuration:0.1f scale:1];
   id wait = [CCDelayTime actionWithDuration:0.3f];
   id scaleBack = [CCScaleTo actionWithDuration:0.1f scale:.1f];
   id done = [CCCallFuncN actionWithTarget:self selector:@selector(ballOutAnimationDone:)];
   id seq = [CCSequence actions:scaleTo, wait, scaleBack, done, (id)nil];
   [animation runAction:seq];
}

- (void)ballOutAnimationDone:(CCNode *)animation
{
   [animation removeFromParentAndCleanup:YES];
}

/*
- (void)increaseScore:(int)score
{
	score_ += score;
	[hud_ onUpdateScore:score_];
}
 */

#pragma mark BZLevelScene - Box2d Callbacks

// will be called for each created body in the parser
-(void) physicsCallbackWithBody:(b2Body*)body attribs:(NSString *)gameAttribs
{
	NSArray *values = [gameAttribs componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];

   NSString *objectClassName = nil;
   NSMutableDictionary *objectParams = nil;
   
	for (NSString *propertyValue in nse)
   {
		NSArray *arr = [propertyValue componentsSeparatedByString:@"="];
		NSString *key = [arr objectAtIndex:0];
		NSString *value = [arr objectAtIndex:1];

		key = [key lowercaseString];
	
		if ([key isEqualToString:@"object"])
      {
			objectClassName = [@"BZ" stringByAppendingString:[value capitalizedString]];
		}
      else if ([key isEqualToString:@"objectparams"])
      {
			// Format of parameters:
			// objectParams=direction:vertical;target:1;visible:NO;
			
         objectParams = [NSMutableDictionary dictionaryWithCapacity:10];
         
			NSArray *params = [value componentsSeparatedByString:@";"];
			for (NSString *param in params)
         {
				NSArray *keyVal = [param componentsSeparatedByString:@":"];
				[objectParams setValue:[keyVal objectAtIndex:1] forKey:[keyVal objectAtIndex:0]];
			}
		}
      else
      {
			twlog("BZLevelScene physicsCallbackWithBody FAIL: unrecognized key: %@", key);
      }
	}
   
   if (objectClassName.length)
   {
      Class objectClass = NSClassFromString(objectClassName);
      
      if (objectClass)
      {
         // The BodyNode will be added to the scene graph at init time
         
         //BZBodyNode *node = [[objectClass alloc] initWithBody:body gameScene:self];
  			//[node setParameters:dict];
         BZBodyNode *node = [[objectClass alloc] initWithBody:body params:objectParams scene:self];
     
         [self addBodyNode:node z:0];
         [node release];					
      }
      else
      {
         twlog("BZLevelScene physicsCallbackWithBody FAIL: What's class %@?", objectClassName);
      }
   }
   else
   {
      twcheck(!objectParams);
   }
}

// This is the default behavior
-(void) addBodyNode:(BZBodyNode*)node z:(int)zOrder
{
   //(void)node;
   //(void)zOrder;
	//CCLOG(@"LevelSVG: BZLevelScene#addBodyNode override me");

	switch (node.preferredParent)
   {
         /*
		case BN_PREFERRED_PARENT_SPRITES_PNG:
         
			// Add to sprites' batch node
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
         */
         
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
- (BOOL)mouseDown:(b2Vec2) p
{
   // do nothing unless actively playing
   // which means not in tutorial -- although tutorial should override this
   if (!self.userPlaying)
      return NO;
   
   // is it trying to select a heroball?
   
   for (BZHeroball *ball in self.heroballs)
   {
      if (![ball coversPoint:p])
         continue;
    
      // can't select a moving heroball
      if (ball.isMoving)
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
   // and if there's nothing in play right now
   
   BZHeroball *ball = self.readyHeroball;
   if (!ball /*|| self.game.levelBallsInPlay*/)
   {
      //twlog("no heroball ready, or ball in play!");
      return NO;
   }
   
   [hud_ beginForceCycle];
   
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
   /* no, tapper in tutorial might want to call this
    // do nothing unless actively playing
   // which means not in tutorial -- although tutorial should override this
   if (!self.userPlaying)
   {
      twlog("not playing in BZLevelScene mouseUp??");
      return;
   }
    */
   
   BZHeroball *ball = self.readyHeroball;
   if (!ball)
   {
      twlog("no heroball ready!");
      return;
   }
   
   ball.shooting = YES;
   [self.hud endForceCycle];
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
   //ball.body->ApplyTorque(5);
	[[SimpleAudioEngine sharedEngine] playEffect:@"launch.caf"];
   [self.game ballShot];

   /*
	if (mouseJoint_)
	{
		world_->DestroyJoint(mouseJoint_);
		mouseJoint_ = NULL;
	}
    */
}


@end
